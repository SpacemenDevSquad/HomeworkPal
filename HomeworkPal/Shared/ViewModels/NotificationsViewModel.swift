import Foundation
import Observation
import UserNotifications

/// Keeps the scheduled reminders, overdue alerts, daily summaries, and app icon badge in step with the
/// student's assignments and settings, and routes a tapped notification to its assignment.
///
/// Created once in `HomeworkPalApp` and injected with `.environment`. It's also the notification center's
/// delegate, so it must exist before launch finishes to receive the tap that opened the app.
@MainActor
@Observable
final class NotificationsViewModel: NSObject, UNUserNotificationCenterDelegate {
    /// Set when the student taps an assignment's notification. The Upcoming tab opens it, then clears this.
    var assignmentToOpen: Assignment.ID?

    /// What a schedule was built from, so unrelated settings changes don't rebuild it.
    private struct ScheduleInputs: Equatable {
        let assignments: [Assignment]
        let preferences: NotificationPreferences
    }

    @ObservationIgnored private let planner: PlannerViewModel
    @ObservationIgnored private let scheduler: any NotificationSchedulingService
    @ObservationIgnored private let userDefaults: UserDefaults
    @ObservationIgnored private let calendar: Calendar
    @ObservationIgnored private let now: () -> Date
    @ObservationIgnored private var lastScheduledInputs: ScheduleInputs?
    /// The schedule being written. Each rebuild waits for the one before it, so two never interleave.
    @ObservationIgnored private var schedulingTask: Task<Void, Never>?

    init(
        planner: PlannerViewModel,
        scheduler: any NotificationSchedulingService = UserNotificationSchedulingService(),
        userDefaults: UserDefaults = .standard,
        calendar: Calendar = .current,
        now: @escaping () -> Date = { .now }
    ) {
        self.planner = planner
        self.scheduler = scheduler
        self.userDefaults = userDefaults
        self.calendar = calendar
        self.now = now
        super.init()
    }

    /// Rebuilds the schedule and badge, even if nothing changed. Called when the app opens, because time has
    /// passed: the daily summaries need extending and the overdue count may have grown.
    func reschedule() async {
        let inputs = currentInputs
        lastScheduledInputs = inputs
        let date = now()
        let planned = NotificationPlanner.plan(
            assignments: inputs.assignments,
            preferences: inputs.preferences,
            now: date,
            calendar: calendar
        )
        let badgeCount = inputs.preferences.isEnabled
            ? NotificationPlanner.overdueCount(in: inputs.assignments, at: date)
            : 0

        let previousTask = schedulingTask
        let task = Task { [scheduler] in
            await previousTask?.value
            await scheduler.replacePendingNotifications(with: planned)
            await scheduler.setBadgeCount(badgeCount)
        }
        schedulingTask = task
        await task.value
    }

    /// Rebuilds the schedule only if assignments or notification settings changed since the last build.
    func rescheduleIfNeeded() async {
        guard currentInputs != lastScheduledInputs else { return }
        await reschedule()
    }

    /// Rebuilds whenever an assignment is added, edited, completed, or deleted. Runs for the app's lifetime.
    func monitorPlannerChanges() async {
        let changes = plannerChanges()
        // Catches up first, in case the planner finished loading before watching began.
        await rescheduleIfNeeded()
        for await _ in changes {
            await rescheduleIfNeeded()
        }
    }

    /// Rebuilds whenever a notification setting changes. Runs for the app's lifetime.
    func monitorPreferenceChanges() async {
        for await _ in NotificationCenter.default.notifications(named: UserDefaults.didChangeNotification) {
            await rescheduleIfNeeded()
        }
    }

    private var currentInputs: ScheduleInputs {
        ScheduleInputs(
            assignments: planner.assignments,
            preferences: NotificationPreferences(userDefaults: userDefaults)
        )
    }

    private func plannerChanges() -> AsyncStream<Void> {
        AsyncStream { continuation in
            observeAssignments(continuation)
        }
    }

    private func observeAssignments(_ continuation: AsyncStream<Void>.Continuation) {
        withObservationTracking {
            _ = planner.assignments
        } onChange: { [weak self] in
            // `onChange` fires just before the change lands and only once, so announce it on the next
            // main-actor turn, once the new values are in place, then start watching again.
            Task { @MainActor in
                guard let self else {
                    continuation.finish()
                    return
                }
                continuation.yield()
                self.observeAssignments(continuation)
            }
        }
    }

    private func openAssignment(withID id: Assignment.ID) {
        assignmentToOpen = id
    }

    // MARK: - UNUserNotificationCenterDelegate

    // These use the completion-handler forms rather than the `async` ones. The `async` forms finish on a
    // background thread, so the system's completion handling then trips UIKit's main-thread check and crashes.
    // Calling the handlers from the main actor avoids that.

    /// Shows notifications as banners even while the app is open.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping @Sendable (UNNotificationPresentationOptions) -> Void
    ) {
        Task { @MainActor in
            completionHandler([.banner, .list, .sound, .badge])
        }
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping @Sendable () -> Void
    ) {
        // Read here, because the response isn't safe to pass to the main actor.
        let userInfo = response.notification.request.content.userInfo
        let assignmentID = (userInfo[UserNotificationSchedulingService.assignmentIDKey] as? String)
            .flatMap(UUID.init(uuidString:))
        let isDefaultAction = response.actionIdentifier == UNNotificationDefaultActionIdentifier

        Task { @MainActor in
            if isDefaultAction, let assignmentID {
                self.openAssignment(withID: assignmentID)
            }
            completionHandler()
        }
    }
}

#if DEBUG
extension NotificationsViewModel {
    /// Never touches the system, so previews don't schedule real notifications.
    private final class PreviewSchedulingService: NotificationSchedulingService {
        func replacePendingNotifications(with notifications: [PlannedNotification]) async {}
        func setBadgeCount(_ count: Int) async {}
    }

    static func preview(planner: PlannerViewModel) -> NotificationsViewModel {
        NotificationsViewModel(
            planner: planner,
            scheduler: PreviewSchedulingService(),
            userDefaults: UserDefaults(suiteName: "NotificationsPreview") ?? .standard
        )
    }
}
#endif
