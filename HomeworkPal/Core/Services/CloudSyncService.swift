import CloudKit
import CoreData
import Foundation
import OSLog

/// A finished iCloud upload or download, kept free of Core Data so the rest of the app doesn't depend on it.
nonisolated struct CloudSyncEvent: Equatable, Sendable {
    enum Kind: Sendable {
        /// Preparing the iCloud connection, which happens before the first download.
        case setup
        /// Downloading changes made on other devices.
        case download
        /// Uploading this device's changes.
        case upload
    }

    let kind: Kind
    let succeeded: Bool
    let endDate: Date
}

/// Turns iCloud sync of the student's planner on or off, and checks whether iCloud is available.
protocol CloudSyncServiceProtocol {
    func setCloudSyncEnabled(_ isEnabled: Bool)
    /// Whether this device is signed in to iCloud, so syncing can actually happen.
    func isICloudAccountAvailable() async -> Bool
    /// Each upload, download, or setup as it finishes. Unfinished work isn't reported.
    func finishedSyncEvents() -> AsyncStream<CloudSyncEvent>
}

/// Syncs through the student's private iCloud database, so data is never stored on HomeworkPal's servers.
final class CloudSyncService: CloudSyncServiceProtocol {
    private let planner: PlannerViewModel
    private let makePersistence: @MainActor (Bool) -> any PlannerPersistenceService

    /// - Parameter makePersistence: Opens the store with sync on (`true`) or off. Injected for tests and previews.
    init(
        planner: PlannerViewModel,
        makePersistence: @escaping @MainActor (Bool) -> any PlannerPersistenceService
            = SwiftDataPlannerService.makePersistence(syncsWithICloud:)
    ) {
        self.planner = planner
        self.makePersistence = makePersistence
    }

    func setCloudSyncEnabled(_ isEnabled: Bool) {
        planner.replacePersistence { makePersistence(isEnabled) }
    }

    func isICloudAccountAvailable() async -> Bool {
        do {
            let status = try await CKContainer(identifier: SwiftDataPlannerService.cloudKitContainerIdentifier).accountStatus()
            return status == .available
        } catch {
            Logger.persistence.error("Checking the iCloud account failed: \(error.localizedDescription, privacy: .private)")
            return false
        }
    }

    /// SwiftData syncs through Core Data's CloudKit mirroring, which reports its progress with this notification.
    func finishedSyncEvents() -> AsyncStream<CloudSyncEvent> {
        AsyncStream { continuation in
            let task = Task {
                let notifications = NotificationCenter.default.notifications(named: NSPersistentCloudKitContainer.eventChangedNotification)
                for await notification in notifications {
                    let key = NSPersistentCloudKitContainer.eventNotificationUserInfoKey
                    guard let event = notification.userInfo?[key] as? NSPersistentCloudKitContainer.Event,
                          let syncEvent = Self.finishedEvent(from: event) else { continue }
                    continuation.yield(syncEvent)
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    /// Each operation is reported once when it starts and again when it ends; only the end has a date.
    private static func finishedEvent(from event: NSPersistentCloudKitContainer.Event) -> CloudSyncEvent? {
        guard let endDate = event.endDate else { return nil }
        let kind: CloudSyncEvent.Kind
        switch event.type {
        case .setup: kind = .setup
        case .import: kind = .download
        case .export: kind = .upload
        @unknown default: return nil
        }
        if let error = event.error {
            Logger.persistence.error("iCloud sync failed: \(error.localizedDescription, privacy: .private)")
        }
        return CloudSyncEvent(kind: kind, succeeded: event.succeeded, endDate: endDate)
    }
}
