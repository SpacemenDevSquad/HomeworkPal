import Foundation

/// One local notification the app intends to schedule.
struct PlannedNotification: Equatable, Sendable {
    enum Kind: Sendable {
        /// Fires a chosen time before an assignment is due.
        case reminder
        /// Fires just after an unfinished assignment's due time.
        case overdue
        /// Lists what's due that day, at the student's chosen time.
        case dailySummary
        /// Shows nothing; only updates the app icon's overdue count when overdue reminders are off.
        case badgeUpdate
    }

    let identifier: String
    let kind: Kind
    let title: String
    let body: String
    let fireDate: Date
    /// The overdue count to show on the app icon when this fires, or `nil` to leave the badge as it is.
    let badgeCount: Int?
    /// The assignment to open when the student taps the notification.
    let assignmentID: Assignment.ID?
}

/// Works out every notification to schedule from the student's assignments and settings.
///
/// Local notifications can't change their text after they're scheduled, so the daily summaries are written
/// ahead of time, one per day, and the whole plan is rebuilt whenever assignments or settings change.
enum NotificationPlanner {
    /// iOS keeps at most 64 pending notifications per app and silently drops the rest.
    static let maximumPendingNotifications = 64
    /// How many days of daily summaries to write ahead. Opening the app rebuilds the plan and extends it.
    static let dailySummaryDaysAhead = 14
    /// How long after the due time the overdue reminder fires.
    static let overdueDelay: TimeInterval = 60

    static func plan(
        assignments: [Assignment],
        preferences: NotificationPreferences,
        now: Date,
        calendar: Calendar
    ) -> [PlannedNotification] {
        guard preferences.isEnabled else { return [] }
        let openAssignments = assignments.filter { !$0.isCompleted }

        var planned: [PlannedNotification] = []
        if let leadTime = preferences.reminderLeadTime {
            planned += reminders(for: openAssignments, leadTime: leadTime)
        }
        planned += overdueNotifications(for: openAssignments, sendsAlert: preferences.isOverdueReminderEnabled)
        if preferences.isDailySummaryEnabled {
            planned += dailySummaries(
                for: openAssignments,
                minutesAfterMidnight: preferences.dailySummaryMinutesAfterMidnight,
                now: now,
                calendar: calendar
            )
        }

        // Keeps the soonest ones, since later ones get scheduled when the plan is next rebuilt.
        return planned
            .filter { $0.fireDate > now }
            .sorted { $0.fireDate < $1.fireDate }
            .prefix(maximumPendingNotifications)
            .map(\.self)
    }

    /// How many unfinished assignments are past due at `date`. Shown on the app icon.
    static func overdueCount(in assignments: [Assignment], at date: Date) -> Int {
        assignments.count { !$0.isCompleted && $0.dueDate < date }
    }

    private static func reminders(for assignments: [Assignment], leadTime: ReminderLeadTime) -> [PlannedNotification] {
        assignments.map { assignment in
            PlannedNotification(
                identifier: "reminder-\(assignment.id.uuidString)",
                kind: .reminder,
                title: assignment.title,
                body: String(localized: "\(assignment.course.name) · Due \(dueDateText(for: assignment))"),
                fireDate: assignment.dueDate.addingTimeInterval(-TimeInterval(leadTime.minutesBeforeDue * 60)),
                badgeCount: nil,
                assignmentID: assignment.id
            )
        }
    }

    /// One per unfinished assignment, firing just after it's due. Each carries the overdue count at that
    /// moment, so the app icon stays current even while the app is closed.
    private static func overdueNotifications(for assignments: [Assignment], sendsAlert: Bool) -> [PlannedNotification] {
        assignments.map { assignment in
            let fireDate = assignment.dueDate.addingTimeInterval(overdueDelay)
            let badgeCount = overdueCount(in: assignments, at: fireDate)
            guard sendsAlert else {
                return PlannedNotification(
                    identifier: "badge-\(assignment.id.uuidString)",
                    kind: .badgeUpdate,
                    title: "",
                    body: "",
                    fireDate: fireDate,
                    badgeCount: badgeCount,
                    assignmentID: nil
                )
            }
            return PlannedNotification(
                identifier: "overdue-\(assignment.id.uuidString)",
                kind: .overdue,
                title: String(localized: "Overdue: \(assignment.title)"),
                body: String(localized: "\(assignment.course.name) was due \(dueDateText(for: assignment)). Turn it in as soon as you can."),
                fireDate: fireDate,
                badgeCount: badgeCount,
                assignmentID: assignment.id
            )
        }
    }

    /// One per day that has unfinished work due. Days with nothing due get no summary.
    private static func dailySummaries(
        for assignments: [Assignment],
        minutesAfterMidnight: Int,
        now: Date,
        calendar: Calendar
    ) -> [PlannedNotification] {
        let today = calendar.startOfDay(for: now)
        return (0..<dailySummaryDaysAhead).compactMap { dayOffset in
            guard
                let day = calendar.date(byAdding: .day, value: dayOffset, to: today),
                let fireDate = calendar.date(byAdding: .minute, value: minutesAfterMidnight, to: day)
            else { return nil }

            let dueThatDay = assignments
                .filter { calendar.isDate($0.dueDate, inSameDayAs: day) }
                .sorted { $0.dueDate < $1.dueDate }
            guard !dueThatDay.isEmpty else { return nil }

            let items = dueThatDay.map { "\($0.title) (\($0.course.name))" }
            let dayKey = day.formatted(.iso8601.year().month().day())
            return PlannedNotification(
                identifier: "summary-\(dayKey)",
                kind: .dailySummary,
                title: String(localized: "Due Today"),
                body: items.formatted(.list(type: .and)),
                fireDate: fireDate,
                badgeCount: nil,
                assignmentID: nil
            )
        }
    }

    /// For example "Fri, Nov 21, 11:59 PM".
    private static func dueDateText(for assignment: Assignment) -> String {
        assignment.dueDate.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day().hour().minute())
    }
}
