import UserNotifications

/// Checks and requests permission to show notifications.
protocol NotificationAuthorizationServiceProtocol {
    func isAuthorized() async -> Bool
    /// Shows the system permission prompt the first time; afterwards returns the student's earlier answer.
    func requestAuthorization() async throws -> Bool
}

final class NotificationAuthorizationService: NotificationAuthorizationServiceProtocol {
    /// Statuses under which the app can deliver notifications.
    private static let authorizedStatuses: Set<UNAuthorizationStatus> = [.authorized, .provisional, .ephemeral]

    func isAuthorized() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return Self.authorizedStatuses.contains(settings.authorizationStatus)
    }

    func requestAuthorization() async throws -> Bool {
        try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
    }
}

/// Temporary stand-in that never asks the system and always reports permission as granted.
///
/// The test devices can't grant notification permission yet, so the Allow Notifications toggle
/// just flips the saved preference. Swap `SettingsViewModel`'s default back to
/// `NotificationAuthorizationService()` once real notifications are wired up.
final class DummyNotificationAuthorizationService: NotificationAuthorizationServiceProtocol {
    func isAuthorized() async -> Bool { true }
    func requestAuthorization() async throws -> Bool { true }
}
