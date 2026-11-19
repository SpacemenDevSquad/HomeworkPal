import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel

    /// Kept to build each assignment's detail screen.
    private let planner: PlannerViewModel

    init(planner: PlannerViewModel) {
        self.planner = planner
        _viewModel = StateObject(wrappedValue: DashboardViewModel(planner: planner))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.isEmpty {
                    emptyState
                } else {
                    assignmentList
                }
            }
            .background(Theme.background)
            .tint(Theme.primaryText)
            .navigationTitle("Upcoming")
            .navigationDestination(for: AssignmentLink.self) { link in
                AssignmentDetailView(planner: planner, assignmentID: link.id)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: viewModel.startAddingAssignment) {
                        // Brown on orange keeps contrast; the prominent style otherwise defaults to white.
                        Image(systemName: "plus")
                            .foregroundStyle(Theme.primaryText)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(Theme.accent)
                    .accessibilityLabel(Text("Add Assignment"))
                }
            }
            .sheet(isPresented: $viewModel.isAddingAssignment, onDismiss: viewModel.presentQueuedCalendarEvent) {
                AddAssignmentView(courses: viewModel.courses, onSave: viewModel.addAssignment)
            }
            .sheet(item: $viewModel.assignmentToAddToCalendar) { assignment in
                AddToCalendarSheet(assignment: assignment) {
                    viewModel.markAddedToCalendar(assignment)
                }
                // Apple's form is embedded rather than presented, so it can't block a swipe-down itself;
                // without this, a swipe would silently discard the student's edits.
                .interactiveDismissDisabled()
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "Nothing Due",
            systemImage: "checkmark.circle",
            description: viewModel.courses.isEmpty
                ? Text("Add your classes in the Activities tab, then tap + to add homework.")
                : Text("Tap + to add homework.")
        )
        .foregroundStyle(Theme.primaryText)
    }

    private var assignmentList: some View {
        LazyVStack(alignment: .leading, spacing: 10, pinnedViews: .sectionHeaders) {
            ForEach(viewModel.sections) { section in
                Section {
                    ForEach(section.assignments) { assignment in
                        AssignmentRow(
                            assignment: assignment,
                            isOverdue: section.bucket == .overdue,
                            dueDateStyle: section.bucket.showsDateInsteadOfTime ? .date : .weekdayAndTime,
                            onToggle: { viewModel.markComplete(assignment) },
                            onAddToCalendar: { viewModel.requestCalendarEvent(for: assignment) }
                        )
                    }
                } header: {
                    SectionHeader(title: section.bucket.title)
                }
            }
        }
        .padding([.horizontal, .bottom])
    }
}

#if DEBUG
#Preview {
    DashboardView(planner: PlannerViewModel())
}

#Preview("Empty") {
    DashboardView(planner: PlannerViewModel(assignments: []))
}
#endif
