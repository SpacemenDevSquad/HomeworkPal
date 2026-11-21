import Foundation

/// Used when the on-device store can't be opened at launch, so the app still runs and tells the
/// student their changes can't be saved, rather than crashing or silently losing their work.
struct UnavailablePlannerService: PlannerPersistenceService {
    func fetchPlanner() throws -> PlannerSnapshot {
        throw PlannerPersistenceError.storeUnavailable
    }

    func insertCourse(_ course: Course) throws {
        throw PlannerPersistenceError.storeUnavailable
    }

    func deleteCourse(_ course: Course) throws {
        throw PlannerPersistenceError.storeUnavailable
    }

    func updateCourse(_ course: Course) throws {
        throw PlannerPersistenceError.storeUnavailable
    }

    func updateAssignment(_ assignment: Assignment) throws {
        throw PlannerPersistenceError.storeUnavailable
    }

    func insertAssignment(_ assignment: Assignment) throws {
        throw PlannerPersistenceError.storeUnavailable
    }

    func setCompletion(_ isCompleted: Bool, forAssignmentID assignmentID: Assignment.ID) throws {
        throw PlannerPersistenceError.storeUnavailable
    }

    func deleteAssignment(_ assignment: Assignment) throws {
        throw PlannerPersistenceError.storeUnavailable
    }

    func markAddedToCalendar(assignmentID: Assignment.ID) throws {
        throw PlannerPersistenceError.storeUnavailable
    }

    func fetchProfile() throws -> UserProfile? {
        throw PlannerPersistenceError.storeUnavailable
    }

    func saveProfile(_ profile: UserProfile) throws {
        throw PlannerPersistenceError.storeUnavailable
    }

    func deleteAllData() throws {
        throw PlannerPersistenceError.storeUnavailable
    }
}
