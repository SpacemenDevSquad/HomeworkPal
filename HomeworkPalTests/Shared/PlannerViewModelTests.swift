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
}
