import SwiftUI

struct ActivitiesView: View {
    @StateObject private var viewModel: ActivitiesViewModel

    /// Kept to build each class's detail screen, which has its own view model over the same shared data.
    private let planner: PlannerViewModel

    init(planner: PlannerViewModel) {
        self.planner = planner
        _viewModel = StateObject(wrappedValue: ActivitiesViewModel(planner: planner))
    }

    var body: some View {
        NavigationStack {
            content
                .background(Theme.background)
                .tint(Theme.primaryText)
                .navigationTitle("Activities")
                .navigationDestination(for: Course.self) { course in
                    CourseDetailView(planner: planner, course: course)
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: viewModel.startAddingCourse) {
                            // Brown on orange keeps contrast; the prominent style otherwise defaults to white.
                            Image(systemName: "plus")
                                .foregroundStyle(Theme.primaryText)
                        }
                        .buttonStyle(.glassProminent)
                        .tint(Theme.accent)
                        .accessibilityLabel(Text("Add Class or Activity"))
                    }
                }
                .sheet(isPresented: $viewModel.isAddingCourse) {
                    AddCourseView(existingCourses: viewModel.courses, onSave: viewModel.addCourse)
                }
                .alert("Delete Class?", item: $viewModel.pendingDeletion) { course in
                    Button("Delete", role: .destructive) {
                        withAnimation { viewModel.deleteCourse(course) }
                    }
                    Button("Cancel", role: .cancel) {}
                } message: { course in
                    deletionMessage(for: course)
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isEmpty {
            ContentUnavailableView(
                "No Classes Yet",
                systemImage: "books.vertical",
                description: Text("Tap + to add a class or activity.")
            )
            .foregroundStyle(Theme.primaryText)
        } else {
            courseList
        }
    }

    private var courseList: some View {
        List {
            ForEach(viewModel.courses) { course in
                NavigationLink(value: course) {
                    CourseRow(course: course, openAssignmentCount: viewModel.openAssignmentCount(for: course))
                }
                .listRowBackground(Theme.surface)
                // Not `.destructive`: that role animates the row away before the user confirms in the alert.
                .swipeActions(allowsFullSwipe: false) {
                    Button("Delete", systemImage: "trash") {
                        viewModel.requestDeletion(of: course)
                    }
                    .tint(.red)
                }
                .contextMenu {
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        viewModel.requestDeletion(of: course)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
    }

    // Uses automatic grammar agreement so the count reads "1 assignment" or "3 assignments".
    private func deletionMessage(for course: Course) -> Text {
        let assignmentCount = viewModel.totalAssignmentCount(for: course)
        guard assignmentCount > 0 else {
            return Text("\"\(course.name)\" will be deleted.")
        }
        return Text("\"\(course.name)\" and its ^[\(assignmentCount) assignment](inflect: true) will be deleted.")
    }
}

#if DEBUG
#Preview {
    ActivitiesView(planner: PlannerViewModel())
}

#Preview("Empty") {
    ActivitiesView(planner: PlannerViewModel(courses: [], assignments: []))
}
#endif
