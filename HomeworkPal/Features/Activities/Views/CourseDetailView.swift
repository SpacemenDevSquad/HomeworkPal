import SwiftUI

struct CourseDetailView: View {
    private static let colorBarWidth: CGFloat = 6

    @StateObject private var viewModel: CourseDetailViewModel
    @Environment(\.dismiss) private var dismiss

    init(planner: PlannerViewModel, course: Course) {
        _viewModel = StateObject(wrappedValue: CourseDetailViewModel(planner: planner, course: course))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                if hasDetails {
                    detailsCard
                        .padding(.horizontal)
                }
                if viewModel.isEmpty {
                    emptyState
                } else {
                    assignmentList
                }
            }
        }
        .background(Theme.background)
        .navigationTitle(viewModel.course.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: viewModel.startEditing) {
                    Image(systemName: "pencil")
                        .foregroundStyle(Theme.primaryText)
                }
                .accessibilityLabel(Text("Edit \(viewModel.course.name)"))
            }
        }
        // Waits for the sheet to finish closing before leaving, because a deleted class has nothing left to show.
        .sheet(isPresented: $viewModel.isEditing, onDismiss: closeIfCourseDeleted) {
            AddCourseView(
                existingCourses: viewModel.allCourses,
                editing: viewModel.course,
                assignmentCount: viewModel.totalAssignmentCount,
                onSave: viewModel.save,
                onDelete: viewModel.deleteCourse
            )
        }
    }

    private func closeIfCourseDeleted() {
        guard viewModel.isCourseDeleted else { return }
        dismiss()
    }

    private var hasDetails: Bool {
        viewModel.course.location != nil
    }

    /// Where the class or activity meets.
    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let location = viewModel.course.location {
                Label(location, systemImage: "mappin.and.ellipse")
            }
        }
        .foregroundStyle(Theme.primaryText)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Theme.surface, in: .rect(cornerRadius: Theme.cornerRadius))
        .overlay(alignment: .leading) {
            UnevenRoundedRectangle(topLeadingRadius: Theme.cornerRadius, bottomLeadingRadius: Theme.cornerRadius)
                .fill(viewModel.course.color)
                .frame(width: Self.colorBarWidth)
        }
        .clipShape(.rect(cornerRadius: Theme.cornerRadius))
        .accessibilityElement(children: .combine)
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
                        viewModel.toggleCompletion(of: assignment)
                    }
                }
            } header: {
                SectionHeader(title: title, count: assignments.count)
            }
        }
    }
}

#if DEBUG
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
#endif
