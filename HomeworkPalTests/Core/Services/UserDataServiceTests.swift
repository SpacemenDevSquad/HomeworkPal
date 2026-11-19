import Foundation
import Testing
@testable import HomeworkPal

@MainActor
struct UserDataServiceTests {
    @Test func deleteAllDataEmptiesPlannerAndClearsSettings() async throws {
        let suiteName = "UserDataServiceTests-\(UUID().uuidString)"
        let userDefaults = try #require(UserDefaults(suiteName: suiteName))
        defer { userDefaults.removePersistentDomain(forName: suiteName) }
        userDefaults.set(true, forKey: PreferenceKey.notificationsEnabled)
        userDefaults.set(true, forKey: PreferenceKey.iCloudSyncEnabled)
        let planner = PlannerViewModel(courses: Course.sampleData, assignments: Assignment.sampleData)
        let service = UserDataService(planner: planner, userDefaults: userDefaults)

        try await service.deleteAllData()

        #expect(planner.courses.isEmpty)
        #expect(planner.assignments.isEmpty)
        #expect(PreferenceKey.allKeys.allSatisfy { userDefaults.object(forKey: $0) == nil })
    }

    @Test func failedDeleteKeepsSettings() async throws {
        let suiteName = "UserDataServiceTests-\(UUID().uuidString)"
        let userDefaults = try #require(UserDefaults(suiteName: suiteName))
        defer { userDefaults.removePersistentDomain(forName: suiteName) }
        userDefaults.set(true, forKey: PreferenceKey.notificationsEnabled)
        let service = UserDataService(planner: PlannerViewModel(persistence: UnavailablePlannerService()), userDefaults: userDefaults)

        await #expect(throws: PlannerPersistenceError.storeUnavailable) {
            try await service.deleteAllData()
        }
        #expect(userDefaults.bool(forKey: PreferenceKey.notificationsEnabled))
    }
}
