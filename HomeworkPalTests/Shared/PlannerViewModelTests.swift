import Foundation
import Testing
@testable import HomeworkPal

@MainActor
struct PlannerViewModelTests {
    private let essay = Assignment(title: "Essay", course: .english, dueDate: .now)
    private let quiz = Assignment(title: "Quiz", course: .biology, dueDate: .now)

    @Test func assignmentsForCourseOnlyIncludesThatCourse() {
        let planner = PlannerViewModel(courses: Course.sampleData, assignments: [essay, quiz])

        #expect(planner.assignments(for: .english) == [essay])
    }

    @Test func markCompleteAndIncompleteToggleTheSameAssignment() throws {
        let planner = PlannerViewModel(courses: Course.sampleData, assignments: [essay])

        planner.markComplete(essay)
        let completed = try #require(planner.assignments.first)
        #expect(completed.isCompleted)

        planner.markIncomplete(essay)
        let reopened = try #require(planner.assignments.first)
        #expect(!reopened.isCompleted)
    }

    @Test func markAddedToCalendarIsSavedAndIdempotent() throws {
        let persistence = InMemoryPlannerService(courses: [.english], assignments: [essay])
        let planner = PlannerViewModel(persistence: persistence)
        planner.loadPlanner()

        planner.markAddedToCalendar(essay)
        planner.markAddedToCalendar(essay)

        #expect(planner.assignments.map(\.isAddedToCalendar) == [true])
        #expect(try persistence.fetchPlanner().assignments.map(\.isAddedToCalendar) == [true])
    }

    @Test func markAddedToCalendarIgnoresUnknownAssignment() {
        let planner = PlannerViewModel(courses: Course.sampleData, assignments: [essay])

        planner.markAddedToCalendar(quiz)

        #expect(planner.assignments == [essay])
    }

    @Test func addCourseAppendsIt() {
        let planner = PlannerViewModel(courses: [], assignments: [])
        let robotics = Course(name: "Robotics", colorHex: "#6155F5")

        planner.addCourse(robotics)

        #expect(planner.courses == [robotics])
    }

    @Test func deleteCourseAlsoDeletesItsAssignments() {
        let planner = PlannerViewModel(courses: [.english, .biology], assignments: [essay, quiz])

        planner.deleteCourse(.english)

        #expect(planner.courses == [.biology])
        #expect(planner.assignments == [quiz])
    }

    @Test func startsEmptyUntilLoaded() {
        let planner = PlannerViewModel(persistence: InMemoryPlannerService(courses: [.english], assignments: [essay]))

        #expect(planner.courses.isEmpty)

        planner.loadPlanner()

        #expect(planner.courses == [.english])
        #expect(planner.assignments == [essay])
    }

    @Test func changesAreWrittenToPersistence() throws {
        let persistence = InMemoryPlannerService()
        let planner = PlannerViewModel(persistence: persistence)

        planner.addCourse(.english)
        planner.addAssignment(essay)
        planner.markComplete(essay)

        let saved = try persistence.fetchPlanner()
        #expect(saved.courses == [.english])
        #expect(saved.assignments.map(\.isCompleted) == [true])
    }

    @Test func failedSaveLeavesDataUnchangedAndReportsError() {
        let planner = PlannerViewModel(persistence: UnavailablePlannerService())

        planner.addCourse(.english)

        #expect(planner.courses.isEmpty)
        #expect(planner.isShowingError)
        #expect(planner.errorMessage == PlannerPersistenceError.storeUnavailable.errorDescription)
    }

    @Test func dismissingTheErrorClearsIt() {
        let planner = PlannerViewModel(persistence: UnavailablePlannerService())
        planner.loadPlanner()

        planner.isShowingError = false

        #expect(planner.errorMessage == nil)
    }
}
