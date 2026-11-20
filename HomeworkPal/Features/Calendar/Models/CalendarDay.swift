import Foundation

/// One day in the week strip, with everything due on it.
struct CalendarDay: Identifiable, Sendable {
    /// Three or more items is the point where a student's day starts to feel crowded.
    private static let busyThreshold = 3

    /// The start of the day. Each day in a week is unique, so this also serves as the identity.
    let date: Date
    /// Every assignment due on this day, completed ones included, soonest first.
    /// Completed work stays listed so the day's count doesn't shift as the student checks things off.
    let assignments: [Assignment]
    let isToday: Bool

    var id: Date { date }

    var isEmpty: Bool {
        assignments.isEmpty
    }

    var isBusy: Bool {
        assignments.count >= Self.busyThreshold
    }

    /// Open assignments that "Add All to Calendar" would still add, so finished or already-added ones are skipped.
    var assignmentsNotAddedToCalendar: [Assignment] {
        assignments.filter { !$0.isCompleted && !$0.isAddedToCalendar }
    }
}
