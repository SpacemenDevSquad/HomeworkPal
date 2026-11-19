import Foundation

/// The user's notification choices, persisted to `UserDefaults` under `PreferenceKey`.
struct NotificationPreferences: Equatable, Sendable {
    private static let defaultLeadTimes: Set<ReminderLeadTime> = [.oneDay]
    private static let defaultDailySummaryMinutesAfterMidnight = 7 * 60

    var isEnabled = false
    var leadTimes = Self.defaultLeadTimes
    var isDailySummaryEnabled = false
    var dailySummaryMinutesAfterMidnight = Self.defaultDailySummaryMinutesAfterMidnight
    var isOverdueReminderEnabled = true
    var playsSound = true

    init() {}

    init(userDefaults: UserDefaults) {
        isEnabled = userDefaults.bool(forKey: PreferenceKey.notificationsEnabled)
        if let storedLeadTimes = userDefaults.array(forKey: PreferenceKey.reminderLeadTimes) as? [Int] {
            leadTimes = Set(storedLeadTimes.compactMap(ReminderLeadTime.init(rawValue:)))
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
        userDefaults.set(leadTimes.map(\.rawValue).sorted(), forKey: PreferenceKey.reminderLeadTimes)
        userDefaults.set(isDailySummaryEnabled, forKey: PreferenceKey.dailySummaryEnabled)
        userDefaults.set(dailySummaryMinutesAfterMidnight, forKey: PreferenceKey.dailySummaryMinutesAfterMidnight)
        userDefaults.set(isOverdueReminderEnabled, forKey: PreferenceKey.overdueRemindersEnabled)
        userDefaults.set(playsSound, forKey: PreferenceKey.notificationSoundEnabled)
    }
}
