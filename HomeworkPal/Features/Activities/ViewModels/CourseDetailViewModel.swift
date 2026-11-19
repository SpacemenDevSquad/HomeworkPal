import Combine
import Foundation

@MainActor
final class CourseDetailViewModel: ObservableObject {
    /// The assignment awaiting confirmation before it's checked off. Drives the confirmation alert.
    @Published var pendingCompletion: Assignment?

    let course: Course

    private let planner: PlannerViewModel
    /// Read on demand rather than stored, so overdue status stays correct while the screen is open.
    private let currentDate: () -> Date

    init(planner: PlannerViewModel, course: Course, currentDate: @escaping () -> Date = { .now }) {
        self.planner = planner
        self.course = course
        self.currentDate = currentDate
    }

    /// Open assignments, soonest first.
    var openAssignments: [Assignment] {
        planner.assignments(for: course)
            .filter { !$0.isCompleted }
            .sorted { $0.dueDate < $1.dueDate }
    }

    /// Checked-off assignments, most recently due first, so finished work stays findable.
    var completedAssignments: [Assignment] {
        planner.assignments(for: course)
            .filter(\.isCompleted)
            .sorted { $0.dueDate > $1.dueDate }
    }

    var isEmpty: Bool {
        planner.assignments(for: course).isEmpty
    }

    func isOverdue(_ assignment: Assignment) -> Bool {
        !assignment.isCompleted && DueBucket.bucket(for: assignment.dueDate, now: currentDate()) == .overdue
    }

    /// Completing asks for confirmation; un-checking a completed item is an undo, so it happens right away.
    func toggleCompletion(of assignment: Assignment) {
        if assignment.isCompleted {
            planner.markIncomplete(assignment)
        } else {
            pendingCompletion = assignment
        }
    }

    func markComplete(_ assignment: Assignment) {
        planner.markComplete(assignment)
    }
}
