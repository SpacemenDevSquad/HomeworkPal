import Foundation
import Testing
@testable import HomeworkPal

@MainActor
struct DashboardViewModelTests {
    private let overdueAssignment = Assignment(title: "Overdue essay", course: .english, dueDate: .now.addingTimeInterval(-3_600))
    private let laterAssignment = Assignment(title: "Final project", course: .biology, dueDate: .now.addingTimeInterval(30 * 86_400))

    private func makeViewModel(assignments: [Assignment]) -> DashboardViewModel {
        DashboardViewModel(planner: PlannerViewModel(courses: Course.sampleData, assignments: assignments))
    }

    @Test func sectionsAreOrderedByUrgency() {
        let viewModel = makeViewModel(assignments: [laterAssignment, overdueAssignment])

        #expect(viewModel.sections.map(\.bucket) == [.overdue, .later])
    }

    @Test func emptyAssignmentsProduceEmptyState() {
        let viewModel = makeViewModel(assignments: [])

        #expect(viewModel.isEmpty)
    }

    @Test func requestCompletionSetsPendingAssignmentWithoutCompleting() {
        let viewModel = makeViewModel(assignments: [overdueAssignment])

        viewModel.requestCompletion(for: overdueAssignment)

        #expect(viewModel.pendingCompletion == overdueAssignment)
        #expect(viewModel.sections.flatMap(\.assignments) == [overdueAssignment])
    }

    @Test func markCompleteRemovesAssignmentFromSections() {
        let viewModel = makeViewModel(assignments: [overdueAssignment, laterAssignment])

        viewModel.markComplete(overdueAssignment)

        #expect(viewModel.sections.flatMap(\.assignments).map(\.id) == [laterAssignment.id])
    }

    @Test func addAssignmentAppearsInSections() {
        let viewModel = makeViewModel(assignments: [])

        viewModel.addAssignment(laterAssignment)

        #expect(viewModel.sections.flatMap(\.assignments) == [laterAssignment])
    }

    @Test func startAddingAssignmentPresentsSheet() {
        let viewModel = makeViewModel(assignments: [])

        viewModel.startAddingAssignment()

        #expect(viewModel.isAddingAssignment)
    }

    @Test func changesFromAnotherTabAppearInSections() {
        let planner = PlannerViewModel(courses: Course.sampleData, assignments: [overdueAssignment])
        let viewModel = DashboardViewModel(planner: planner)

        planner.markComplete(overdueAssignment)

        #expect(viewModel.isEmpty)
    }
}
