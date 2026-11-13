import Foundation
import Testing
@testable import HomeworkPal

@MainActor
struct DueBucketTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        return calendar
    }()

    /// Thursday, Nov 12, 2026 at noon GMT.
    private var now: Date {
        calendar.date(from: DateComponents(year: 2026, month: 11, day: 12, hour: 12)) ?? .distantPast
    }

    private func date(daysFromNow days: Int, hour: Int) -> Date {
        let day = calendar.date(byAdding: .day, value: days, to: now) ?? now
        return calendar.date(bySettingHour: hour, minute: 0, second: 0, of: day) ?? day
    }

    @Test(arguments: [
        (-1, 9, DueBucket.overdue),
        (0, 8, DueBucket.overdue),
        (0, 18, DueBucket.today),
        (1, 9, DueBucket.tomorrow),
        (3, 9, DueBucket.thisWeek),
        (6, 23, DueBucket.thisWeek),
        (7, 0, DueBucket.later),
        (30, 9, DueBucket.later)
    ])
    func bucketMatchesDueDate(daysFromNow: Int, hour: Int, expected: DueBucket) {
        let dueDate = date(daysFromNow: daysFromNow, hour: hour)
        #expect(DueBucket.bucket(for: dueDate, now: now, calendar: calendar) == expected)
    }
}
