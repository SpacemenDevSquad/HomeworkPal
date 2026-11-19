import SwiftUI

struct CalendarView: View {
    /// A requested move to another week. Held for one view update before it's applied, so the
    /// outgoing week is re-rendered with the new slide direction before it animates away.
    private struct PendingWeekChange: Equatable {
        let id = UUID()
        let target: Date
    }

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
                LazyVStack(spacing: 10) {
                    titleHeader
                    weekDays
                }
                .padding([.horizontal, .bottom])
            }
            .background(Theme.background)
            // Pinned to the bottom so the week arrows sit within easy thumb reach; content scrolls underneath.
            .safeAreaInset(edge: .bottom) {
                weekNavigator
            }
            .tint(Theme.primaryText)
            .navigationDestination(for: AssignmentLink.self) { link in
                AssignmentDetailView(planner: planner, assignmentID: link.id)
            }
            .task(id: pendingWeekChange) {
                guard let change = pendingWeekChange else { return }
                withAnimation(.snappy) {
                    viewModel.showWeek(containing: change.target)
                }
            }
            .sheet(isPresented: $isShowingWeekPicker) {
                WeekPickerSheet(initialDate: viewModel.pickerStartDate) { date in
                    isShowingWeekPicker = false
                    changeWeek(toWeekContaining: date)
                }
            }
            // The system large title can't hold a button beside it, so the title is drawn in `titleHeader` instead.
            .toolbar(.hidden, for: .navigationBar)
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

    private var titleHeader: some View {
        HStack {
            Text("Calendar")
                .font(.largeTitle.bold())
                .foregroundStyle(Theme.primaryText)
                .accessibilityAddTraits(.isHeader)

            Spacer()

            if !viewModel.isShowingCurrentWeek {
                Button("Back to This Week") {
                    changeWeek(toWeekContaining: .now)
                }
                .buttonStyle(.glass)
                .foregroundStyle(Theme.primaryText)
                .frame(minHeight: Theme.minimumTapTarget)
            }
        }
        // Keeps the header the same height whether or not the button is showing, so the rows don't shift.
        .frame(minHeight: Theme.minimumTapTarget)
    }

    /// The shown week's days. Its identity is the week, so changing weeks swaps the whole block and
    /// slides the new week in from the side it's coming from.
    private var weekDays: some View {
        VStack(spacing: 10) {
            ForEach(viewModel.days) { day in
                CalendarDayRow(day: day, viewModel: viewModel)
            }
        }
        .id(viewModel.weekStart)
        .transition(.push(from: slideDirection == .forward ? .trailing : .leading))
    }

    private var weekNavigator: some View {
        HStack {
            Button {
                changeWeek(byWeeks: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .frame(minWidth: Theme.minimumTapTarget, minHeight: Theme.minimumTapTarget)
                    .contentShape(.circle)
            }
            .accessibilityLabel(Text("Previous Week"))

            Spacer()

            Button {
                isShowingWeekPicker = true
            } label: {
                HStack(spacing: 6) {
                    Text(viewModel.weekRange, format: .interval.month(.abbreviated).day())
                        .contentTransition(.numericText())
                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.semibold))
                        .accessibilityHidden(true)
                }
                .font(.headline)
                .padding(.horizontal, 4)
                .frame(minHeight: Theme.minimumTapTarget)
            }
            .buttonBorderShape(.capsule)
            .accessibilityHint(Text("Opens a calendar to jump to another week"))

            Spacer()

            Button {
                changeWeek(byWeeks: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .frame(minWidth: Theme.minimumTapTarget, minHeight: Theme.minimumTapTarget)
                    .contentShape(.circle)
            }
            .accessibilityLabel(Text("Next Week"))
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .foregroundStyle(Theme.primaryText)
        .padding([.horizontal, .bottom])
    }

    private func changeWeek(byWeeks weekCount: Int) {
        let target = Calendar.current.date(byAdding: .weekOfYear, value: weekCount, to: viewModel.weekStart) ?? viewModel.weekStart
        changeWeek(toWeekContaining: target)
    }

    /// Sets the slide direction now and applies the move on the next update (see `PendingWeekChange`).
    private func changeWeek(toWeekContaining date: Date) {
        slideDirection = viewModel.direction(toWeekContaining: date)
        pendingWeekChange = PendingWeekChange(target: date)
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
                .navigationTitle("Go to Week")
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
