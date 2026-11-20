import Foundation

/// The user's notification choices, persisted to `UserDefaults` under `PreferenceKey`.
struct NotificationPreferences: Equatable, Sendable {
    private static let defaultDailySummaryMinutesAfterMidnight = 7 * 60

    var isEnabled = false
    /// When each assignment's reminder fires, or `nil` for no per-assignment reminder.
    var reminderLeadTime: ReminderLeadTime? = .oneDay
    var isDailySummaryEnabled = false
    var dailySummaryMinutesAfterMidnight = Self.defaultDailySummaryMinutesAfterMidnight
    var isOverdueReminderEnabled = true
    var playsSound = true

    init() {}

    init(userDefaults: UserDefaults) {
        isEnabled = userDefaults.bool(forKey: PreferenceKey.notificationsEnabled)
        // Stored as an array of zero or one values; empty means None. Earlier versions allowed several reminders,
        // so keep the one that warned earliest.
        if let storedLeadTimes = userDefaults.array(forKey: PreferenceKey.reminderLeadTimes) as? [Int] {
            reminderLeadTime = storedLeadTimes.compactMap(ReminderLeadTime.init(rawValue:)).max { $0.rawValue < $1.rawValue }
        }
        isDailySummaryEnabled = userDefaults.bool(forKey: PreferenceKey.dailySummaryEnabled)
        if let storedMinutes = userDefaults.object(forKey: PreferenceKey.dailySummaryMinutesAfterMidnight) as? Int {
            dailySummaryMinutesAfterMidnight = storedMinutes
        }
        if let storedOverdue = userDefaults.object(forKey: PreferenceKey.overdueRemindersEnabled) as? Bool {
            isOverdueReminderEnabled = storedOverdue
        }
        if let storedSound = userDefaults.object(forKey: PreferenceKey.notificationSoundEnabled) as? Bool {
            playsSound = storedSound
        }
    }

    func save(to userDefaults: UserDefaults) {
        userDefaults.set(isEnabled, forKey: PreferenceKey.notificationsEnabled)
        userDefaults.set(reminderLeadTime.map { [$0.rawValue] } ?? [], forKey: PreferenceKey.reminderLeadTimes)
        userDefaults.set(isDailySummaryEnabled, forKey: PreferenceKey.dailySummaryEnabled)
        userDefaults.set(dailySummaryMinutesAfterMidnight, forKey: PreferenceKey.dailySummaryMinutesAfterMidnight)
        userDefaults.set(isOverdueReminderEnabled, forKey: PreferenceKey.overdueRemindersEnabled)
        userDefaults.set(playsSound, forKey: PreferenceKey.notificationSoundEnabled)
    }
}
