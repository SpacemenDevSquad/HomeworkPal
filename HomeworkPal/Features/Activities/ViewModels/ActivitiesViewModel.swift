import Combine
import Foundation

@MainActor
final class ActivitiesViewModel: ObservableObject {
    @Published var isAddingCourse = false
    /// The class or activity awaiting confirmation before it's deleted. Drives the confirmation alert.
    @Published var pendingDeletion: Course?

    private let planner: PlannerViewModel

    init(planner: PlannerViewModel) {
        self.planner = planner
    }

    var courses: [Course] {
        planner.courses
    }

    var isEmpty: Bool {
        courses.isEmpty
    }

    func openAssignmentCount(for course: Course) -> Int {
        planner.assignments(for: course).filter { !$0.isCompleted }.count
    }

    /// Every assignment that deleting the course would remove, open or completed, for the warning message.
    func totalAssignmentCount(for course: Course) -> Int {
        planner.assignments(for: course).count
    }

    func startAddingCourse() {
        isAddingCourse = true
    }

    func addCourse(_ course: Course) {
        planner.addCourse(course)
    }

    /// Asks the user to confirm before deleting, because the course's assignments are deleted with it.
    func requestDeletion(of course: Course) {
        pendingDeletion = course
    }

    func deleteCourse(_ course: Course) {
        planner.deleteCourse(course)
    }
}
