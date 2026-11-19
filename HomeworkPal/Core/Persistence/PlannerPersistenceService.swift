import Foundation

/// Everything the app has saved, loaded together at launch.
struct PlannerSnapshot: Sendable {
    let courses: [Course]
    let assignments: [Assignment]
}

/// Reads and writes the student's planner data on the device.
protocol PlannerPersistenceService {
    func fetchPlanner() throws -> PlannerSnapshot
    func insertCourse(_ course: Course) throws
    /// Deletes the course and every assignment that belongs to it.
    func deleteCourse(_ course: Course) throws
    func insertAssignment(_ assignment: Assignment) throws
    func setCompletion(_ isCompleted: Bool, forAssignmentID assignmentID: Assignment.ID) throws
    /// Deletes every course and assignment.
    func deleteAllData() throws
}

enum PlannerPersistenceError: LocalizedError {
    case storeUnavailable
    case loadFailed
    case saveFailed
    case courseNotFound

    var errorDescription: String? {
        switch self {
        case .storeUnavailable:
            String(localized: "Your planner couldn't be opened, so changes can't be saved right now.")
        case .loadFailed:
            String(localized: "Your planner couldn't be loaded. Please try again.")
        case .saveFailed:
            String(localized: "That change couldn't be saved. Please try again.")
        case .courseNotFound:
            String(localized: "That class or activity no longer exists.")
        }
    }
}
