import SwiftUI

/// Shows when the planner last synced with iCloud. Tapping it asks iCloud to check for changes right away.
struct ICloudSyncStatusRow: View {
    /// How often the "5 minutes ago" text refreshes while Settings is open.
    private static let relativeTimeRefreshInterval: TimeInterval = 60

    @Environment(CloudSyncStatusViewModel.self) private var syncStatus

    var body: some View {
        Button {
            syncStatus.checkForUpdates()
        } label: {
            LabeledContent {
                status
            } label: {
                Label("Check for Updates", systemImage: "arrow.triangle.2.circlepath")
            }
        }
        .disabled(syncStatus.isCheckingForUpdates)
        .accessibilityHint(Text("Asks iCloud for changes made on your other devices"))
    }

    @ViewBuilder
    private var status: some View {
        if syncStatus.isCheckingForUpdates {
            HStack(spacing: 6) {
                ProgressView()
                Text("Checking…")
            }
            .foregroundStyle(Theme.secondaryText)
        } else if syncStatus.didLastSyncFail {
            // Says so plainly instead of showing an old time that looks current.
            Label("Couldn't sync", systemImage: "exclamationmark.icloud")
                .foregroundStyle(Theme.primaryText)
        } else if let lastSyncDate = syncStatus.lastSyncDate {
            TimelineView(.periodic(from: .now, by: Self.relativeTimeRefreshInterval)) { _ in
                Text("Synced \(lastSyncDate, format: .relative(presentation: .named))")
            }
            .foregroundStyle(Theme.secondaryText)
        } else {
            Text("Not synced yet")
                .foregroundStyle(Theme.secondaryText)
        }
    }
}

#if DEBUG
#Preview {
    let planner = PlannerViewModel()
    let syncStatus = CloudSyncStatusViewModel.preview(planner: planner)
    let _ = syncStatus.record(CloudSyncEvent(kind: .download, succeeded: true, endDate: .now.addingTimeInterval(-300)))
    Form {
        Section {
            Toggle(isOn: .constant(true)) {
                Label("iCloud Sync", systemImage: "icloud")
            }
            .tint(Theme.accent)
            ICloudSyncStatusRow()
        }
        .listRowBackground(Theme.surface)
    }
    .scrollContentBackground(.hidden)
    .background(Theme.background)
    .foregroundStyle(Theme.primaryText)
    .tint(Theme.primaryText)
    .environment(syncStatus)
}
#endif
