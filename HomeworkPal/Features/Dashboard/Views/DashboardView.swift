import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel
    @Environment(NotificationsViewModel.self) private var notifications
    /// Held so a tapped notification can push its assignment.
    @State private var path: [AssignmentLink] = []

    /// Kept to build each assignment's detail screen.
    private let planner: PlannerViewModel

    init(planner: PlannerViewModel) {
        self.planner = planner
        _viewModel = StateObject(wrappedValue: DashboardViewModel(planner: planner))
    }

    var body: some View {
        NavigationStack(path: $path) {
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
        // `initial` covers a tap that launched the app, which arrives before this view first appears.
        .onChange(of: notifications.assignmentToOpen, initial: true) { _, assignmentID in
            guard let assignmentID else { return }
            // Replaces whatever was open, so the tapped assignment is the only screen on top of the list.
            path = [AssignmentLink(id: assignmentID)]
            notifications.assignmentToOpen = nil
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
        // Headers scroll with their rows rather than pinning: a pinned header's solid band clashed with the
        // translucent navigation bar above it, leaving two mismatched strips at the top of the screen.
        LazyVStack(alignment: .leading, spacing: 10) {
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
                        // Scoped to the section: when an edit moves an assignment to another section, the lazy
                        // stack would otherwise reuse the old row and keep showing its old title and date.
                        .id(SectionedRowID(section: section.id, assignment: assignment.id))
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
    let planner = PlannerViewModel()
    DashboardView(planner: planner)
        .environment(NotificationsViewModel.preview(planner: planner))
}

#Preview("Empty") {
    let planner = PlannerViewModel(assignments: [])
    DashboardView(planner: planner)
        .environment(NotificationsViewModel.preview(planner: planner))
}
#endif
