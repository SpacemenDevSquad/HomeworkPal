import Foundation
import Testing
@testable import HomeworkPal

/// Rows on a class's screen stay in the section they were shown in, so checking or unchecking an
/// assignment never moves it out from under the student's finger.
@MainActor
struct CourseDetailPlacementTests {
    private let essay = Assignment(title: "Essay", course: .english, dueDate: .now.addingTimeInterval(3_600))
    private let poem = Assignment(title: "Poem", course: .english, dueDate: .now, isCompleted: true)

    private func makeViewModel(planner: PlannerViewModel) -> CourseDetailViewModel {
        CourseDetailViewModel(planner: planner, course: .english)
    }

    @Test func checkingOffKeepsTheRowInUpcomingWithItsCheckmark() {
        let planner = PlannerViewModel(courses: [.english], assignments: [essay])
        let viewModel = makeViewModel(planner: planner)
        #expect(viewModel.openAssignments.map(\.id) == [essay.id])

        viewModel.toggleCompletion(of: essay)

        #expect(viewModel.openAssignments.map(\.id) == [essay.id])
        #expect(viewModel.openAssignments.map(\.isCompleted) == [true])
        #expect(viewModel.completedAssignments.isEmpty)
    }

    @Test func uncheckingKeepsTheRowInCompletedWithoutItsCheckmark() {
        let planner = PlannerViewModel(courses: [.english], assignments: [poem])
        let viewModel = makeViewModel(planner: planner)
        #expect(viewModel.completedAssignments.map(\.id) == [poem.id])

        viewModel.toggleCompletion(of: poem)

        #expect(viewModel.completedAssignments.map(\.id) == [poem.id])
        #expect(viewModel.completedAssignments.map(\.isCompleted) == [false])
        #expect(planner.assignments.map(\.isCompleted) == [false])
    }

    @Test func reopeningTheScreenSortsBySavedStatus() {
        let planner = PlannerViewModel(courses: [.english], assignments: [essay])
        let firstVisit = makeViewModel(planner: planner)
        _ = firstVisit.openAssignments
        firstVisit.toggleCompletion(of: essay)

        let nextVisit = makeViewModel(planner: planner)

        #expect(nextVisit.openAssignments.isEmpty)
        #expect(nextVisit.completedAssignments.map(\.id) == [essay.id])
    }

    @Test func assignmentsAddedWhileOpenArePlacedByStatus() {
        let planner = PlannerViewModel(courses: [.english], assignments: [essay])
        let viewModel = makeViewModel(planner: planner)
        _ = viewModel.openAssignments

        planner.addAssignment(poem)

        #expect(viewModel.completedAssignments.map(\.id) == [poem.id])
    }
}
