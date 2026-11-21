import CoreData
import SwiftUI
import UIKit
import UserNotifications

@main
struct HomeworkPalApp: App {
    /// The one shared copy of the student's data; every tab reads and writes through it.
    @State private var planner: PlannerViewModel
    /// When the planner last synced with iCloud, shown in Settings.
    @State private var syncStatus: CloudSyncStatusViewModel
    /// Schedules reminders and opens the assignment behind a tapped notification.
    @State private var notifications: NotificationsViewModel
    @Environment(\.scenePhase) private var scenePhase

    init() {
        let planner = PlannerViewModel(
            persistence: SwiftDataPlannerService.makePersistence(
                syncsWithICloud: UserDefaults.standard.bool(forKey: PreferenceKey.iCloudSyncEnabled)
            )
        )
        _planner = State(initialValue: planner)
        _syncStatus = State(initialValue: CloudSyncStatusViewModel(cloudSync: CloudSyncService(planner: planner)))
        let notifications = NotificationsViewModel(planner: planner)
        _notifications = State(initialValue: notifications)
        // Set during launch so the tap that opened the app is delivered. The center holds it weakly; the state keeps it alive.
        UNUserNotificationCenter.current().delegate = notifications

        // SwiftUI has no API for navigation title color, so the palette is applied through UIKit's appearance proxy.
        let titleColor = UIColor(Theme.primaryText)
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: titleColor]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: titleColor]
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(planner)
                .environment(syncStatus)
                .environment(notifications)
                .tint(Theme.primaryText)
                .task {
                    planner.refreshFromStore()
                }
                .task {
                    await notifications.monitorPlannerChanges()
                }
                .task {
                    await notifications.monitorPreferenceChanges()
                }
                .task {
                    await syncStatus.monitorSyncEvents()
                }
                // SwiftData merges changes synced from other devices into the store on its own, but the planner
                // holds its own copy for the screens, so it reloads whenever the store reports outside changes.
                .task {
                    for await _ in NotificationCenter.default.notifications(named: .NSPersistentStoreRemoteChange) {
                        planner.refreshFromStore()
                    }
                }
                // Coming back to the app also catches up, in case changes arrived while it was suspended, and
                // rebuilds the notifications so the daily summaries stay written ahead and the badge is current.
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        planner.refreshFromStore()
                        Task { await notifications.reschedule() }
                    }
                }
        }
    }
}
