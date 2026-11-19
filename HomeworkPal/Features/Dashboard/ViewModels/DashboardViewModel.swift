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

    @Published var isAddingAssignment = false
    /// The assignment Apple's Add Event sheet is open for. Drives the calendar sheet.
    @Published var assignmentToAddToCalendar: Assignment?

    /// A just-added assignment waiting for the New Assignment sheet to finish closing, since one sheet
    /// can't be presented while another is still dismissing.
    private var queuedCalendarAssignment: Assignment?

    private let planner: PlannerViewModel

    init(planner: PlannerViewModel) {
        self.planner = planner
        PlannerObservation.forwardChanges(from: planner, to: self)
    }

    var courses: [Course] {
        planner.courses
    }

    /// Open assignments grouped into time buckets, soonest first. Empty buckets are left out.
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

    /// No open work at all, so the dashboard shows its empty state.
    var isEmpty: Bool {
        sections.isEmpty
    }

    func markComplete(_ assignment: Assignment) {
        planner.markComplete(assignment)
    }

    func startAddingAssignment() {
        isAddingAssignment = true
    }

    func addAssignment(_ assignment: Assignment, addToCalendar: Bool) {
        planner.addAssignment(assignment)
        // Only offer the calendar if the assignment was actually saved; a failed save is reported by the planner.
        guard addToCalendar, planner.assignments.contains(where: { $0.id == assignment.id }) else { return }
        queuedCalendarAssignment = assignment
    }

    /// Opens Apple's Add Event sheet for the assignment queued by `addAssignment(_:addToCalendar:)`, if any.
    func presentQueuedCalendarEvent() {
        guard let queuedCalendarAssignment else { return }
        assignmentToAddToCalendar = queuedCalendarAssignment
        self.queuedCalendarAssignment = nil
    }

    func requestCalendarEvent(for assignment: Assignment) {
        assignmentToAddToCalendar = assignment
    }

    func markAddedToCalendar(_ assignment: Assignment) {
        planner.markAddedToCalendar(assignment)
    }
}
