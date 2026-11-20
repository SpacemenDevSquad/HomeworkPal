import Foundation
import Testing
@testable import HomeworkPal

@MainActor
struct PlannerDeletionTests {
    private let essay = Assignment(title: "Essay", course: .english, dueDate: .now)
    private let quiz = Assignment(title: "Quiz", course: .biology, dueDate: .now)

    @Test func deleteAssignmentRemovesOnlyThatAssignment() {
        let planner = PlannerViewModel(courses: Course.sampleData, assignments: [essay, quiz])

        planner.deleteAssignment(essay)

        #expect(planner.assignments == [quiz])
    }

    @Test func deleteAssignmentIsSavedToPersistence() throws {
        let persistence = InMemoryPlannerService(courses: Course.sampleData, assignments: [essay, quiz])
        let planner = PlannerViewModel(persistence: persistence)
        planner.loadPlanner()

        planner.deleteAssignment(essay)

        #expect(try persistence.fetchPlanner().assignments == [quiz])
    }

    @Test func failedDeleteKeepsTheAssignmentAndReportsError() {
        let planner = PlannerViewModel(persistence: UnavailablePlannerService())

        planner.deleteAssignment(essay)

        #expect(planner.isShowingError)
    }

    @Test func swiftDataDeleteAssignmentPersists() throws {
        let container = try SwiftDataPlannerService.makeContainer(isStoredInMemoryOnly: true)
        let service = SwiftDataPlannerService(container: container)
        try service.insertCourse(.english)
        try service.insertAssignment(essay)

        try service.deleteAssignment(essay)

        let relaunched = try SwiftDataPlannerService(container: container).fetchPlanner()
        #expect(relaunched.assignments.isEmpty)
        #expect(relaunched.courses.map(\.id) == [Course.english.id])
    }

    @Test func courseDetailReportsDeletionAndCountsAssignments() {
        let planner = PlannerViewModel(courses: Course.sampleData, assignments: [essay, quiz])
        let viewModel = CourseDetailViewModel(planner: planner, course: .english)

        #expect(viewModel.totalAssignmentCount == 1)
        #expect(!viewModel.isCourseDeleted)

        viewModel.deleteCourse()

        #expect(viewModel.isCourseDeleted)
        #expect(planner.assignments == [quiz])
    }

    @Test func assignmentDetailReportsDeletion() {
        let planner = PlannerViewModel(courses: Course.sampleData, assignments: [essay])
        let viewModel = AssignmentDetailViewModel(planner: planner, assignmentID: essay.id)

        #expect(!viewModel.isAssignmentDeleted)

        viewModel.deleteAssignment()

        #expect(viewModel.isAssignmentDeleted)
        #expect(planner.assignments.isEmpty)
    }
}
