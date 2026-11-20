import SwiftUI

/// A form section holding one red Delete button, placed last in an edit sheet.
///
/// The red is set explicitly because the forms tint everything brown, which would otherwise
/// override the destructive role and make Delete look as safe as any other button.
struct DeleteButtonSection: View {
    let title: LocalizedStringKey
    let action: () -> Void

    var body: some View {
        Section {
            Button(role: .destructive, action: action) {
                Label(title, systemImage: "trash")
                    .foregroundStyle(Theme.destructive)
                    .frame(maxWidth: .infinity)
            }
        }
        .listRowBackground(Theme.surface)
    }
}

#if DEBUG
#Preview {
    Form {
        DeleteButtonSection(title: "Delete Class") {}
    }
    .scrollContentBackground(.hidden)
    .background(Theme.background)
}
#endif
