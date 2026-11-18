import Foundation
import Observation

/// The single source of truth for classes, activities, and assignments, shared by every tab.
///
/// Created once in `HomeworkPalApp` and injected with `.environment`. Feature view models hold only
/// their own screen state and read or write through this, so a change in one tab shows up in all of them.
@MainActor
@Observable
final class PlannerViewModel {
    private(set) var courses: [Course]
    private(set) var assignments: [Assignment]

    init(courses: [Course] = Course.sampleData, assignments: [Assignment] = Assignment.sampleData) {
        self.courses = courses
        self.assignments = assignments
    }

    func assignments(for course: Course) -> [Assignment] {
        assignments.filter { $0.course.id == course.id }
    }

    func addAssignment(_ assignment: Assignment) {
        assignments.append(assignment)
    }

    func markComplete(_ assignment: Assignment) {
        setCompletion(true, for: assignment)
    }

    func markIncomplete(_ assignment: Assignment) {
        setCompletion(false, for: assignment)
    }

    func addCourse(_ course: Course) {
        courses.append(course)
    }

    /// Deletes the class or activity together with its assignments, so no assignment is left without one.
    func deleteCourse(_ course: Course) {
        courses.removeAll { $0.id == course.id }
        assignments.removeAll { $0.course.id == course.id }
    }

    private func setCompletion(_ isCompleted: Bool, for assignment: Assignment) {
        guard let index = assignments.firstIndex(where: { $0.id == assignment.id }) else { return }
        assignments[index].isCompleted = isCompleted
    }
}
