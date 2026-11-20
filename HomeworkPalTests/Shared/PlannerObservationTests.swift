import Combine
import Foundation
import Testing
@testable import HomeworkPal

@MainActor
struct PlannerObservationTests {
    /// Waits for the forwarded change, which is announced on the next main-actor turn.
    private func settle() async {
        for _ in 0..<5 { await Task.yield() }
    }

    @Test func completingAnAssignmentRedrawsTheCourseScreen() async {
        let essay = Assignment(title: "Essay", course: .english, dueDate: .now.addingTimeInterval(3_600))
        let planner = PlannerViewModel(courses: [.english], assignments: [essay])
        let viewModel = CourseDetailViewModel(planner: planner, course: .english)
        var changeCount = 0
        let subscription = viewModel.objectWillChange.sink { changeCount += 1 }

        viewModel.toggleCompletion(of: essay)
        await settle()
        #expect(changeCount == 1)

        // Keeps watching after the first change, so unchecking redraws too.
        viewModel.toggleCompletion(of: viewModel.completedAssignments[0])
        await settle()
        #expect(changeCount == 2)
        // The row stays in place while the screen is open, now showing as not completed.
        #expect(viewModel.completedAssignments.map(\.isCompleted) == [false])
        subscription.cancel()
    }

    @Test func completingAnAssignmentRedrawsTheDashboard() async {
        let essay = Assignment(title: "Essay", course: .english, dueDate: .now.addingTimeInterval(3_600))
        let planner = PlannerViewModel(courses: [.english], assignments: [essay])
        let viewModel = DashboardViewModel(planner: planner)
        var changeCount = 0
        let subscription = viewModel.objectWillChange.sink { changeCount += 1 }

        viewModel.markComplete(essay)
        await settle()

        #expect(changeCount == 1)
        #expect(viewModel.isEmpty)
        subscription.cancel()
    }
}
