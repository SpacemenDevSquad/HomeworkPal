import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel: CalendarViewModel
    @Environment(\.dismiss) private var dismiss

    private let onComplete: (Assignment) -> Void
    private let onAddedToCalendar: (Assignment) -> Void

    /// - Parameters:
    ///   - onComplete: Called when an assignment is checked off here, so the owner of the assignments can record it.
    ///   - onAddedToCalendar: Called when an assignment's event is saved to Apple Calendar here, for the same reason.
    init(
        assignments: [Assignment] = Assignment.sampleData,
        onComplete: @escaping (Assignment) -> Void = { _ in },
        onAddedToCalendar: @escaping (Assignment) -> Void = { _ in }
    ) {
        _viewModel = StateObject(wrappedValue: CalendarViewModel(assignments: assignments))
        self.onComplete = onComplete
        self.onAddedToCalendar = onAddedToCalendar
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
            .sheet(item: $viewModel.assignmentToAddToCalendar) { assignment in
                AddToCalendarSheet(assignment: assignment) {
                    viewModel.markAddedToCalendar(assignment)
                    onAddedToCalendar(assignment)
                }
            }
            .alert("Mark as Complete?", item: $viewModel.pendingCompletion) { assignment in
                Button("Complete") {
                    withAnimation { viewModel.markComplete(assignment) }
                    onComplete(assignment)
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
        VStack(alignment: .leading, spacing: 8) {
            backButton
            titleRow
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // The navigation bar is hidden, so the system back button is replaced with this one.
    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            Label("Dashboard", systemImage: "chevron.left")
                .frame(minHeight: Theme.minimumTapTarget)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .foregroundStyle(Theme.primaryText)
        .accessibilityLabel(Text("Back to Dashboard"))
    }

    private var titleRow: some View {
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

#Preview {
    CalendarView()
}

#Preview("Empty") {
    CalendarView(assignments: [])
}
