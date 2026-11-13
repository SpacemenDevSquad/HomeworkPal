import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel

    init(viewModel: DashboardViewModel = DashboardViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
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
            .sheet(isPresented: $viewModel.isAddingAssignment) {
                AddAssignmentView(courses: viewModel.courses, onSave: viewModel.addAssignment)
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
            description: Text("Tap + to add homework.")
        )
        .foregroundStyle(Theme.primaryText)
    }

    private var assignmentList: some View {
        LazyVStack(alignment: .leading, spacing: 10, pinnedViews: .sectionHeaders) {
            ForEach(viewModel.sections) { section in
                Section {
                    ForEach(section.assignments) { assignment in
                        AssignmentRow(assignment: assignment, isOverdue: section.bucket == .overdue) {
                            viewModel.requestCompletion(for: assignment)
                        }
                    }
                } header: {
                    SectionHeader(bucket: section.bucket, count: section.assignments.count)
                }
            }
        }
        .padding([.horizontal, .bottom])
    }
}

#Preview {
    DashboardView()
}

#Preview("Empty") {
    DashboardView(viewModel: DashboardViewModel(assignments: []))
}
