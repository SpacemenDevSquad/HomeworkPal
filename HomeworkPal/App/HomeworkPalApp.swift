import SwiftUI
import UIKit

@main
struct HomeworkPalApp: App {
    /// The one shared copy of the student's data; every tab reads and writes through it.
    @State private var planner = PlannerViewModel()

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
        }
    }
}
