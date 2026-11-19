import Combine
import Foundation
import os

@MainActor
final class SettingsViewModel: ObservableObject {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "HomeworkPal", category: "Settings")
    private static let minutesPerHour = 60

    @Published var notificationPreferences: NotificationPreferences {
        didSet { notificationPreferences.save(to: userDefaults) }
    }
    @Published var iCloudSyncEnabled: Bool {
        didSet { userDefaults.set(iCloudSyncEnabled, forKey: PreferenceKey.iCloudSyncEnabled) }
    }

    /// Set when the user turns notifications on but the system permission is denied. Drives the "open Settings" alert.
    @Published var isShowingNotificationsDeniedAlert = false
    @Published var isConfirmingClearData = false
    @Published var errorMessage: String?

    private let userDefaults: UserDefaults
    private let calendar: Calendar
    private let notificationService: NotificationAuthorizationServiceProtocol
    private let userDataService: UserDataServiceProtocol

    init(
        userDefaults: UserDefaults = .standard,
        calendar: Calendar = .current,
        notificationService: NotificationAuthorizationServiceProtocol = NotificationAuthorizationService(),
        userDataService: UserDataServiceProtocol = UserDataService()
    ) {
        self.userDefaults = userDefaults
        self.calendar = calendar
        self.notificationService = notificationService
        self.userDataService = userDataService
        self.notificationPreferences = NotificationPreferences(userDefaults: userDefaults)
        self.iCloudSyncEnabled = userDefaults.bool(forKey: PreferenceKey.iCloudSyncEnabled)
    }

    var notificationsEnabled: Bool {
        notificationPreferences.isEnabled
    }

    /// Reminder options in display order, soonest to the due date first.
    var leadTimeOptions: [ReminderLeadTime] {
        ReminderLeadTime.allCases
    }

    /// The daily summary time as a `Date` today, so it can drive a time picker.
    var dailySummaryTime: Date {
        get {
            let minutes = notificationPreferences.dailySummaryMinutesAfterMidnight
            let startOfDay = calendar.startOfDay(for: .now)
            return calendar.date(byAdding: .minute, value: minutes, to: startOfDay) ?? startOfDay
        }
        set {
            let components = calendar.dateComponents([.hour, .minute], from: newValue)
            notificationPreferences.dailySummaryMinutesAfterMidnight =
                (components.hour ?? 0) * Self.minutesPerHour + (components.minute ?? 0)
        }
    }

    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "–"
    }

    func isLeadTimeSelected(_ leadTime: ReminderLeadTime) -> Bool {
        notificationPreferences.leadTimes.contains(leadTime)
    }

    func toggleLeadTime(_ leadTime: ReminderLeadTime) {
        if notificationPreferences.leadTimes.contains(leadTime) {
            notificationPreferences.leadTimes.remove(leadTime)
        } else {
            notificationPreferences.leadTimes.insert(leadTime)
        }
    }

    /// Turns notifications off if the user revoked permission in the Settings app since the preference was saved.
    func refreshNotificationStatus() async {
        guard notificationsEnabled else { return }
        let isAuthorized = await notificationService.isAuthorized()
        guard !isAuthorized else { return }
        notificationPreferences.isEnabled = false
    }

    func setNotificationsEnabled(_ isEnabled: Bool) async {
        guard isEnabled else {
            notificationPreferences.isEnabled = false
            return
        }

        do {
            let isAuthorized = try await notificationService.requestAuthorization()
            notificationPreferences.isEnabled = isAuthorized
            isShowingNotificationsDeniedAlert = !isAuthorized
        } catch {
            Self.logger.error("Notification authorization failed: \(error.localizedDescription, privacy: .public)")
            notificationPreferences.isEnabled = false
            errorMessage = String(localized: "Notifications couldn't be turned on. Please try again.")
        }
    }

    func requestClearData() {
        isConfirmingClearData = true
    }

    func clearData() async {
        do {
            try await userDataService.deleteAllData()
            notificationPreferences = NotificationPreferences()
            iCloudSyncEnabled = false
        } catch {
            Self.logger.error("Clearing user data failed: \(error.localizedDescription, privacy: .public)")
            errorMessage = error.localizedDescription
        }
    }
}
