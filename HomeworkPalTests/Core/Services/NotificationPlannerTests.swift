import Foundation
import Testing
@testable import HomeworkPal

@MainActor
struct NotificationPlannerTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        return calendar
    }()

    /// Noon on a fixed day, so every test sees the same "now".
    private var now: Date {
        calendar.date(from: DateComponents(year: 2026, month: 3, day: 10, hour: 12)) ?? .distantPast
    }

    private func date(daysFromNow days: Int, hour: Int) -> Date {
        let day = calendar.date(byAdding: .day, value: days, to: calendar.startOfDay(for: now)) ?? now
        return calendar.date(byAdding: .hour, value: hour, to: day) ?? day
    }

    private func preferences(
        leadTime: ReminderLeadTime? = .oneDay,
        overdue: Bool = true,
        dailySummary: Bool = false
    ) -> NotificationPreferences {
        var preferences = NotificationPreferences()
        preferences.isEnabled = true
        preferences.reminderLeadTime = leadTime
        preferences.isOverdueReminderEnabled = overdue
        preferences.isDailySummaryEnabled = dailySummary
        preferences.dailySummaryMinutesAfterMidnight = 7 * 60
        return preferences
    }

    private func plan(_ assignments: [Assignment], _ preferences: NotificationPreferences) -> [PlannedNotification] {
        NotificationPlanner.plan(assignments: assignments, preferences: preferences, now: now, calendar: calendar)
    }

    @Test func nothingIsScheduledWhenNotificationsAreOff() {
        var preferences = preferences(dailySummary: true)
        preferences.isEnabled = false
        let essay = Assignment(title: "Essay", course: .english, dueDate: date(daysFromNow: 2, hour: 9))

        #expect(plan([essay], preferences).isEmpty)
    }

    @Test func reminderFiresTheChosenTimeBeforeTheDueDate() throws {
        let essay = Assignment(title: "Essay", course: .english, dueDate: date(daysFromNow: 2, hour: 9))

        let reminder = try #require(plan([essay], preferences(leadTime: .oneDay)).first { $0.kind == .reminder })

        #expect(reminder.fireDate == date(daysFromNow: 1, hour: 9))
        #expect(reminder.title == "Essay")
        #expect(reminder.assignmentID == essay.id)
    }

    @Test func noneSchedulesNoAssignmentReminders() {
        let essay = Assignment(title: "Essay", course: .english, dueDate: date(daysFromNow: 2, hour: 9))

        #expect(!plan([essay], preferences(leadTime: nil)).contains { $0.kind == .reminder })
    }

    @Test func completedAssignmentsGetNothing() {
        let essay = Assignment(title: "Essay", course: .english, dueDate: date(daysFromNow: 2, hour: 9), isCompleted: true)

        #expect(plan([essay], preferences(dailySummary: true)).isEmpty)
    }

    @Test func remindersWhoseTimeHasPassedAreSkipped() {
        // Due in 3 hours, so a 1-day reminder would already be in the past.
        let quiz = Assignment(title: "Quiz", course: .biology, dueDate: date(daysFromNow: 0, hour: 15))

        let kinds = plan([quiz], preferences(leadTime: .oneDay)).map(\.kind)

        #expect(kinds == [.overdue])
    }

    @Test func overdueReminderFiresAMinuteAfterTheDueTimeWithTheOverdueCount() throws {
        let alreadyLate = Assignment(title: "Reading", course: .english, dueDate: date(daysFromNow: -1, hour: 8))
        let quiz = Assignment(title: "Quiz", course: .biology, dueDate: date(daysFromNow: 0, hour: 15))

        let overdue = try #require(plan([alreadyLate, quiz], preferences(leadTime: nil)).first)

        #expect(overdue.kind == .overdue)
        #expect(overdue.assignmentID == quiz.id)
        #expect(overdue.fireDate == quiz.dueDate.addingTimeInterval(60))
        #expect(overdue.badgeCount == 2)
    }

    @Test func turningOffOverdueRemindersStillKeepsTheBadgeCurrent() throws {
        let quiz = Assignment(title: "Quiz", course: .biology, dueDate: date(daysFromNow: 0, hour: 15))

        let update = try #require(plan([quiz], preferences(leadTime: nil, overdue: false)).first)

        #expect(update.kind == .badgeUpdate)
        #expect(update.title.isEmpty)
        #expect(update.assignmentID == nil)
        #expect(update.badgeCount == 1)
    }

    @Test func dailySummaryListsWhatsDueAndSkipsEmptyDays() throws {
        let essay = Assignment(title: "Essay", course: .english, dueDate: date(daysFromNow: 2, hour: 23))
        let quiz = Assignment(title: "Quiz", course: .biology, dueDate: date(daysFromNow: 2, hour: 9))

        let summaries = plan([essay, quiz], preferences(leadTime: nil, overdue: true, dailySummary: true))
            .filter { $0.kind == .dailySummary }
        let summary = try #require(summaries.first)

        #expect(summaries.count == 1)
        #expect(summary.fireDate == date(daysFromNow: 2, hour: 7))
        // Listed in due order.
        #expect(summary.body.contains("Quiz"))
        #expect(summary.body.range(of: "Quiz")?.lowerBound ?? summary.body.endIndex
            < summary.body.range(of: "Essay")?.lowerBound ?? summary.body.startIndex)
    }

    @Test func planIsCappedAtTheSystemLimitKeepingTheSoonest() throws {
        let assignments = (1...100).map { day in
            Assignment(title: "Day \(day)", course: .calculus, dueDate: date(daysFromNow: day, hour: 9))
        }

        let planned = plan(assignments, preferences(leadTime: .oneDay))
        let lastPlanned = try #require(planned.last)

        #expect(planned.count == NotificationPlanner.maximumPendingNotifications)
        #expect(planned.map(\.fireDate) == planned.map(\.fireDate).sorted())
        #expect(lastPlanned.fireDate < date(daysFromNow: 40, hour: 0))
    }
}
