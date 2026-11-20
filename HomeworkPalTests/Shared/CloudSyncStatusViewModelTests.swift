import Foundation
import Testing
@testable import HomeworkPal

@MainActor
struct CloudSyncStatusViewModelTests {
    private final class FakeCloudSync: CloudSyncServiceProtocol {
        var enabledChanges: [Bool] = []

        func setCloudSyncEnabled(_ isEnabled: Bool) {
            enabledChanges.append(isEnabled)
        }

        func isICloudAccountAvailable() async -> Bool { true }

        func finishedSyncEvents() -> AsyncStream<CloudSyncEvent> {
            AsyncStream { $0.finish() }
        }
    }

    private let syncedAt = Date(timeIntervalSinceReferenceDate: 800_000_000)

    private func makeDefaults() throws -> UserDefaults {
        try #require(UserDefaults(suiteName: "CloudSyncStatusTests-\(UUID().uuidString)"))
    }

    private func makeViewModel(
        cloudSync: FakeCloudSync = FakeCloudSync(),
        defaults: UserDefaults,
        timeout: Duration = .seconds(30)
    ) -> CloudSyncStatusViewModel {
        CloudSyncStatusViewModel(cloudSync: cloudSync, userDefaults: defaults, checkTimeout: timeout)
    }

    @Test func successfulSyncIsRecordedAndRememberedAcrossLaunches() throws {
        let defaults = try makeDefaults()
        let viewModel = makeViewModel(defaults: defaults)

        viewModel.record(CloudSyncEvent(kind: .upload, succeeded: true, endDate: syncedAt))

        #expect(viewModel.lastSyncDate == syncedAt)
        #expect(makeViewModel(defaults: defaults).lastSyncDate == syncedAt)
    }

    @Test func setupDoesNotCountAsASync() throws {
        let viewModel = makeViewModel(defaults: try makeDefaults())

        viewModel.record(CloudSyncEvent(kind: .setup, succeeded: true, endDate: syncedAt))

        #expect(viewModel.lastSyncDate == nil)
    }

    @Test func failedSyncIsFlaggedAndKeepsTheLastGoodTime() throws {
        let viewModel = makeViewModel(defaults: try makeDefaults())
        viewModel.record(CloudSyncEvent(kind: .download, succeeded: true, endDate: syncedAt))

        viewModel.record(CloudSyncEvent(kind: .upload, succeeded: false, endDate: syncedAt.addingTimeInterval(60)))

        #expect(viewModel.didLastSyncFail)
        #expect(viewModel.lastSyncDate == syncedAt)

        viewModel.record(CloudSyncEvent(kind: .upload, succeeded: true, endDate: syncedAt.addingTimeInterval(120)))
        #expect(!viewModel.didLastSyncFail)
    }

    @Test func checkingReconnectsAndFinishesWhenTheDownloadDoes() throws {
        let cloudSync = FakeCloudSync()
        let viewModel = makeViewModel(cloudSync: cloudSync, defaults: try makeDefaults())

        viewModel.checkForUpdates()
        #expect(viewModel.isCheckingForUpdates)
        #expect(cloudSync.enabledChanges == [true])

        // An upload alone doesn't answer the question of whether other devices changed anything.
        viewModel.record(CloudSyncEvent(kind: .upload, succeeded: true, endDate: syncedAt))
        #expect(viewModel.isCheckingForUpdates)

        viewModel.record(CloudSyncEvent(kind: .download, succeeded: true, endDate: syncedAt))
        #expect(!viewModel.isCheckingForUpdates)
    }

    @Test func tappingAgainWhileCheckingDoesNothing() throws {
        let cloudSync = FakeCloudSync()
        let viewModel = makeViewModel(cloudSync: cloudSync, defaults: try makeDefaults())

        viewModel.checkForUpdates()
        viewModel.checkForUpdates()

        #expect(cloudSync.enabledChanges == [true])
    }

    @Test func checkStopsAfterTheTimeoutWhenNothingSyncs() async throws {
        let viewModel = makeViewModel(defaults: try makeDefaults(), timeout: .milliseconds(20))

        viewModel.checkForUpdates()
        try await Task.sleep(for: .milliseconds(200))

        #expect(!viewModel.isCheckingForUpdates)
    }
}
