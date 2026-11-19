import Foundation

/// Erases what the student has stored in HomeworkPal.
protocol UserDataServiceProtocol {
    func deleteAllData() async throws
}

/// Deletes every class, activity, and assignment, plus saved settings, from the device.
final class UserDataService: UserDataServiceProtocol {
    /// Planner data goes through the shared planner so every tab empties immediately, not just after a relaunch.
    private let planner: PlannerViewModel
    private let userDefaults: UserDefaults

    init(planner: PlannerViewModel, userDefaults: UserDefaults = .standard) {
        self.planner = planner
        self.userDefaults = userDefaults
    }

    func deleteAllData() async throws {
        try planner.deleteAllData()
        PreferenceKey.allKeys.forEach(userDefaults.removeObject(forKey:))
    }
}
