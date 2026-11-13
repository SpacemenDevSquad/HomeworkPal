import SwiftUI
import UIKit

@main
struct HomeworkPalApp: App {
    init() {
        // SwiftUI has no API for navigation title color, so the palette is applied through UIKit's appearance proxy.
        let titleColor = UIColor(Theme.primaryText)
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: titleColor]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: titleColor]
    }

    var body: some Scene {
        WindowGroup {
            OnboardingView()
                .tint(Theme.primaryText)
        }
    }
}
