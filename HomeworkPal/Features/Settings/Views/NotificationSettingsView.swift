import SwiftUI
import UIKit

struct NotificationSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.openURL) private var openURL

    var body: some View {
        Form {
            masterToggleSection
            if viewModel.notificationsEnabled {
                settingsSection
            }
        }
        .scrollContentBackground(.hidden)
        .background(Theme.background)
        .foregroundStyle(Theme.primaryText)
        .tint(Theme.primaryText)
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.default, value: viewModel.notificationsEnabled)
        .task {
            await viewModel.refreshNotificationStatus()
        }
        .alert("Notifications Are Off", isPresented: $viewModel.isShowingNotificationsDeniedAlert) {
            Button("Open Settings", action: openNotificationSettings)
                .keyboardShortcut(.defaultAction)
            Button("Not Now", role: .cancel) {}
        } message: {
            Text("To get due date reminders, allow notifications for HomeworkPal in the Settings app.")
        }
    }

    private var masterToggleSection: some View {
        Section {
            Toggle(isOn: notificationsBinding) {
                Label("Allow Notifications", systemImage: "bell")
            }
            .toggleStyle(.switch)
            .tint(Theme.accent)
        } footer: {
            Text("Reminders are scheduled on your device. Nothing is sent to a server.")
                .foregroundStyle(Theme.secondaryText)
        }
        .listRowBackground(Theme.surface)
    }

    private var settingsSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 0) {
                Label("Remind Me", systemImage: "clock")
                Picker("Remind Me", selection: $viewModel.notificationPreferences.reminderLeadTime) {
                    Text("None").tag(nil as ReminderLeadTime?)
                    ForEach(viewModel.leadTimeOptions) { leadTime in
                        Text(leadTime.title).tag(leadTime as ReminderLeadTime?)
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
            }
            Toggle(isOn: $viewModel.notificationPreferences.isDailySummaryEnabled) {
                Label("Daily Summary", systemImage: "sun.horizon")
            }
            if viewModel.notificationPreferences.isDailySummaryEnabled {
                DatePicker("Summary Time", selection: $viewModel.dailySummaryTime, displayedComponents: .hourAndMinute)
            }
            Toggle(isOn: $viewModel.notificationPreferences.isOverdueReminderEnabled) {
                Label("Overdue Reminders", systemImage: "exclamationmark.circle")
            }
        } header: {
            Text("Settings")
                .foregroundStyle(Theme.primaryText)
        } footer: {
            Text("Each assignment gets one reminder before it's due. The daily summary lists what's due that day. Overdue reminders let you know right after something's due if it isn't checked off.")
                .foregroundStyle(Theme.secondaryText)
        }
        .toggleStyle(.switch)
        .tint(Theme.accent)
        .listRowBackground(Theme.surface)
    }

    // The toggle reflects the permission result rather than the tap, so it routes through the view model.
    private var notificationsBinding: Binding<Bool> {
        Binding(
            get: { viewModel.notificationsEnabled },
            set: { isEnabled in
                Task { await viewModel.setNotificationsEnabled(isEnabled) }
            }
        )
    }

    private func openNotificationSettings() {
        // SwiftUI has no equivalent for the app's notification settings URL.
        guard let settingsURL = URL(string: UIApplication.openNotificationSettingsURLString) else { return }
        openURL(settingsURL)
    }
}

private struct LeadTimeRow: View {
    let title: LocalizedStringResource
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack {
                Text(title)
                Spacer()
                Image(systemName: "checkmark")
                    .font(.body.weight(.semibold))
                    .opacity(isSelected ? 1 : 0)
                    .accessibilityHidden(true)
            }
            .contentShape(.rect)
        }
        .foregroundStyle(Theme.primaryText)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#if DEBUG
#Preview {
    let planner = PlannerViewModel()
    NavigationStack {
        NotificationSettingsView(viewModel: SettingsViewModel(
            userDataService: UserDataService(planner: planner),
            // Memory-only, so the preview never opens the real store or iCloud.
            cloudSyncService: CloudSyncService(planner: planner) { _ in InMemoryPlannerService() }
        ))
    }
}

#Preview("Enabled") {
    let planner = PlannerViewModel()
    // A throwaway suite, so the preview starts with notifications on without touching the app's real settings.
    let userDefaults = UserDefaults(suiteName: "NotificationSettingsPreview") ?? .standard
    var preferences = NotificationPreferences()
    preferences.isEnabled = true
    preferences.save(to: userDefaults)
    return NavigationStack {
        NotificationSettingsView(viewModel: SettingsViewModel(
            userDefaults: userDefaults,
            userDataService: UserDataService(planner: planner),
            cloudSyncService: CloudSyncService(planner: planner) { _ in InMemoryPlannerService() }
        ))
    }
}
#endif
