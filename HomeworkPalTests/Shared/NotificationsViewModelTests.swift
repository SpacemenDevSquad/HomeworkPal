import Foundation
import Testing
@testable import HomeworkPal

@MainActor
struct NotificationsViewModelTests {
    private final class FakeScheduler: NotificationSchedulingService {
        var scheduled: [[PlannedNotification]] = []
        var badgeCounts: [Int] = []

        func replacePendingNotifications(with notifications: [PlannedNotification]) async {
            scheduled.append(notifications)
        }

        func setBadgeCount(_ count: Int) async {
            badgeCounts.append(count)
        }
    }

    private let now = Date(timeIntervalSinceReferenceDate: 800_000_000)

    private func makeDefaults(notificationsEnabled: Bool) throws -> UserDefaults {
        let defaults = try #require(UserDefaults(suiteName: "NotificationsViewModelTests-\(UUID().uuidString)"))
        var preferences = NotificationPreferences()
        preferences.isEnabled = notificationsEnabled
        preferences.save(to: defaults)
        return defaults
    }

    private func makeViewModel(
        planner: PlannerViewModel,
        scheduler: FakeScheduler,
        defaults: UserDefaults
    ) -> NotificationsViewModel {
        NotificationsViewModel(planner: planner, scheduler: scheduler, userDefaults: defaults) { [now] in now }
    }

    @Test func rescheduleSchedulesThePlanAndShowsTheOverdueCount() async throws {
        let late = Assignment(title: "Reading", course: .english, dueDate: now.addingTimeInterval(-3_600))
        let upcoming = Assignment(title: "Essay", course: .english, dueDate: now.addingTimeInterval(172_800))
        let planner = PlannerViewModel(assignments: [late, upcoming])
        let scheduler = FakeScheduler()
        let viewModel = makeViewModel(planner: planner, scheduler: scheduler, defaults: try makeDefaults(notificationsEnabled: true))

        await viewModel.reschedule()

        let scheduled = try #require(scheduler.scheduled.last)
        #expect(scheduled.contains { $0.kind == .reminder && $0.assignmentID == upcoming.id })
        #expect(scheduler.badgeCounts == [1])
    }

    @Test func turningNotificationsOffClearsEverythingAndTheBadge() async throws {
        let late = Assignment(title: "Reading", course: .english, dueDate: now.addingTimeInterval(-3_600))
        let scheduler = FakeScheduler()
        let viewModel = makeViewModel(
            planner: PlannerViewModel(assignments: [late]),
            scheduler: scheduler,
            defaults: try makeDefaults(notificationsEnabled: false)
        )

        await viewModel.reschedule()

        #expect(scheduler.scheduled == [[]])
        #expect(scheduler.badgeCounts == [0])
    }

    @Test func rescheduleIfNeededSkipsWhenNothingChanged() async throws {
        let planner = PlannerViewModel(assignments: [])
        let scheduler = FakeScheduler()
        let viewModel = makeViewModel(planner: planner, scheduler: scheduler, defaults: try makeDefaults(notificationsEnabled: true))

        await viewModel.rescheduleIfNeeded()
        await viewModel.rescheduleIfNeeded()
        #expect(scheduler.scheduled.count == 1)

        planner.addAssignment(Assignment(title: "Essay", course: .english, dueDate: now.addingTimeInterval(172_800)))
        await viewModel.rescheduleIfNeeded()
        #expect(scheduler.scheduled.count == 2)
    }
}
