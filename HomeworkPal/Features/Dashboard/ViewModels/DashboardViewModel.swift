import Combine
import Foundation

@MainActor
final class DashboardViewModel: ObservableObject {
    /// A group of assignments that share a due bucket.
    struct Section: Identifiable {
        let bucket: DueBucket
        let assignments: [Assignment]

        var id: DueBucket { bucket }
    }

    /// The assignment awaiting confirmation before it's checked off. Drives the confirmation alert.
    @Published var pendingCompletion: Assignment?
    @Published var isAddingAssignment = false

    private let planner: PlannerViewModel

    init(planner: PlannerViewModel) {
        self.planner = planner
    }

    var courses: [Course] {
        planner.courses
    }

    /// Open assignments grouped into time buckets, soonest first. Empty buckets are omitted.
    var sections: [Section] {
        let openAssignments = planner.assignments
            .filter { !$0.isCompleted }
            .sorted { $0.dueDate < $1.dueDate }
        let assignmentsByBucket = Dictionary(grouping: openAssignments) { DueBucket.bucket(for: $0.dueDate) }

        return DueBucket.allCases.compactMap { bucket in
            guard let bucketAssignments = assignmentsByBucket[bucket] else { return nil }
            return Section(bucket: bucket, assignments: bucketAssignments)
        }
    }

    var isEmpty: Bool {
        sections.isEmpty
    }

    /// Asks the user to confirm before checking the assignment off.
    func requestCompletion(for assignment: Assignment) {
        pendingCompletion = assignment
    }

    func markComplete(_ assignment: Assignment) {
        planner.markComplete(assignment)
    }

    func startAddingAssignment() {
        isAddingAssignment = true
    }

    func addAssignment(_ assignment: Assignment) {
        planner.addAssignment(assignment)
    }
}
