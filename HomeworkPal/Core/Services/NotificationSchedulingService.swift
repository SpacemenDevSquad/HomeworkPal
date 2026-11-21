import OSLog
import UserNotifications

/// Hands planned notifications to the system and keeps the app icon badge current.
protocol NotificationSchedulingService {
    /// Removes everything already scheduled and schedules `notifications` in its place.
    func replacePendingNotifications(with notifications: [PlannedNotification]) async
    func setBadgeCount(_ count: Int) async
}

final class UserNotificationSchedulingService: NotificationSchedulingService {
    /// The `userInfo` key holding the assignment a notification opens when tapped.
    nonisolated static let assignmentIDKey = "assignmentID"

    private let center = UNUserNotificationCenter.current()

    func replacePendingNotifications(with notifications: [PlannedNotification]) async {
        center.removeAllPendingNotificationRequests()
        for notification in notifications {
            do {
                try await center.add(Self.request(for: notification))
            } catch {
                Logger.notifications.error("Scheduling a notification failed: \(error.localizedDescription, privacy: .private)")
            }
        }
    }

    func setBadgeCount(_ count: Int) async {
        do {
            try await center.setBadgeCount(count)
        } catch {
            Logger.notifications.error("Updating the badge failed: \(error.localizedDescription, privacy: .private)")
        }
    }

    private static func request(for notification: PlannedNotification) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        if notification.kind != .badgeUpdate {
            content.title = notification.title
            content.body = notification.body
            // The standard ding, which the system silences on its own when the phone is on silent.
            content.sound = .default
        }
        if let badgeCount = notification.badgeCount {
            content.badge = NSNumber(value: badgeCount)
        }
        if let assignmentID = notification.assignmentID {
            content.userInfo = [assignmentIDKey: assignmentID.uuidString]
        }

        // Calendar components rather than a countdown, so the time stays right if the device's clock changes.
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: notification.fireDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        return UNNotificationRequest(identifier: notification.identifier, content: content, trigger: trigger)
    }
}
