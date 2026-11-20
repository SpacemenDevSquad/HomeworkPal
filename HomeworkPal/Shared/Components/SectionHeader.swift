import SwiftUI

struct SectionHeader: View {
    private static let badgeHorizontalPadding: CGFloat = 8
    private static let badgeVerticalPadding: CGFloat = 2

    let title: LocalizedStringResource
    /// The number shown in the badge beside the title, or `nil` to show no badge.
    var count: Int? = nil
    /// Fills the count badge with the orange accent to draw attention, such as for overdue work.
    var isEmphasized = false

    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Theme.primaryText)
            if let count {
                Text(count, format: .number)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.primaryText)
                    .padding(.horizontal, Self.badgeHorizontalPadding)
                    .padding(.vertical, Self.badgeVerticalPadding)
                    .background(isEmphasized ? Theme.accent : Theme.surface, in: .capsule)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    VStack {
        SectionHeader(title: "Overdue", count: 1, isEmphasized: true)
        SectionHeader(title: "Today", count: 2)
    }
    .padding()
    .background(Theme.background)
}
