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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .safeAreaInset(edge: .top) {
                    kindPicker
                }
                .animation(.default, value: viewModel.selectedKind)
                .background(Theme.background)
                .tint(Theme.primaryText)
                // Matches the selected tab, so the title reads "Classes" or "Activities".
                .navigationTitle(viewModel.selectedKind == .activity ? "Activities" : "Classes")
                .navigationDestination(for: Course.self) { course in
                    CourseDetailView(planner: planner, course: course)
                }
                .navigationDestination(for: AssignmentLink.self) { link in
                    AssignmentDetailView(planner: planner, assignmentID: link.id)
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
                        .accessibilityLabel(viewModel.selectedKind == .activity ? Text("Add Activity") : Text("Add Class"))
                    }
                }
                .sheet(isPresented: $viewModel.isAddingCourse) {
                    AddCourseView(existingCourses: viewModel.courses, kind: viewModel.selectedKind, onSave: viewModel.addCourse)
                }
                .alert(viewModel.pendingDeletion?.kind == .activity ? "Delete Activity?" : "Delete Class?", item: $viewModel.pendingDeletion) { course in
                    Button("Delete", role: .destructive) {
                        withAnimation { viewModel.deleteCourse(course) }
                    }
                    Button("Cancel", role: .cancel) {}
                } message: { course in
                    deletionMessage(for: course)
                }
        }
    }

    private var kindPicker: some View {
        Picker("Show", selection: $viewModel.selectedKind) {
            Text("Classes").tag(CourseKind.schoolClass)
            Text("Activities").tag(CourseKind.activity)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isEmpty {
            emptyState
                .foregroundStyle(Theme.primaryText)
        } else {
            courseList
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        switch viewModel.selectedKind {
        case .schoolClass:
            ContentUnavailableView(
                "No Classes Yet",
                systemImage: "books.vertical",
                description: Text("Tap + to add a class.")
            )
        case .activity:
            ContentUnavailableView(
                "No Activities Yet",
                systemImage: "figure.run",
                description: Text("Tap + to add a sport, club, or other activity.")
            )
        }
    }

    private var courseList: some View {
        List {
            ForEach(viewModel.visibleCourses) { course in
                NavigationLink(value: course) {
                    CourseRow(course: course, openAssignmentCount: viewModel.openAssignmentCount(for: course))
                }
                .listRowBackground(CourseRow.background(for: course))
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
