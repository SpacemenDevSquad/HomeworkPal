import Foundation
import Observation
import OSLog

/// The single source of truth for classes, activities, and assignments, shared by every tab.
///
/// Created once in `HomeworkPalApp` and injected with `.environment`. Feature view models hold only
/// their own screen state and read or write through this, so a change in one tab shows up in all of them.
/// Every change is saved to the device first and applied in memory only if the save succeeds, so what
/// the student sees always matches what's stored.
@MainActor
@Observable
final class PlannerViewModel {
    private(set) var courses: [Course] = []
    private(set) var assignments: [Assignment] = []
    /// A user-facing description of the last failed load or save, shown in an alert.
    private(set) var errorMessage: String?

    private let persistence: any PlannerPersistenceService

    init(persistence: any PlannerPersistenceService) {
        self.persistence = persistence
    }

    /// Loads saved data from the device. Called from `.task` rather than `init` to keep startup cheap.
    func loadPlanner() {
        perform {
            let snapshot = try persistence.fetchPlanner()
            courses = snapshot.courses
            assignments = snapshot.assignments
        }
    }

    func assignments(for course: Course) -> [Assignment] {
        assignments.filter { $0.course.id == course.id }
    }

    func addAssignment(_ assignment: Assignment) {
        perform {
            try persistence.insertAssignment(assignment)
            assignments.append(assignment)
        }
    }

    func updateAssignment(_ assignment: Assignment) {
        guard let index = assignments.firstIndex(where: { $0.id == assignment.id }) else { return }
        perform {
            try persistence.updateAssignment(assignment)
            assignments[index] = assignment
        }
    }

    func deleteAssignment(_ assignment: Assignment) {
        perform {
            try persistence.deleteAssignment(assignment)
            assignments.removeAll { $0.id == assignment.id }
        }
    }

    func markComplete(_ assignment: Assignment) {
        setCompletion(true, for: assignment)
    }

    func markIncomplete(_ assignment: Assignment) {
        setCompletion(false, for: assignment)
    }

    /// Records that the student saved the assignment's event in Apple's Add Event sheet.
    func markAddedToCalendar(_ assignment: Assignment) {
        guard let index = assignments.firstIndex(where: { $0.id == assignment.id }) else { return }
        perform {
            try persistence.markAddedToCalendar(assignmentID: assignment.id)
            assignments[index].isAddedToCalendar = true
        }
    }

    func addCourse(_ course: Course) {
        perform {
            try persistence.insertCourse(course)
            courses.append(course)
        }
    }

    /// Saves edits to a class or activity. Assignments carry a copy of their course, so those copies are
    /// refreshed too, keeping names and colors in step everywhere.
    func updateCourse(_ course: Course) {
        guard let index = courses.firstIndex(where: { $0.id == course.id }) else { return }
        perform {
            try persistence.updateCourse(course)
            courses[index] = course
            for assignmentIndex in assignments.indices where assignments[assignmentIndex].course.id == course.id {
                assignments[assignmentIndex].course = course
            }
        }
    }

    func course(withID id: Course.ID) -> Course? {
        courses.first { $0.id == id }
    }

    func assignment(withID id: Assignment.ID) -> Assignment? {
        assignments.first { $0.id == id }
    }

    /// Deletes the class or activity together with its assignments, so no assignment is left without one.
    func deleteCourse(_ course: Course) {
        perform {
            try persistence.deleteCourse(course)
            courses.removeAll { $0.id == course.id }
            assignments.removeAll { $0.course.id == course.id }
        }
    }

    /// Erases every class, activity, and assignment. Throws rather than using the shared error alert, so the
    /// caller (Settings' Clear Data) can report the failure in its own UI.
    func deleteAllData() throws {
        try persistence.deleteAllData()
        courses = []
        assignments = []
    }

    /// Drives the error alert; setting it to `false` dismisses the current error.
    var isShowingError: Bool {
        get { errorMessage != nil }
        set { if !newValue { errorMessage = nil } }
    }

    private func setCompletion(_ isCompleted: Bool, for assignment: Assignment) {
        guard let index = assignments.firstIndex(where: { $0.id == assignment.id }) else { return }
        perform {
            try persistence.setCompletion(isCompleted, forAssignmentID: assignment.id)
            assignments[index].isCompleted = isCompleted
        }
    }

    /// Runs a save or load, turning any failure into a message for the student instead of failing silently.
    private func perform(_ operation: () throws -> Void) {
        do {
            try operation()
        } catch {
            Logger.persistence.error("Planner operation failed: \(error.localizedDescription, privacy: .private)")
            errorMessage = error.localizedDescription
        }
    }
}

#if DEBUG
extension PlannerViewModel {
    /// A planner backed by memory only and preloaded with the given data. For previews and tests.
    convenience init(courses: [Course] = Course.sampleData, assignments: [Assignment] = Assignment.sampleData) {
        self.init(persistence: InMemoryPlannerService(courses: courses, assignments: assignments))
        loadPlanner()
    }
}
#endif
