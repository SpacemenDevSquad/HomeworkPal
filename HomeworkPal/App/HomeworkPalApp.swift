import CoreData
import SwiftUI
import UIKit

@main
struct HomeworkPalApp: App {
    /// The one shared copy of the student's data; every tab reads and writes through it.
    @State private var planner: PlannerViewModel
    /// When the planner last synced with iCloud, shown in Settings.
    @State private var syncStatus: CloudSyncStatusViewModel
    @Environment(\.scenePhase) private var scenePhase

    init() {
        let planner = PlannerViewModel(
            persistence: SwiftDataPlannerService.makePersistence(
                syncsWithICloud: UserDefaults.standard.bool(forKey: PreferenceKey.iCloudSyncEnabled)
            )
        )
        _planner = State(initialValue: planner)
        _syncStatus = State(initialValue: CloudSyncStatusViewModel(cloudSync: CloudSyncService(planner: planner)))

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
                .tint(Theme.primaryText)
                .task {
                    planner.refreshFromStore()
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
                // Coming back to the app also catches up, in case changes arrived while it was suspended.
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        planner.refreshFromStore()
                    }
                }
        }
    }
}
