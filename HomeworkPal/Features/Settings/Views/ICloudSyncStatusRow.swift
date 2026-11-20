import SwiftUI

/// Shows when the planner last synced with iCloud. Tapping it asks iCloud to check for changes right away.
struct ICloudSyncStatusRow: View {
    /// How often the "5 minutes ago" text refreshes while Settings is open.
    private static let relativeTimeRefreshInterval: TimeInterval = 60

    /// How long the arrows take to make one full turn while checking.
    private static let spinDuration: TimeInterval = 1.5
    private static let fullTurnDegrees: Double = 360

    @Environment(CloudSyncStatusViewModel.self) private var syncStatus
    /// Mirrors `isCheckingForUpdates`, but changes after the row appears so the spin starts even if a check is
    /// already running when Settings opens.
    @State private var isSpinning = false
    /// Changes each time a check ends, giving the arrows a new identity that drops the running animation.
    @State private var spinCycle = 0

    var body: some View {
        Button {
            syncStatus.checkForUpdates()
        } label: {
            LabeledContent {
                status
            } label: {
                Label {
                    Text("Check for Updates")
                } icon: {
                    // The arrows spin while checking, so the row needs no separate progress spinner.
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .rotationEffect(.degrees(isSpinning ? Self.fullTurnDegrees : 0))
                        .animation(
                            isSpinning ? .linear(duration: Self.spinDuration).repeatForever(autoreverses: false) : nil,
                            value: isSpinning
                        )
                        // A repeating animation can't be cancelled, so stopping swaps in a fresh, upright image.
                        .id(spinCycle)
                }
            }
        }
        .disabled(syncStatus.isCheckingForUpdates)
        .onChange(of: syncStatus.isCheckingForUpdates, initial: true) { _, isChecking in
            if !isChecking {
                spinCycle += 1
            }
            isSpinning = isChecking
        }
        .accessibilityHint(Text("Asks iCloud for changes made on your other devices"))
    }

    @ViewBuilder
    private var status: some View {
        if syncStatus.isCheckingForUpdates {
            Text("Checking…")
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
