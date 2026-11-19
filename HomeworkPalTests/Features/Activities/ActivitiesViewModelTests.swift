import Foundation
import Testing
@testable import HomeworkPal

@MainActor
struct ActivitiesViewModelTests {
    private let openEssay = Assignment(title: "Essay", course: .english, dueDate: .now)
    private let finishedReading = Assignment(title: "Reading", course: .english, dueDate: .now, isCompleted: true)

    private func makeViewModel() -> ActivitiesViewModel {
        ActivitiesViewModel(planner: PlannerViewModel(courses: [.english, .biology], assignments: [openEssay, finishedReading]))
    }

    @Test func openCountExcludesCompletedWorkButTotalIncludesIt() {
        let viewModel = makeViewModel()

        #expect(viewModel.openAssignmentCount(for: .english) == 1)
        #expect(viewModel.totalAssignmentCount(for: .english) == 2)
        #expect(viewModel.openAssignmentCount(for: .biology) == 0)
    }

    @Test func requestDeletionWaitsForConfirmation() {
        let viewModel = makeViewModel()

        viewModel.requestDeletion(of: .english)

        #expect(viewModel.pendingDeletion == .english)
        #expect(viewModel.courses == [.english, .biology])
    }

    @Test func deleteCourseRemovesIt() {
        let viewModel = makeViewModel()

        viewModel.deleteCourse(.english)

        #expect(viewModel.courses == [.biology])
    }

    @Test func addCourseAppearsInList() {
        let viewModel = makeViewModel()
        let robotics = Course(name: "Robotics", colorHex: "#6155F5")

        viewModel.addCourse(robotics)

        #expect(viewModel.courses.last == robotics)
    }

    @Test func noCoursesShowsEmptyState() {
        let viewModel = ActivitiesViewModel(planner: PlannerViewModel(courses: [], assignments: []))

        #expect(viewModel.isEmpty)
    }
}
