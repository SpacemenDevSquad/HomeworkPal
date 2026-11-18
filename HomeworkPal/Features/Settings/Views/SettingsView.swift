import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Coming Soon",
                systemImage: "gearshape",
                description: Text("Settings aren't available yet.")
            )
            .foregroundStyle(Theme.primaryText)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.background)
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
