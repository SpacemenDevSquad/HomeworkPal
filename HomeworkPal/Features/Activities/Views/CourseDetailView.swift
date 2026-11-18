import SwiftUI

struct CourseDetailView: View {
    @StateObject private var viewModel: CourseDetailViewModel

    init(planner: PlannerViewModel, course: Course) {
        _viewModel = StateObject(wrappedValue: CourseDetailViewModel(planner: planner, course: course))
    }

    var body: some View {
        ScrollView {
            if viewModel.isEmpty {
                emptyState
            } else {
                assignmentList
            }
        }
        .background(Theme.background)
        .navigationTitle(viewModel.course.name)
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

    private var emptyState: some View {
        ContentUnavailableView(
            "No Assignments",
            systemImage: "tray",
            description: Text("Nothing has been added to \(viewModel.course.name) yet.")
        )
        .foregroundStyle(Theme.primaryText)
    }

    private var assignmentList: some View {
        LazyVStack(alignment: .leading, spacing: 10, pinnedViews: .sectionHeaders) {
            assignmentSection(title: "Upcoming", assignments: viewModel.openAssignments)
            assignmentSection(title: "Completed", assignments: viewModel.completedAssignments)
        }
        .padding([.horizontal, .bottom])
    }

    @ViewBuilder
    private func assignmentSection(title: LocalizedStringResource, assignments: [Assignment]) -> some View {
        if !assignments.isEmpty {
            Section {
                ForEach(assignments) { assignment in
                    AssignmentRow(assignment: assignment, isOverdue: viewModel.isOverdue(assignment)) {
                        withAnimation { viewModel.toggleCompletion(of: assignment) }
                    }
                }
            } header: {
                SectionHeader(title: title, count: assignments.count)
            }
        }
    }
}

#Preview {
    let finishedEssay = Assignment(
        title: "Poetry analysis",
        course: .english,
        dueDate: .now.addingTimeInterval(-86_400),
        isCompleted: true
    )
    NavigationStack {
        CourseDetailView(planner: PlannerViewModel(assignments: Assignment.sampleData + [finishedEssay]), course: .english)
    }
}

#Preview("Empty") {
    NavigationStack {
        CourseDetailView(planner: PlannerViewModel(assignments: []), course: .english)
    }
}
