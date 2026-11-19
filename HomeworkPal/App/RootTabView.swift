import SwiftUI

struct RootTabView: View {
    @Environment(PlannerViewModel.self) private var planner

    var body: some View {
        @Bindable var planner = planner
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
                SettingsView(planner: planner)
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
    RootTabView()
        .environment(PlannerViewModel())
        .tint(Theme.primaryText)
}
#endif
