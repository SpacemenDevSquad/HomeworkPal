import Foundation
import Testing
@testable import HomeworkPal

struct CourseScheduleTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US")
        return calendar
    }()

    private func schedule(_ weekdays: Set<Weekday>) -> CourseSchedule {
        CourseSchedule(weekdays: weekdays, startMinutes: 540, endMinutes: 600, repeatsUntil: .now)
    }

    @Test func commonDaySetsGetShortNames() {
        #expect(schedule(Set(Weekday.allCases)).daysDescription(calendar: calendar) == "Every day")
        #expect(schedule(Weekday.schoolDays).daysDescription(calendar: calendar) == "Weekdays")
        #expect(schedule(Weekday.weekend).daysDescription(calendar: calendar) == "Weekends")
    }

    @Test func otherDaysAreListedMondayFirst() {
        #expect(schedule([.sunday, .wednesday, .monday]).daysDescription(calendar: calendar) == "Mon, Wed, Sun")
    }

    @Test func timeRangeUsesMinutesAfterMidnight() throws {
        let day = try #require(calendar.date(from: DateComponents(year: 2026, month: 11, day: 18, hour: 13)))
        let range = schedule([.monday]).timeRange(on: day, calendar: calendar)

        #expect(calendar.component(.hour, from: range.lowerBound) == 9)
        #expect(calendar.component(.hour, from: range.upperBound) == 10)
    }
}
