import Foundation

/// One day in the week view, with the open work due on it.
struct CalendarDay: Identifiable, Sendable {
    /// Three or more items is the point where a student's day starts to feel crowded.
    private static let busyThreshold = 3

    /// The start of the day. Each day in a week is unique, so this also serves as the identity.
    let date: Date
    /// Open assignments due on this day, soonest first.
    let assignments: [Assignment]
    let isToday: Bool

    var id: Date { date }

    var isEmpty: Bool {
        assignments.isEmpty
    }

    var isBusy: Bool {
        assignments.count >= Self.busyThreshold
    }

    /// The distinct classes and activities with work due, in due-date order, for the day's color dots.
    var courses: [Course] {
        var seenCourseIDs: Set<Course.ID> = []
        return assignments.map(\.course).filter { seenCourseIDs.insert($0.id).inserted }
    }
}
