import SwiftUI

struct CalendarView: View {
    /// A requested move to another week. Held for one view update before it's applied, so the
    /// outgoing week is re-rendered with the new slide direction before it animates away.
    private struct PendingWeekChange: Equatable {
        enum Kind: Equatable {
            /// Move by this many weeks, keeping the same weekday selected.
            case byWeeks(Int)
            /// Jump to this exact day.
            case toDate(Date)
        }

        let id = UUID()
        let kind: Kind
    }

    private static let arrowIconSize: CGFloat = 28

    @StateObject private var viewModel: CalendarViewModel
    /// Kept to build each assignment's detail screen.
    private let planner: PlannerViewModel
    @State private var slideDirection: WeekChangeDirection = .forward
    @State private var pendingWeekChange: PendingWeekChange?
    @State private var isShowingWeekPicker = false

    init(planner: PlannerViewModel) {
        self.planner = planner
        _viewModel = StateObject(wrappedValue: CalendarViewModel(planner: planner))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    titleHeader
                    weekStrip
                    dayHeader
                    agenda
                }
                .padding([.horizontal, .bottom])
            }
            .background(Theme.background)
            .tint(Theme.primaryText)
            .navigationDestination(for: AssignmentLink.self) { link in
                AssignmentDetailView(planner: planner, assignmentID: link.id)
            }
            // `onChange` rather than `.task(id:)`: a task re-runs whenever the view reappears, which replayed the
            // last week change after switching tabs and threw away the day the student had picked.
            .onChange(of: pendingWeekChange) { _, change in
                guard let change else { return }
                withAnimation(.snappy) {
                    switch change.kind {
                    case .byWeeks(let weekCount):
                        weekCount > 0 ? viewModel.showNextWeek() : viewModel.showPreviousWeek()
                    case .toDate(let date):
                        viewModel.show(date)
                    }
                }
                pendingWeekChange = nil
            }
            .sheet(isPresented: $isShowingWeekPicker) {
                WeekPickerSheet(initialDate: viewModel.pickerStartDate) { date in
                    isShowingWeekPicker = false
                    change(to: date)
                }
            }
            // The system large title keeps "Calendar" at the same height as the other tabs' titles.
            .navigationTitle("Calendar")
            .toolbar {
                if !viewModel.isShowingToday {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Today") {
                            change(to: .now)
                        }
                        .foregroundStyle(Theme.primaryText)
                    }
                }
            }
            // Closing one sheet opens the next during Add All; it waits for dismissal so sheets don't overlap.
            .sheet(item: $viewModel.assignmentToAddToCalendar, onDismiss: viewModel.presentNextQueuedCalendarEvent) { assignment in
                AddToCalendarSheet(
                    assignment: assignment,
                    onSaved: { viewModel.markAddedToCalendar(assignment) },
                    onCancelled: viewModel.cancelQueuedCalendarEvents
                )
                // Apple's form is embedded rather than presented, so it can't block a swipe-down itself;
                // without this, a swipe would silently discard the student's edits.
                .interactiveDismissDisabled()
            }
            .alert("Add All Events?", item: $viewModel.dayPendingAddAll) { day in
                Button("Add") {
                    viewModel.addAllToCalendar(on: day)
                }
                .keyboardShortcut(.defaultAction)
                Button("Cancel", role: .cancel) {}
            } message: { day in
                // Automatic grammar agreement turns "assignment" plural when the count isn't 1.
                Text("^[\(day.assignmentsNotAddedToCalendar.count) assignment](inflect: true) will open in the Add Event sheet, one at a time.")
            }
        }
    }

    /// The month, which opens the month picker, beside the previous and next week arrows.
    private var titleHeader: some View {
        HStack {
            monthButton
            Spacer()
            weekArrows
        }
    }

    private var monthButton: some View {
        Button {
            isShowingWeekPicker = true
        } label: {
            HStack(spacing: 4) {
                Text(viewModel.selectedDate, format: .dateTime.month(.wide).year())
                    .contentTransition(.numericText())
                Image(systemName: "chevron.down")
                    .font(.caption.weight(.semibold))
                    .accessibilityHidden(true)
            }
            .font(.headline)
            .foregroundStyle(Theme.secondaryText)
            .frame(minHeight: Theme.minimumTapTarget)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityHint(Text("Opens a calendar to jump to another day"))
    }

    private var weekArrows: some View {
        HStack(spacing: 8) {
            weekArrow(systemImage: "chevron.left", label: Text("Previous Week"), weekCount: -1)
            weekArrow(systemImage: "chevron.right", label: Text("Next Week"), weekCount: 1)
        }
    }

    private func weekArrow(systemImage: String, label: Text, weekCount: Int) -> some View {
        Button {
            changeWeek(by: weekCount)
        } label: {
            Image(systemName: systemImage)
                .font(.body.weight(.semibold))
                // The glass style adds its own padding, which brings this up to a full 44-point tap target.
                .frame(width: Self.arrowIconSize, height: Self.arrowIconSize)
                .contentShape(.circle)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .foregroundStyle(Theme.primaryText)
        .accessibilityLabel(label)
    }

    /// The week's identity is its first day, so changing weeks swaps the whole strip and
    /// slides the new week in from the side it's coming from.
    private var weekStrip: some View {
        CalendarWeekStrip(viewModel: viewModel, onChangeWeek: changeWeek(by:))
            .id(viewModel.weekStart)
            .transition(.push(from: slideDirection == .forward ? .trailing : .leading))
    }

    /// Moves by whole weeks, from the arrows or a swipe, keeping the same weekday selected.
    private func changeWeek(by weekCount: Int) {
        slideDirection = weekCount > 0 ? .forward : .backward
        pendingWeekChange = PendingWeekChange(kind: .byWeeks(weekCount))
    }

    private var dayHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(viewModel.selectedDate, format: .dateTime.weekday(.wide).month(.wide).day())
                .font(.title2.bold())
                .foregroundStyle(Theme.primaryText)
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: 8)
            // An empty day already says "Nothing due" below, so the count only shows when there's work.
            if !viewModel.selectedDay.isEmpty {
                Text("^[\(viewModel.selectedDay.assignments.count) assignment](inflect: true)")
                    .font(.subheadline)
                    .foregroundStyle(Theme.secondaryText)
            }
        }
        .padding(.top, 4)
    }

    @ViewBuilder
    private var agenda: some View {
        let day = viewModel.selectedDay
        if day.isEmpty {
            emptyDay
        } else {
            LazyVStack(spacing: 10) {
                ForEach(day.assignments) { assignment in
                    CalendarAgendaRow(
                        assignment: assignment,
                        isOverdue: viewModel.isOverdue(assignment),
                        onToggle: { viewModel.toggleCompletion(of: assignment) },
                        onAddToCalendar: { viewModel.requestCalendarEvent(for: assignment) }
                    )
                    // Scoped to the day, so a row is drawn fresh when the selection or its due day changes.
                    .id(SectionedRowID(section: day.id, assignment: assignment.id))
                }
            }
        }
    }

    private var emptyDay: some View {
        Text("Nothing due")
            .font(.body)
            .foregroundStyle(Theme.secondaryText)
            .frame(maxWidth: .infinity, minHeight: Theme.minimumTapTarget * 2)
    }

    /// Jumps to `date`, setting the slide direction now and applying the move on the next update (see `PendingWeekChange`).
    private func change(to date: Date) {
        slideDirection = viewModel.direction(toWeekContaining: date)
        pendingWeekChange = PendingWeekChange(kind: .toDate(date))
    }
}

/// A month calendar for jumping straight to any week. Picking a day closes it right away.
private struct WeekPickerSheet: View {
    private static let sheetHeightFraction = 0.62

    @State private var selection: Date
    @Environment(\.dismiss) private var dismiss
    private let onPick: (Date) -> Void

    init(initialDate: Date, onPick: @escaping (Date) -> Void) {
        _selection = State(initialValue: initialDate)
        self.onPick = onPick
    }

    var body: some View {
        NavigationStack {
            DatePicker("Date", selection: $selection, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .labelsHidden()
                .tint(Theme.accent)
                .padding(.horizontal)
                .frame(maxHeight: .infinity, alignment: .top)
                .background(Theme.background)
                .navigationTitle("Go to Date")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", role: .cancel) { dismiss() }
                    }
                }
                // Month paging doesn't change the selection, so this only fires when a day is tapped.
                .onChange(of: selection) { _, newDate in
                    onPick(newDate)
                }
        }
        .foregroundStyle(Theme.primaryText)
        .presentationDetents([.fraction(Self.sheetHeightFraction), .large])
        .presentationBackground(Theme.background)
    }
}

#if DEBUG
#Preview {
    CalendarView(planner: PlannerViewModel())
}

#Preview("Empty") {
    CalendarView(planner: PlannerViewModel(assignments: []))
}
#endif
