import Foundation

/// The contents of the Apple Calendar event created for an assignment.
struct CalendarEventDetails: Equatable, Sendable {
    let title: String
    let startDate: Date
    let endDate: Date
    let notes: String
}

extension Assignment {
    /// A due date is a moment, not a block of time, so the event starts and ends at the due date.
    var calendarEventDetails: CalendarEventDetails {
        CalendarEventDetails(
            title: String(localized: "\(title) (\(course.name))"),
            startDate: dueDate,
            endDate: dueDate,
            notes: String(localized: "Added by HomeworkPal")
        )
    }
}
