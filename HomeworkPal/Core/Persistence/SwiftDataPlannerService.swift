import Foundation
import OSLog
import SwiftData

/// Stores the planner on the device with SwiftData.
final class SwiftDataPlannerService: PlannerPersistenceService {
    /// Held strongly because a `ModelContext` only references its container weakly; without this the
    /// container is freed right after `init` and the first fetch crashes.
    private let container: ModelContainer
    private let context: ModelContext

    init(container: ModelContainer) {
        self.container = container
        context = container.mainContext
    }

    /// - Parameter isStoredInMemoryOnly: Pass `true` for tests, so nothing is written to disk.
    static func makeContainer(isStoredInMemoryOnly: Bool = false) throws -> ModelContainer {
        let schema = Schema([CourseRecord.self, AssignmentRecord.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isStoredInMemoryOnly)
        return try ModelContainer(for: schema, configurations: configuration)
    }

    func fetchPlanner() throws -> PlannerSnapshot {
        do {
            let courseRecords = try context.fetch(FetchDescriptor<CourseRecord>(sortBy: [SortDescriptor(\.createdAt)]))
            let assignmentRecords = try context.fetch(FetchDescriptor<AssignmentRecord>())
            return PlannerSnapshot(
                courses: courseRecords.map(\.course),
                assignments: assignmentRecords.compactMap(\.assignment)
            )
        } catch {
            Logger.persistence.error("Fetching the planner failed: \(error.localizedDescription, privacy: .private)")
            throw PlannerPersistenceError.loadFailed
        }
    }

    func insertCourse(_ course: Course) throws {
        context.insert(CourseRecord(course))
        try save()
    }

    func deleteCourse(_ course: Course) throws {
        guard let record = try courseRecord(withID: course.id) else { return }
        context.delete(record)
        try save()
    }

    func updateCourse(_ course: Course) throws {
        guard let record = try courseRecord(withID: course.id) else {
            throw PlannerPersistenceError.courseNotFound
        }
        record.apply(course)
        try save()
    }

    func updateAssignment(_ assignment: Assignment) throws {
        guard let courseRecord = try courseRecord(withID: assignment.course.id) else {
            throw PlannerPersistenceError.courseNotFound
        }
        guard let record = try assignmentRecord(withID: assignment.id) else { return }
        record.apply(assignment, course: courseRecord)
        try save()
    }

    func insertAssignment(_ assignment: Assignment) throws {
        guard let courseRecord = try courseRecord(withID: assignment.course.id) else {
            throw PlannerPersistenceError.courseNotFound
        }
        context.insert(AssignmentRecord(assignment, course: courseRecord))
        try save()
    }

    func setCompletion(_ isCompleted: Bool, forAssignmentID assignmentID: Assignment.ID) throws {
        guard let record = try assignmentRecord(withID: assignmentID) else { return }
        record.isCompleted = isCompleted
        try save()
    }

    func deleteAssignment(_ assignment: Assignment) throws {
        guard let record = try assignmentRecord(withID: assignment.id) else { return }
        context.delete(record)
        try save()
    }

    func markAddedToCalendar(assignmentID: Assignment.ID) throws {
        guard let record = try assignmentRecord(withID: assignmentID) else { return }
        record.isAddedToCalendar = true
        try save()
    }

    private func assignmentRecord(withID assignmentID: Assignment.ID) throws -> AssignmentRecord? {
        var descriptor = FetchDescriptor<AssignmentRecord>(predicate: #Predicate { $0.id == assignmentID })
        descriptor.fetchLimit = 1
        return try fetch(descriptor).first
    }

    func deleteAllData() throws {
        do {
            try context.delete(model: AssignmentRecord.self)
            try context.delete(model: CourseRecord.self)
        } catch {
            Logger.persistence.error("Deleting all planner data failed: \(error.localizedDescription, privacy: .private)")
            context.rollback()
            throw PlannerPersistenceError.saveFailed
        }
        try save()
    }

    private func courseRecord(withID courseID: Course.ID) throws -> CourseRecord? {
        var descriptor = FetchDescriptor<CourseRecord>(predicate: #Predicate { $0.id == courseID })
        descriptor.fetchLimit = 1
        return try fetch(descriptor).first
    }

    private func fetch<Record: PersistentModel>(_ descriptor: FetchDescriptor<Record>) throws -> [Record] {
        do {
            return try context.fetch(descriptor)
        } catch {
            Logger.persistence.error("Fetching a record failed: \(error.localizedDescription, privacy: .private)")
            throw PlannerPersistenceError.loadFailed
        }
    }

    /// Saves pending changes, discarding them if the save fails so memory and disk stay in step.
    private func save() throws {
        do {
            try context.save()
        } catch {
            Logger.persistence.error("Saving the planner failed: \(error.localizedDescription, privacy: .private)")
            context.rollback()
            throw PlannerPersistenceError.saveFailed
        }
    }
}
