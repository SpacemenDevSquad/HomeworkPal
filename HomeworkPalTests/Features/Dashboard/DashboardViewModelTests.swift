import Foundation
import Testing
@testable import HomeworkPal

@MainActor
struct DashboardViewModelTests {
    private let overdueAssignment = Assignment(title: "Overdue essay", course: .english, dueDate: .now.addingTimeInterval(-3_600))
    private let laterAssignment = Assignment(title: "Final project", course: .biology, dueDate: .now.addingTimeInterval(30 * 86_400))

    @Test func sectionsAreOrderedByUrgency() {
        let viewModel = DashboardViewModel(assignments: [laterAssignment, overdueAssignment], courses: Course.sampleData)

        #expect(viewModel.sections.map(\.bucket) == [.overdue, .later])
    }

    @Test func emptyAssignmentsProduceEmptyState() {
        let viewModel = DashboardViewModel(assignments: [], courses: Course.sampleData)

        #expect(viewModel.isEmpty)
    }

    @Test func requestCompletionSetsPendingAssignmentWithoutCompleting() {
        let viewModel = DashboardViewModel(assignments: [overdueAssignment], courses: Course.sampleData)

        viewModel.requestCompletion(for: overdueAssignment)

        #expect(viewModel.pendingCompletion == overdueAssignment)
        #expect(viewModel.sections.flatMap(\.assignments) == [overdueAssignment])
    }

    @Test func markCompleteRemovesAssignmentFromSections() {
        let viewModel = DashboardViewModel(assignments: [overdueAssignment, laterAssignment], courses: Course.sampleData)

        viewModel.markComplete(overdueAssignment)

        #expect(viewModel.sections.flatMap(\.assignments).map(\.id) == [laterAssignment.id])
    }

    @Test func addAssignmentAppearsInSections() {
        let viewModel = DashboardViewModel(assignments: [], courses: Course.sampleData)

        viewModel.addAssignment(laterAssignment, addToCalendar: false)

        #expect(viewModel.sections.flatMap(\.assignments) == [laterAssignment])
    }

    @Test func startAddingAssignmentPresentsSheet() {
        let viewModel = DashboardViewModel(assignments: [], courses: Course.sampleData)

        viewModel.startAddingAssignment()

        #expect(viewModel.isAddingAssignment)
    }

    @Test func showCalendarPresentsCalendar() {
        let viewModel = DashboardViewModel(assignments: [], courses: Course.sampleData)

        viewModel.showCalendar()

        #expect(viewModel.isShowingCalendar)
    }

    @Test func addingWithCalendarQueuesUntilFormDismisses() {
        let viewModel = DashboardViewModel(assignments: [], courses: Course.sampleData)

        viewModel.addAssignment(laterAssignment, addToCalendar: true)
        #expect(viewModel.assignmentToAddToCalendar == nil)

        viewModel.presentQueuedCalendarEvent()
        #expect(viewModel.assignmentToAddToCalendar == laterAssignment)
    }

    @Test func addingWithoutCalendarQueuesNothing() {
        let viewModel = DashboardViewModel(assignments: [], courses: Course.sampleData)

        viewModel.addAssignment(laterAssignment, addToCalendar: false)
        viewModel.presentQueuedCalendarEvent()

        #expect(viewModel.assignmentToAddToCalendar == nil)
    }

    @Test func presentQueuedCalendarEventWithNothingQueuedDoesNothing() {
        let viewModel = DashboardViewModel(assignments: [], courses: Course.sampleData)

        viewModel.presentQueuedCalendarEvent()

        #expect(viewModel.assignmentToAddToCalendar == nil)
    }

    @Test func presentQueuedCalendarEventClearsQueue() {
        let viewModel = DashboardViewModel(assignments: [], courses: Course.sampleData)
        viewModel.addAssignment(laterAssignment, addToCalendar: true)

        viewModel.presentQueuedCalendarEvent()
        viewModel.assignmentToAddToCalendar = nil
        viewModel.presentQueuedCalendarEvent()

        #expect(viewModel.assignmentToAddToCalendar == nil)
    }

    @Test func requestCalendarEventSetsAssignment() {
        let viewModel = DashboardViewModel(assignments: [overdueAssignment], courses: Course.sampleData)

        viewModel.requestCalendarEvent(for: overdueAssignment)

        #expect(viewModel.assignmentToAddToCalendar == overdueAssignment)
    }

    @Test func markAddedToCalendarSetsFlag() {
        let viewModel = DashboardViewModel(assignments: [overdueAssignment], courses: Course.sampleData)

        viewModel.markAddedToCalendar(overdueAssignment)

        #expect(viewModel.assignments.first?.isAddedToCalendar == true)
    }

    @Test func markAddedToCalendarIsIdempotent() {
        let viewModel = DashboardViewModel(assignments: [overdueAssignment], courses: Course.sampleData)

        viewModel.markAddedToCalendar(overdueAssignment)
        viewModel.markAddedToCalendar(overdueAssignment)

        #expect(viewModel.assignments.count == 1)
        #expect(viewModel.assignments.first?.isAddedToCalendar == true)
    }

    @Test func markAddedToCalendarIgnoresUnknownAssignment() {
        let viewModel = DashboardViewModel(assignments: [overdueAssignment], courses: Course.sampleData)

        viewModel.markAddedToCalendar(laterAssignment)

        #expect(viewModel.assignments == [overdueAssignment])
    }
}
