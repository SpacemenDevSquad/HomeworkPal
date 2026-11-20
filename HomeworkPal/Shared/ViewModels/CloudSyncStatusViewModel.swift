import Foundation
import Observation

/// When the planner last synced with iCloud, and whether a "Check for Updates" is in progress.
///
/// Global so it can record sync activity from launch, long before Settings is opened. Created once in
/// `HomeworkPalApp` and injected with `.environment`.
@MainActor
@Observable
final class CloudSyncStatusViewModel {
    /// How long "Check for Updates" waits before giving up, so the spinner can't run forever when iOS
    /// postpones syncing, such as on a poor connection or in Low Power Mode.
    static let checkTimeout: Duration = .seconds(30)

    /// When this device last finished syncing successfully, or `nil` if it never has.
    private(set) var lastSyncDate: Date?
    private(set) var isCheckingForUpdates = false
    /// `true` when the most recent sync attempt failed, so Settings can say so instead of showing a stale time.
    private(set) var didLastSyncFail = false

    private let cloudSync: any CloudSyncServiceProtocol
    private let userDefaults: UserDefaults
    private let checkTimeout: Duration
    private var timeoutTask: Task<Void, Never>?

    init(
        cloudSync: any CloudSyncServiceProtocol,
        userDefaults: UserDefaults = .standard,
        checkTimeout: Duration = CloudSyncStatusViewModel.checkTimeout
    ) {
        self.cloudSync = cloudSync
        self.userDefaults = userDefaults
        self.checkTimeout = checkTimeout
        lastSyncDate = userDefaults.object(forKey: PreferenceKey.lastICloudSyncDate) as? Date
    }

    /// Records sync activity for as long as the app runs. Called from `.task` at the app's root.
    func monitorSyncEvents() async {
        for await event in cloudSync.finishedSyncEvents() {
            record(event)
        }
    }

    /// iCloud has no "sync now" request, so this reconnects to it, which in practice makes iOS check for
    /// changes right away. The spinner stops when that check's download finishes, or after the timeout.
    func checkForUpdates() {
        guard !isCheckingForUpdates else { return }
        isCheckingForUpdates = true
        cloudSync.setCloudSyncEnabled(true)
        timeoutTask = Task { [checkTimeout] in
            try? await Task.sleep(for: checkTimeout)
            guard !Task.isCancelled else { return }
            finishCheck()
        }
    }

    func record(_ event: CloudSyncEvent) {
        // Setup only prepares the connection; it doesn't move any data.
        guard event.kind != .setup else { return }
        didLastSyncFail = !event.succeeded
        if event.succeeded {
            lastSyncDate = event.endDate
            userDefaults.set(event.endDate, forKey: PreferenceKey.lastICloudSyncDate)
        }
        // A check is waiting for other devices' changes, so it's over once a download finishes.
        if event.kind == .download {
            finishCheck()
        }
    }

    private func finishCheck() {
        timeoutTask?.cancel()
        timeoutTask = nil
        isCheckingForUpdates = false
    }
}

#if DEBUG
extension CloudSyncStatusViewModel {
    /// Backed by memory only, so previews never open the real store or reach iCloud.
    static func preview(planner: PlannerViewModel) -> CloudSyncStatusViewModel {
        CloudSyncStatusViewModel(
            cloudSync: CloudSyncService(planner: planner) { _ in InMemoryPlannerService() },
            userDefaults: UserDefaults(suiteName: "CloudSyncStatusPreview") ?? .standard
        )
    }
}
#endif
