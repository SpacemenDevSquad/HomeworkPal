import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    /// The About link open in the in-app browser, if any.
    @State private var presentedWebPage: PresentedWebPage?

    init(planner: PlannerViewModel) {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(
            userDataService: UserDataService(planner: planner),
            cloudSyncService: CloudSyncService(planner: planner)
        ))
    }

    var body: some View {
        NavigationStack {
            Form {
                preferencesSection
                dataSection
                aboutSection
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .foregroundStyle(Theme.primaryText)
            .tint(Theme.primaryText)
            .navigationTitle("Settings")
            .navigationDestination(for: SettingsDestination.self) { destination in
                switch destination {
                case .notifications:
                    NotificationSettingsView(viewModel: viewModel)
                }
            }
            .task {
                await viewModel.refreshNotificationStatus()
                await viewModel.refreshICloudStatus()
            }
            .confirmationDialog(
                "Clear All Data?",
                isPresented: $viewModel.isConfirmingClearData,
                titleVisibility: .visible
            ) {
                Button("Clear All Data", role: .destructive) {
                    Task { await viewModel.clearData() }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                // With sync on, deletions sync too, so the warning has to say every device is affected.
                if viewModel.iCloudSyncEnabled {
                    Text("This permanently deletes your assignments and classes from iCloud and every device signed in to it, plus this device's settings. This can't be undone.")
                } else {
                    Text("This permanently deletes your assignments, classes, and settings from this device. This can't be undone.")
                }
            }
        }
        .sheet(item: $presentedWebPage) { webPage in
            WebPageSheet(url: webPage.url)
        }
        // Attached to the stack, not the root list, so errors also surface while a pushed screen is showing.
        .alert("Something Went Wrong", isPresented: isShowingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var preferencesSection: some View {
        Section {
            NavigationLink(value: SettingsDestination.notifications) {
                LabeledContent {
                    Text(viewModel.notificationsEnabled ? "On" : "Off")
                        .foregroundStyle(Theme.secondaryText)
                } label: {
                    Label("Notifications", systemImage: "bell")
                }
            }
            Toggle(isOn: $viewModel.iCloudSyncEnabled) {
                Label("iCloud Sync", systemImage: "icloud")
            }
            .toggleStyle(.switch)
            // Orange is reserved for fills, so the switch's "on" track uses the accent.
            .tint(Theme.accent)
            if viewModel.iCloudSyncEnabled {
                ICloudSyncStatusRow()
            }
        } header: {
            Text("Preferences")
                .foregroundStyle(Theme.primaryText)
        } footer: {
            VStack(alignment: .leading, spacing: 6) {
                if viewModel.isICloudAccountMissing {
                    Label("Sign in to iCloud in the Settings app to start syncing.", systemImage: "exclamationmark.icloud")
                        .foregroundStyle(Theme.primaryText)
                }
                Text("iCloud Sync keeps your classes and assignments up to date on every device signed in to your Apple Account, using your own private iCloud storage, never our servers.")
                    .foregroundStyle(Theme.secondaryText)
            }
        }
        .listRowBackground(Theme.surface)
    }

    private var dataSection: some View {
        Section {
            Button(role: .destructive, action: viewModel.requestClearData) {
                Label("Clear All Data", systemImage: "trash")
                    // The form's brown tint would otherwise override the destructive red.
                    .foregroundStyle(Theme.destructive)
            }
        } header: {
            Text("Data")
                .foregroundStyle(Theme.primaryText)
        }
        .listRowBackground(Theme.surface)
    }

    private var aboutSection: some View {
        Section {
            WebLinkRow(title: "Privacy Policy", systemImage: "hand.raised") {
                presentedWebPage = PresentedWebPage(url: AppLinks.privacyPolicy)
            }
            WebLinkRow(title: "Source Code on GitHub", systemImage: "chevron.left.forwardslash.chevron.right") {
                presentedWebPage = PresentedWebPage(url: AppLinks.sourceCode)
            }
            LabeledContent("Version", value: viewModel.appVersion)
        } header: {
            Text("About")
                .foregroundStyle(Theme.primaryText)
        } footer: {
            Text("HomeworkPal is free and open source.")
                .foregroundStyle(Theme.secondaryText)
        }
        .listRowBackground(Theme.surface)
    }

    private var isShowingError: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { isShowing in
                if !isShowing { viewModel.errorMessage = nil }
            }
        )
    }
}

/// A row that opens a web page in an in-app sheet rather than switching to Safari.
private struct WebLinkRow: View {
    let title: LocalizedStringKey
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Label(title, systemImage: systemImage)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Theme.secondaryText)
                    .accessibilityHidden(true)
            }
            .contentShape(.rect)
        }
        .foregroundStyle(Theme.primaryText)
    }
}

#if DEBUG
#Preview {
    let planner = PlannerViewModel()
    SettingsView(planner: planner)
        .environment(CloudSyncStatusViewModel.preview(planner: planner))
}
#endif
