import SwiftUI

struct RootTabView: View {
    @Environment(PlannerViewModel.self) private var planner

    var body: some View {
        TabView {
            Tab("Dashboard", systemImage: "checklist") {
                DashboardView(planner: planner)
            }
            Tab("Calendar", systemImage: "calendar") {
                CalendarView(planner: planner)
            }
            Tab("Activities", systemImage: "books.vertical") {
                ActivitiesView(planner: planner)
            }
            Tab("Settings", systemImage: "gearshape") {
                SettingsView()
            }
        }
    }
}

#Preview {
    RootTabView()
        .environment(PlannerViewModel())
        .tint(Theme.primaryText)
}
