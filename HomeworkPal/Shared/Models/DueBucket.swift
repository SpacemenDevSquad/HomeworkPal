import Foundation

/// Time buckets used to group upcoming work by urgency.
enum DueBucket: Int, CaseIterable, Identifiable, Sendable {
    case overdue, today, tomorrow, thisWeek, later

    private static let daysInWeek = 7

    var id: Int { rawValue }

    var title: LocalizedStringResource {
        switch self {
        case .overdue: "Overdue"
        case .today: "Today"
        case .tomorrow: "Tomorrow"
        case .thisWeek: "This Week"
        case .later: "Later"
        }
    }

    /// Determines which bucket a due date falls into relative to `now`.
    static func bucket(for dueDate: Date, now: Date = .now, calendar: Calendar = .current) -> DueBucket {
        if dueDate < now { return .overdue }
        if calendar.isDate(dueDate, inSameDayAs: now) { return .today }

        // Compare against `now` rather than `isDateInTomorrow`, which always uses the real current date.
        let startOfToday = calendar.startOfDay(for: now)
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: startOfToday),
           calendar.isDate(dueDate, inSameDayAs: tomorrow) {
            return .tomorrow
        }
        if let weekEnd = calendar.date(byAdding: .day, value: daysInWeek, to: startOfToday), dueDate < weekEnd {
            return .thisWeek
        }
        return .later
    }
}
