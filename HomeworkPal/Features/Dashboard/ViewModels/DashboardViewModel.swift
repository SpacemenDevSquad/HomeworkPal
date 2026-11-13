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

    @Published private(set) var assignments: [Assignment]
    @Published private(set) var courses: [Course]

    /// The assignment awaiting confirmation before it's checked off. Drives the confirmation alert.
    @Published var pendingCompletion: Assignment?
    @Published var isAddingAssignment = false

    init(assignments: [Assignment] = Assignment.sampleData, courses: [Course] = Course.sampleData) {
        self.assignments = assignments
        self.courses = courses
    }

    /// Open assignments grouped into time buckets, soonest first. Empty buckets are omitted.
    var sections: [Section] {
        let openAssignments = assignments
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
        guard let index = assignments.firstIndex(where: { $0.id == assignment.id }) else { return }
        assignments[index].isCompleted = true
    }

    func startAddingAssignment() {
        isAddingAssignment = true
    }

    func addAssignment(_ assignment: Assignment) {
        assignments.append(assignment)
    }
}
