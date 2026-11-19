import Foundation

/// A day of the week. Raw values match `Calendar`'s weekday numbering, where Sunday is 1.
nonisolated enum Weekday: Int, CaseIterable, Codable, Sendable, Identifiable, Comparable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday

    var id: Int { rawValue }

    /// Monday first, the way a student reads a school week.
    static let mondayFirst: [Weekday] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    static let schoolDays: Set<Weekday> = [.monday, .tuesday, .wednesday, .thursday, .friday]
    static let weekend: Set<Weekday> = [.saturday, .sunday]

    static func < (lhs: Weekday, rhs: Weekday) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    /// One letter, such as "M", for the day bubbles.
    func veryShortSymbol(in calendar: Calendar = .current) -> String {
        calendar.veryShortWeekdaySymbols[rawValue - 1]
    }

    /// Abbreviated, such as "Mon", for schedule summaries.
    func shortSymbol(in calendar: Calendar = .current) -> String {
        calendar.shortWeekdaySymbols[rawValue - 1]
    }

    /// Full name, such as "Monday", for VoiceOver.
    func fullSymbol(in calendar: Calendar = .current) -> String {
        calendar.weekdaySymbols[rawValue - 1]
    }
}

/// When a class or activity meets: which days, from when to when, and until what date.
nonisolated struct CourseSchedule: Hashable, Codable, Sendable {
    static let minutesPerHour = 60

    var weekdays: Set<Weekday>
    /// Minutes after midnight, so the time stays the same in any time zone.
    var startMinutes: Int
    var endMinutes: Int
    /// The last day it repeats on.
    var repeatsUntil: Date

    /// The meeting days in a short form: "Every day", "Weekdays", "Weekends", or a list like "Mon, Wed, Fri".
    func daysDescription(calendar: Calendar = .current) -> String {
        switch weekdays {
        case Set(Weekday.allCases):
            return String(localized: "Every day")
        case Weekday.schoolDays:
            return String(localized: "Weekdays")
        case Weekday.weekend:
            return String(localized: "Weekends")
        default:
            return Weekday.mondayFirst
                .filter(weekdays.contains)
                .map { $0.shortSymbol(in: calendar) }
                .joined(separator: ", ")
        }
    }

    /// The start and end times placed on `day`, for formatting as a time range.
    func timeRange(on day: Date = .now, calendar: Calendar = .current) -> Range<Date> {
        let startOfDay = calendar.startOfDay(for: day)
        let start = calendar.date(byAdding: .minute, value: startMinutes, to: startOfDay) ?? startOfDay
        let end = calendar.date(byAdding: .minute, value: endMinutes, to: startOfDay) ?? start
        return start..<max(start, end)
    }
}
