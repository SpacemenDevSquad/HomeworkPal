import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel

    init(planner: PlannerViewModel) {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(userDataService: UserDataService(planner: planner)))
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
                Text("This permanently deletes your assignments, classes, and settings from this device. This can't be undone.")
            }
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
        } header: {
            Text("Preferences")
                .foregroundStyle(Theme.primaryText)
        } footer: {
            Text("iCloud Sync keeps your assignments in your own private iCloud storage, never on our servers.")
                .foregroundStyle(Theme.secondaryText)
        }
        .listRowBackground(Theme.surface)
    }

    private var dataSection: some View {
        Section {
            Button(role: .destructive, action: viewModel.requestClearData) {
                Label("Clear All Data", systemImage: "trash")
            }
        } header: {
            Text("Data")
                .foregroundStyle(Theme.primaryText)
        }
        .listRowBackground(Theme.surface)
    }

    private var aboutSection: some View {
        Section {
            ExternalLinkRow(title: "Privacy Policy", systemImage: "hand.raised", destination: AppLinks.privacyPolicy)
            ExternalLinkRow(title: "Terms of Service", systemImage: "doc.text", destination: AppLinks.termsOfService)
            ExternalLinkRow(title: "Source Code on GitHub", systemImage: "chevron.left.forwardslash.chevron.right", destination: AppLinks.sourceCode)
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

private struct ExternalLinkRow: View {
    let title: LocalizedStringKey
    let systemImage: String
    let destination: URL

    var body: some View {
        Link(destination: destination) {
            HStack {
                Label(title, systemImage: systemImage)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Theme.secondaryText)
                    .accessibilityHidden(true)
            }
        }
        .foregroundStyle(Theme.primaryText)
    }
}

#if DEBUG
#Preview {
    SettingsView(planner: PlannerViewModel())
}
#endif
