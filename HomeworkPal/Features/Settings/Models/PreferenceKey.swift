import Foundation

/// `UserDefaults` keys for the student's settings, kept in one place so reading, writing, and clearing agree.
enum PreferenceKey {
    static let notificationsEnabled = "notificationsEnabled"
    static let reminderLeadTimes = "reminderLeadTimes"
    static let dailySummaryEnabled = "dailySummaryEnabled"
    static let dailySummaryMinutesAfterMidnight = "dailySummaryMinutesAfterMidnight"
    static let overdueRemindersEnabled = "overdueRemindersEnabled"
    static let iCloudSyncEnabled = "iCloudSyncEnabled"
    /// When this device last finished syncing with iCloud successfully.
    static let lastICloudSyncDate = "lastICloudSyncDate"

    /// Every key above, so Clear Data can remove them all.
    static let allKeys = [
        notificationsEnabled,
        reminderLeadTimes,
        dailySummaryEnabled,
        dailySummaryMinutesAfterMidnight,
        overdueRemindersEnabled,
        iCloudSyncEnabled,
        lastICloudSyncDate
    ]
}
