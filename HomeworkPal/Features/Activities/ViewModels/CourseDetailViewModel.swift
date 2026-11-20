import Combine
import Foundation

@MainActor
final class CourseDetailViewModel: ObservableObject {
    @Published var isEditing = false

    /// The course as it was when the screen opened, used if it's deleted while still on screen.
    private let initialCourse: Course

    private let planner: PlannerViewModel
    /// Read on demand rather than stored, so overdue status stays correct while the screen is open.
    private let currentDate: () -> Date

    init(planner: PlannerViewModel, course: Course, currentDate: @escaping () -> Date = { .now }) {
        self.planner = planner
        self.initialCourse = course
        self.currentDate = currentDate
        PlannerObservation.forwardChanges(from: planner, to: self)
    }

    /// The live course, so edits show up on this screen right away.
    var course: Course {
        planner.course(withID: initialCourse.id) ?? initialCourse
    }

    /// Every class and activity, for checking an edited name against the others.
    var allCourses: [Course] {
        planner.courses
    }

    func startEditing() {
        isEditing = true
    }

    func save(_ course: Course) {
        planner.updateCourse(course)
    }

    /// Deletes the course and its assignments.
    func deleteCourse() {
        planner.deleteCourse(course)
    }

    /// `true` once the course has been deleted, so the screen knows to close.
    var isCourseDeleted: Bool {
        planner.course(withID: initialCourse.id) == nil
    }

    /// Every assignment deleting this course would remove, open or completed, for the warning.
    var totalAssignmentCount: Int {
        planner.assignments(for: course).count
    }

    /// Assignments in the Upcoming section, soonest first.
    var openAssignments: [Assignment] {
        planner.assignments(for: course)
            .filter { !isPlacedInCompleted($0) }
            .sorted { $0.dueDate < $1.dueDate }
    }

    /// Assignments in the Completed section, most recently due first, so finished work stays findable.
    var completedAssignments: [Assignment] {
        planner.assignments(for: course)
            .filter(isPlacedInCompleted)
            .sorted { $0.dueDate > $1.dueDate }
    }

    /// The section each assignment was in when this screen first showed it, keyed by id.
    ///
    /// Checking or unchecking keeps a row where it is instead of moving it out from under the student's
    /// finger; the sections re-sort the next time the screen opens. New assignments are placed by status.
    private var placements: [Assignment.ID: Bool] = [:]

    private func isPlacedInCompleted(_ assignment: Assignment) -> Bool {
        if let placedInCompleted = placements[assignment.id] {
            return placedInCompleted
        }
        placements[assignment.id] = assignment.isCompleted
        return assignment.isCompleted
    }

    var isEmpty: Bool {
        planner.assignments(for: course).isEmpty
    }

    func isOverdue(_ assignment: Assignment) -> Bool {
        !assignment.isCompleted && DueBucket.bucket(for: assignment.dueDate, now: currentDate()) == .overdue
    }

    /// Flips the assignment between open and completed. The row shows the checkmark before this runs.
    func toggleCompletion(of assignment: Assignment) {
        if assignment.isCompleted {
            planner.markIncomplete(assignment)
        } else {
            planner.markComplete(assignment)
        }
    }

    func markComplete(_ assignment: Assignment) {
        planner.markComplete(assignment)
    }
}
