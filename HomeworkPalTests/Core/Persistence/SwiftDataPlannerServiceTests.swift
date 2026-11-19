import Foundation
import SwiftData
import Testing
@testable import HomeworkPal

@MainActor
struct SwiftDataPlannerServiceTests {
    private let english = Course(name: "English", colorHex: "#0088FF")
    private let biology = Course(name: "Biology", colorHex: "#34C759")

    private func makeService() throws -> (SwiftDataPlannerService, ModelContainer) {
        let container = try SwiftDataPlannerService.makeContainer(isStoredInMemoryOnly: true)
        return (SwiftDataPlannerService(container: container), container)
    }

    @Test func savedDataIsLoadedByAFreshServiceOnTheSameStore() throws {
        let (service, container) = try makeService()
        let essay = Assignment(title: "Essay", course: english, dueDate: .now)

        try service.insertCourse(english)
        try service.insertAssignment(essay)

        // A new service over the same container stands in for relaunching the app.
        let relaunched = try SwiftDataPlannerService(container: container).fetchPlanner()
        #expect(relaunched.courses == [english])
        #expect(relaunched.assignments == [essay])
    }

    @Test func activityScheduleAndLocationSurviveARelaunch() throws {
        let (service, container) = try makeService()
        let soccer = Course(
            name: "Soccer",
            colorHex: "#4A9BA3",
            kind: .activity,
            schedule: CourseSchedule(
                weekdays: [.monday, .thursday],
                startMinutes: 930,
                endMinutes: 1020,
                repeatsUntil: Date(timeIntervalSince1970: 1_800_000_000)
            ),
            location: "North Field"
        )

        try service.insertCourse(soccer)

        let relaunched = try SwiftDataPlannerService(container: container).fetchPlanner()
        #expect(relaunched.courses == [soccer])
    }

    @Test func editsToCoursesAndAssignmentsAreSaved() throws {
        let (service, container) = try makeService()
        let essay = Assignment(title: "Essay", course: english, dueDate: .now)
        try service.insertCourse(english)
        try service.insertCourse(biology)
        try service.insertAssignment(essay)

        var renamed = english
        renamed.name = "English Lit"
        renamed.kind = .activity
        renamed.location = "Room 12"
        try service.updateCourse(renamed)

        var moved = essay
        moved.title = "Final essay"
        moved.dueDate = Date(timeIntervalSince1970: 1_800_000_000)
        moved.course = biology
        moved.notes = "Cite three sources"
        try service.updateAssignment(moved)

        let relaunched = try SwiftDataPlannerService(container: container).fetchPlanner()
        #expect(relaunched.courses == [renamed, biology])
        #expect(relaunched.assignments == [moved])
    }

    @Test func coursesLoadInTheOrderTheyWereAdded() throws {
        let (service, _) = try makeService()

        try service.insertCourse(english)
        try service.insertCourse(biology)

        #expect(try service.fetchPlanner().courses == [english, biology])
    }

    @Test func deletingACourseAlsoDeletesItsAssignments() throws {
        let (service, _) = try makeService()
        try service.insertCourse(english)
        try service.insertCourse(biology)
        try service.insertAssignment(Assignment(title: "Essay", course: english, dueDate: .now))
        let quiz = Assignment(title: "Quiz", course: biology, dueDate: .now)
        try service.insertAssignment(quiz)

        try service.deleteCourse(english)

        let snapshot = try service.fetchPlanner()
        #expect(snapshot.courses == [biology])
        #expect(snapshot.assignments == [quiz])
    }

    @Test func completionIsSaved() throws {
        let (service, _) = try makeService()
        let essay = Assignment(title: "Essay", course: english, dueDate: .now)
        try service.insertCourse(english)
        try service.insertAssignment(essay)

        try service.setCompletion(true, forAssignmentID: essay.id)

        let saved = try #require(try service.fetchPlanner().assignments.first)
        #expect(saved.isCompleted)
    }

    @Test func addedToCalendarIsSaved() throws {
        let (service, container) = try makeService()
        let essay = Assignment(title: "Essay", course: english, dueDate: .now)
        try service.insertCourse(english)
        try service.insertAssignment(essay)

        try service.markAddedToCalendar(assignmentID: essay.id)

        let relaunched = try SwiftDataPlannerService(container: container).fetchPlanner()
        let saved = try #require(relaunched.assignments.first)
        #expect(saved.isAddedToCalendar)
    }

    @Test func deleteAllDataRemovesEverything() throws {
        let (service, container) = try makeService()
        try service.insertCourse(english)
        try service.insertAssignment(Assignment(title: "Essay", course: english, dueDate: .now))

        try service.deleteAllData()

        let relaunched = try SwiftDataPlannerService(container: container).fetchPlanner()
        #expect(relaunched.courses.isEmpty)
        #expect(relaunched.assignments.isEmpty)
    }

    @Test func assignmentForUnknownCourseIsRejected() throws {
        let (service, _) = try makeService()

        #expect(throws: PlannerPersistenceError.courseNotFound) {
            try service.insertAssignment(Assignment(title: "Orphan", course: english, dueDate: .now))
        }
    }

    @Test func newStoreStartsEmpty() throws {
        let (service, _) = try makeService()

        let snapshot = try service.fetchPlanner()
        #expect(snapshot.courses.isEmpty)
        #expect(snapshot.assignments.isEmpty)
    }
}
