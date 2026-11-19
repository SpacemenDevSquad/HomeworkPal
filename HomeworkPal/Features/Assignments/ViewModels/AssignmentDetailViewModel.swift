import Combine
import Foundation

@MainActor
final class AssignmentDetailViewModel: ObservableObject {
    @Published var isEditing = false

    let assignmentID: Assignment.ID

    private let planner: PlannerViewModel
    /// Read on demand rather than stored, so overdue status stays correct while the screen is open.
    private let currentDate: () -> Date

    init(planner: PlannerViewModel, assignmentID: Assignment.ID, currentDate: @escaping () -> Date = { .now }) {
        self.planner = planner
        self.assignmentID = assignmentID
        self.currentDate = currentDate
        PlannerObservation.forwardChanges(from: planner, to: self)
    }

    /// The live assignment, so edits made here or elsewhere show up right away. `nil` once it's deleted.
    var assignment: Assignment? {
        planner.assignment(withID: assignmentID)
    }

    /// Every class and activity, for moving the assignment to another one while editing.
    var courses: [Course] {
        planner.courses
    }

    var isOverdue: Bool {
        guard let assignment, !assignment.isCompleted else { return false }
        return DueBucket.bucket(for: assignment.dueDate, now: currentDate()) == .overdue
    }

    func startEditing() {
        isEditing = true
    }

    func save(_ assignment: Assignment) {
        planner.updateAssignment(assignment)
    }

    /// On its own screen the button says exactly what it does, so no confirmation is needed.
    func toggleCompletion() {
        guard let assignment else { return }
        if assignment.isCompleted {
            planner.markIncomplete(assignment)
        } else {
            planner.markComplete(assignment)
        }
    }
}
