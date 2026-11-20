import Foundation
import SwiftData
import Testing
@testable import HomeworkPal

@MainActor
struct CloudSyncServiceTests {
    @Test func togglingSyncReopensTheStoreWithTheMatchingSetting() {
        let course = Course(name: "English", colorHex: "#5A7FC2")
        let planner = PlannerViewModel(courses: [], assignments: [])
        var requestedSettings: [Bool] = []
        let service = CloudSyncService(planner: planner) { syncsWithICloud in
            requestedSettings.append(syncsWithICloud)
            return InMemoryPlannerService(courses: [course], assignments: [])
        }

        service.setCloudSyncEnabled(true)
        service.setCloudSyncEnabled(false)

        #expect(requestedSettings == [true, false])
        #expect(planner.courses == [course])
    }

    @Test func inMemoryStoresIgnoreTheSyncFlag() throws {
        // In-memory containers never request CloudKit, so tests can't reach the real iCloud database.
        // Test builds carry no iCloud entitlement, so this would fail if CloudKit were requested.
        let container = try SwiftDataPlannerService.makeContainer(isStoredInMemoryOnly: true, syncsWithICloud: true)
        let service = SwiftDataPlannerService(container: container)

        try service.insertCourse(Course(name: "English", colorHex: "#5A7FC2"))

        let snapshot = try service.fetchPlanner()
        #expect(snapshot.courses.count == 1)
        let isMemoryOnly = container.configurations.allSatisfy { $0.isStoredInMemoryOnly }
        #expect(isMemoryOnly)
    }
}

@MainActor
struct SettingsCloudSyncTests {
    private final class FakeCloudSync: CloudSyncServiceProtocol {
        var enabledChanges: [Bool] = []
        var isAccountAvailable = true

        func setCloudSyncEnabled(_ isEnabled: Bool) {
            enabledChanges.append(isEnabled)
        }

        func isICloudAccountAvailable() async -> Bool {
            isAccountAvailable
        }

        func finishedSyncEvents() -> AsyncStream<CloudSyncEvent> {
            AsyncStream { $0.finish() }
        }
    }

    private struct NoOpUserData: UserDataServiceProtocol {
        func deleteAllData() async throws {}
    }

    private func makeDefaults() throws -> UserDefaults {
        let suiteName = "SettingsCloudSyncTests-\(UUID().uuidString)"
        return try #require(UserDefaults(suiteName: suiteName))
    }

    @Test func turningTheToggleOnStartsSyncAndRemembersIt() throws {
        let defaults = try makeDefaults()
        let cloudSync = FakeCloudSync()
        let viewModel = SettingsViewModel(userDefaults: defaults, userDataService: NoOpUserData(), cloudSyncService: cloudSync)

        viewModel.iCloudSyncEnabled = true
        viewModel.iCloudSyncEnabled = false

        #expect(cloudSync.enabledChanges == [true, false])
        #expect(!defaults.bool(forKey: PreferenceKey.iCloudSyncEnabled))
    }

    @Test func settingTheSameValueDoesNotReopenTheStore() throws {
        let cloudSync = FakeCloudSync()
        let viewModel = SettingsViewModel(userDefaults: try makeDefaults(), userDataService: NoOpUserData(), cloudSyncService: cloudSync)

        viewModel.iCloudSyncEnabled = false

        #expect(cloudSync.enabledChanges.isEmpty)
    }

    @Test func missingICloudAccountIsReportedOnlyWhileSyncIsOn() async throws {
        let cloudSync = FakeCloudSync()
        cloudSync.isAccountAvailable = false
        let viewModel = SettingsViewModel(userDefaults: try makeDefaults(), userDataService: NoOpUserData(), cloudSyncService: cloudSync)

        await viewModel.refreshICloudStatus()
        #expect(!viewModel.isICloudAccountMissing)

        viewModel.iCloudSyncEnabled = true
        await viewModel.refreshICloudStatus()
        #expect(viewModel.isICloudAccountMissing)
    }

    @Test func clearingDataTurnsSyncOff() async throws {
        let cloudSync = FakeCloudSync()
        let viewModel = SettingsViewModel(userDefaults: try makeDefaults(), userDataService: NoOpUserData(), cloudSyncService: cloudSync)
        viewModel.iCloudSyncEnabled = true

        await viewModel.clearData()

        #expect(!viewModel.iCloudSyncEnabled)
        #expect(cloudSync.enabledChanges == [true, false])
    }
}
