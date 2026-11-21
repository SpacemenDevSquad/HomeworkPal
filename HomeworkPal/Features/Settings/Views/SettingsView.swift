import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    /// The About link open in the in-app browser, if any.
    @State private var presentedWebPage: PresentedWebPage?
    @State private var isEditingProfile = false

    /// Read directly for the profile, and passed to the profile editor.
    private let planner: PlannerViewModel

    init(planner: PlannerViewModel) {
        self.planner = planner
        _viewModel = StateObject(wrappedValue: SettingsViewModel(
            userDataService: UserDataService(planner: planner),
            cloudSyncService: CloudSyncService(planner: planner)
        ))
    }

    var body: some View {
        NavigationStack {
            Form {
                profileSection
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
        }
        .sheet(item: $presentedWebPage) { webPage in
            WebPageSheet(url: webPage.url)
        }
        .sheet(isPresented: $isEditingProfile) {
            EditProfileView(planner: planner)
        }
        // Attached to the stack, not the root list, so errors also surface while a pushed screen is showing.
        .alert("Something Went Wrong", isPresented: isShowingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    /// Sits straight on the background, with no row card behind it.
    private var profileSection: some View {
        Section {
            ProfileHeader(name: planner.profile.name, photoData: planner.profile.photoData)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
        }
    }

    private var preferencesSection: some View {
        Section {
            DisclosureButtonRow(title: "Edit Profile", systemImage: "person.crop.circle") {
                isEditingProfile = true
            }
            NavigationLink(value: SettingsDestination.notifications) {
                LabeledContent {
                    HStack {
                        Text(viewModel.notificationsEnabled ? "On" : "Off")
                            .foregroundStyle(Theme.secondaryText)
                        DisclosureChevron()
                    }
                } label: {
                    Label("Notifications", systemImage: "bell")
                }
            }
            // Swapped for the app's own arrow, so it matches the Edit Profile row above it exactly.
            .navigationLinkIndicatorVisibility(.hidden)
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
                Text("iCloud Sync keeps your classes, assignments, and profile up to date on every device signed in to your Apple Account, using your own private iCloud storage, never our servers.")
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
            // Attached to the button so the dialog's popover points at it, rather than at the whole screen.
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
        } header: {
            Text("Data")
                .foregroundStyle(Theme.primaryText)
        }
        .listRowBackground(Theme.surface)
    }

    private var aboutSection: some View {
        Section {
            DisclosureButtonRow(title: "Privacy Policy", systemImage: "hand.raised") {
                presentedWebPage = PresentedWebPage(url: AppLinks.privacyPolicy)
            }
            DisclosureButtonRow(title: "Source Code on GitHub", systemImage: "chevron.left.forwardslash.chevron.right") {
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

/// The trailing arrow on every Settings row that opens another screen. Drawn by the app rather than the system,
/// so the rows that open sheets and the row that pushes a screen all look identical.
private struct DisclosureChevron: View {
    var body: some View {
        Image(systemName: "chevron.right")
            .font(.footnote.weight(.semibold))
            .foregroundStyle(Color(uiColor: .tertiaryLabel))
            .accessibilityHidden(true)
    }
}

/// A button row with a trailing chevron, matching the look of a navigation link, for rows that open a sheet.
private struct DisclosureButtonRow: View {
    let title: LocalizedStringKey
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Label(title, systemImage: systemImage)
                Spacer()
                DisclosureChevron()
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
