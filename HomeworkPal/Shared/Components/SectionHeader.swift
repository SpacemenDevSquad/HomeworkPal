import SwiftUI

struct SectionHeader: View {
    private static let badgeHorizontalPadding: CGFloat = 8
    private static let badgeVerticalPadding: CGFloat = 2

    let bucket: DueBucket
    let count: Int

    // Overdue gets the orange accent fill so it stands out; other buckets use the neutral surface.
    private var badgeFill: Color {
        bucket == .overdue ? Theme.accent : Theme.surface
    }

    var body: some View {
        HStack(spacing: 8) {
            Text(bucket.title)
                .font(.headline)
                .foregroundStyle(Theme.primaryText)
            Text(count, format: .number)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Theme.primaryText)
                .padding(.horizontal, Self.badgeHorizontalPadding)
                .padding(.vertical, Self.badgeVerticalPadding)
                .background(badgeFill, in: .capsule)
            Spacer()
        }
        .padding(.vertical, 8)
        .background(Theme.background)
    }
}

#Preview {
    VStack {
        SectionHeader(bucket: .overdue, count: 1)
        SectionHeader(bucket: .today, count: 2)
    }
    .padding()
    .background(Theme.background)
}
