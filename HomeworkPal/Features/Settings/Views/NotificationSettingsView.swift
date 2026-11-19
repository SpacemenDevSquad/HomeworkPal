import SwiftUI
import UIKit

struct NotificationSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.openURL) private var openURL

    var body: some View {
        Form {
            masterToggleSection
            if viewModel.notificationsEnabled {
                remindersSection
                extrasSection
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

    private var remindersSection: some View {
        Section {
            ForEach(viewModel.leadTimeOptions) { leadTime in
                LeadTimeRow(
                    title: leadTime.title,
                    isSelected: viewModel.isLeadTimeSelected(leadTime)
                ) {
                    viewModel.toggleLeadTime(leadTime)
                }
            }
        } header: {
            Text("Remind Me")
                .foregroundStyle(Theme.primaryText)
        } footer: {
            Text("Choose one or more reminders for each assignment.")
                .foregroundStyle(Theme.secondaryText)
        }
        .listRowBackground(Theme.surface)
    }

    private var extrasSection: some View {
        Section {
            Toggle(isOn: $viewModel.notificationPreferences.isDailySummaryEnabled) {
                Label("Daily Summary", systemImage: "sun.horizon")
            }
            if viewModel.notificationPreferences.isDailySummaryEnabled {
                DatePicker("Summary Time", selection: $viewModel.dailySummaryTime, displayedComponents: .hourAndMinute)
            }
            Toggle(isOn: $viewModel.notificationPreferences.isOverdueReminderEnabled) {
                Label("Overdue Reminders", systemImage: "exclamationmark.circle")
            }
            Toggle(isOn: $viewModel.notificationPreferences.playsSound) {
                Label("Sound", systemImage: "speaker.wave.2")
            }
        } header: {
            Text("More")
                .foregroundStyle(Theme.primaryText)
        } footer: {
            Text("The daily summary lists what's due today. Overdue reminders nudge you each morning about work that isn't checked off.")
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
    NavigationStack {
        NotificationSettingsView(viewModel: SettingsViewModel(userDataService: UserDataService(planner: PlannerViewModel())))
    }
}
#endif
