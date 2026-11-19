import Foundation
import Testing
@testable import HomeworkPal

@MainActor
struct CourseDetailViewModelTests {
    private let now = Date(timeIntervalSinceReferenceDate: 800_000_000)

    private func makeViewModel(assignments: [Assignment]) -> (CourseDetailViewModel, PlannerViewModel) {
        let planner = PlannerViewModel(courses: Course.sampleData, assignments: assignments)
        let fixedNow = now
        return (CourseDetailViewModel(planner: planner, course: .english, currentDate: { fixedNow }), planner)
    }

    @Test func splitsOpenAndCompletedWorkForThisCourseOnly() {
        let later = Assignment(title: "Later", course: .english, dueDate: now.addingTimeInterval(7_200))
        let sooner = Assignment(title: "Sooner", course: .english, dueDate: now.addingTimeInterval(3_600))
        let finished = Assignment(title: "Finished", course: .english, dueDate: now, isCompleted: true)
        let otherCourse = Assignment(title: "Other", course: .biology, dueDate: now)
        let (viewModel, _) = makeViewModel(assignments: [later, sooner, finished, otherCourse])

        #expect(viewModel.openAssignments == [sooner, later])
        #expect(viewModel.completedAssignments == [finished])
    }

    @Test func checkingOffAsksForConfirmation() {
        let essay = Assignment(title: "Essay", course: .english, dueDate: now.addingTimeInterval(3_600))
        let (viewModel, planner) = makeViewModel(assignments: [essay])

        viewModel.toggleCompletion(of: essay)

        #expect(viewModel.pendingCompletion == essay)
        #expect(planner.assignments.allSatisfy { !$0.isCompleted })
    }

    @Test func uncheckingCompletedWorkHappensImmediately() {
        let finished = Assignment(title: "Finished", course: .english, dueDate: now, isCompleted: true)
        let (viewModel, _) = makeViewModel(assignments: [finished])

        viewModel.toggleCompletion(of: finished)

        #expect(viewModel.pendingCompletion == nil)
        #expect(viewModel.completedAssignments.isEmpty)
        #expect(viewModel.openAssignments.map(\.id) == [finished.id])
    }

    @Test func completedWorkIsNeverOverdue() {
        let pastDue = Assignment(title: "Late", course: .english, dueDate: now.addingTimeInterval(-3_600))
        let pastDueFinished = Assignment(title: "Done", course: .english, dueDate: now.addingTimeInterval(-3_600), isCompleted: true)
        let (viewModel, _) = makeViewModel(assignments: [pastDue, pastDueFinished])

        #expect(viewModel.isOverdue(pastDue))
        #expect(!viewModel.isOverdue(pastDueFinished))
    }

    @Test func courseWithNoWorkIsEmpty() {
        let (viewModel, _) = makeViewModel(assignments: [])

        #expect(viewModel.isEmpty)
    }
}
