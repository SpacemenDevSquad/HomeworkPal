import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel

    init(planner: PlannerViewModel) {
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
                            onToggle: { viewModel.requestCompletion(for: assignment) },
                            onAddToCalendar: { viewModel.requestCalendarEvent(for: assignment) }
                        )
                    }
                } header: {
                    SectionHeader(
                        title: section.bucket.title,
                        count: section.assignments.count,
                        isEmphasized: section.bucket == .overdue
                    )
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
