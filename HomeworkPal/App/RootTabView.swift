import SwiftUI

struct RootTabView: View {
    private enum AppTab: Hashable {
        case dashboard, calendar, activities, settings
    }

    @Environment(PlannerViewModel.self) private var planner
    @Environment(NotificationsViewModel.self) private var notifications
    @State private var selectedTab = AppTab.dashboard

    var body: some View {
        @Bindable var planner = planner
        TabView(selection: $selectedTab) {
            Tab("Dashboard", systemImage: "checklist", value: AppTab.dashboard) {
                DashboardView(planner: planner)
            }
            Tab("Calendar", systemImage: "calendar", value: AppTab.calendar) {
                CalendarView(planner: planner)
            }
            Tab("Activities", systemImage: "books.vertical", value: AppTab.activities) {
                ActivitiesView(planner: planner)
            }
            Tab("Settings", systemImage: "gearshape", value: AppTab.settings) {
                SettingsView(planner: planner)
            }
        }
        // A tapped reminder opens on the Dashboard, which pushes the assignment itself.
        .onChange(of: notifications.assignmentToOpen, initial: true) { _, assignmentID in
            if assignmentID != nil {
                selectedTab = .dashboard
            }
        }
        // Shown here so a failed save is reported no matter which tab it happened in.
        .alert("Something Went Wrong", isPresented: $planner.isShowingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(planner.errorMessage ?? "")
        }
    }
}

#if DEBUG
#Preview {
    let planner = PlannerViewModel()
    RootTabView()
        .environment(planner)
        .environment(CloudSyncStatusViewModel.preview(planner: planner))
        .environment(NotificationsViewModel.preview(planner: planner))
        .tint(Theme.primaryText)
}
#endif
