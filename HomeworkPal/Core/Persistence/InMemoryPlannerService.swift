#if DEBUG
import Foundation

/// Keeps planner data in memory only. Debug-only, for previews and tests that shouldn't touch the disk.
final class InMemoryPlannerService: PlannerPersistenceService {
    private var courses: [Course]
    private var assignments: [Assignment]

    init(courses: [Course] = [], assignments: [Assignment] = []) {
        self.courses = courses
        self.assignments = assignments
    }

    func fetchPlanner() throws -> PlannerSnapshot {
        PlannerSnapshot(courses: courses, assignments: assignments)
    }

    func insertCourse(_ course: Course) throws {
        courses.append(course)
    }

    func deleteCourse(_ course: Course) throws {
        courses.removeAll { $0.id == course.id }
        assignments.removeAll { $0.course.id == course.id }
    }

    func updateCourse(_ course: Course) throws {
        guard let index = courses.firstIndex(where: { $0.id == course.id }) else {
            throw PlannerPersistenceError.courseNotFound
        }
        courses[index] = course
        for assignmentIndex in assignments.indices where assignments[assignmentIndex].course.id == course.id {
            assignments[assignmentIndex].course = course
        }
    }

    func updateAssignment(_ assignment: Assignment) throws {
        guard courses.contains(where: { $0.id == assignment.course.id }) else {
            throw PlannerPersistenceError.courseNotFound
        }
        guard let index = assignments.firstIndex(where: { $0.id == assignment.id }) else { return }
        assignments[index] = assignment
    }

    func insertAssignment(_ assignment: Assignment) throws {
        guard courses.contains(where: { $0.id == assignment.course.id }) else {
            throw PlannerPersistenceError.courseNotFound
        }
        assignments.append(assignment)
    }

    func setCompletion(_ isCompleted: Bool, forAssignmentID assignmentID: Assignment.ID) throws {
        guard let index = assignments.firstIndex(where: { $0.id == assignmentID }) else { return }
        assignments[index].isCompleted = isCompleted
    }

    func markAddedToCalendar(assignmentID: Assignment.ID) throws {
        guard let index = assignments.firstIndex(where: { $0.id == assignmentID }) else { return }
        assignments[index].isAddedToCalendar = true
    }

    func deleteAllData() throws {
        courses.removeAll()
        assignments.removeAll()
    }
}
#endif
