import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel: CalendarViewModel

    init(planner: PlannerViewModel) {
        _viewModel = StateObject(wrappedValue: CalendarViewModel(planner: planner))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 10) {
                    titleHeader
                    ForEach(viewModel.days) { day in
                        CalendarDayRow(day: day, viewModel: viewModel)
                    }
                }
                .padding([.horizontal, .bottom])
            }
            .background(Theme.background)
            // Pinned to the bottom so the week arrows sit within easy thumb reach; content scrolls underneath.
            .safeAreaInset(edge: .bottom) {
                weekNavigator
            }
            .tint(Theme.primaryText)
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
            .alert("Mark as Complete?", item: $viewModel.pendingCompletion) { assignment in
                Button("Complete") {
                    withAnimation { viewModel.markComplete(assignment) }
                }
                // Marks Complete as the default action so the system shows it with greater prominence.
                .keyboardShortcut(.defaultAction)
                Button("Cancel", role: .cancel) {}
            } message: { assignment in
                Text("\"\(assignment.title)\" will be checked off your list.")
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
                Button("Today") {
                    withAnimation { viewModel.showCurrentWeek() }
                }
                .buttonStyle(.glass)
                .foregroundStyle(Theme.primaryText)
                .frame(minHeight: Theme.minimumTapTarget)
            }
        }
        // Keeps the header the same height whether or not Today is showing, so the rows don't shift.
        .frame(minHeight: Theme.minimumTapTarget)
    }

    private var weekNavigator: some View {
        HStack {
            Button {
                withAnimation { viewModel.showPreviousWeek() }
            } label: {
                Image(systemName: "chevron.left")
                    .frame(minWidth: Theme.minimumTapTarget, minHeight: Theme.minimumTapTarget)
                    .contentShape(.circle)
            }
            .accessibilityLabel(Text("Previous Week"))

            Spacer()

            Text(viewModel.weekRange, format: .interval.month(.abbreviated).day())
                .font(.headline)
                .foregroundStyle(Theme.primaryText)
                .padding(.horizontal)
                .frame(minHeight: Theme.minimumTapTarget)
                .glassEffect(.regular, in: .capsule)

            Spacer()

            Button {
                withAnimation { viewModel.showNextWeek() }
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
}

#if DEBUG
#Preview {
    CalendarView(planner: PlannerViewModel())
}

#Preview("Empty") {
    CalendarView(planner: PlannerViewModel(assignments: []))
}
#endif
