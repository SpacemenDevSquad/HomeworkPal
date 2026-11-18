import OSLog
import SwiftUI
import UIKit

@main
struct HomeworkPalApp: App {
    /// The one shared copy of the student's data; every tab reads and writes through it.
    @State private var planner = PlannerViewModel(persistence: Self.makePersistence())

    init() {
        // SwiftUI has no API for navigation title color, so the palette is applied through UIKit's appearance proxy.
        let titleColor = UIColor(Theme.primaryText)
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: titleColor]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: titleColor]
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(planner)
                .tint(Theme.primaryText)
                .task {
                    planner.loadPlanner()
                }
        }
    }

    /// Opens the on-device store. If it can't be opened, the app still launches and explains that changes
    /// can't be saved, rather than crashing or letting the student add work that would be lost.
    private static func makePersistence() -> any PlannerPersistenceService {
        do {
            return SwiftDataPlannerService(container: try SwiftDataPlannerService.makeContainer())
        } catch {
            Logger.persistence.fault("Opening the planner store failed: \(error.localizedDescription, privacy: .private)")
            return UnavailablePlannerService()
        }
    }
}
