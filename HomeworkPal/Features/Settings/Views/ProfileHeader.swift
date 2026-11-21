import SwiftUI
import UIKit

/// The student's photo inside a slowly turning dashed ring, with their name below it.
struct ProfileHeader: View {
    private static let photoDiameter: CGFloat = 96
    /// Space between the photo and the dashed ring around it.
    private static let ringGap: CGFloat = 6
    private static let ringLineWidth: CGFloat = 3
    private static let ringDash: [CGFloat] = [8, 6]
    /// Seconds for the ring to make one full turn.
    private static let ringTurnDuration: TimeInterval = 20
    private static let fullTurnDegrees: Double = 360

    /// The student's name, or `nil` if they haven't set one.
    var name: String?
    /// The student's photo, or `nil` to show a placeholder.
    var photo: Image?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                ring
                photoView
                    .frame(width: Self.photoDiameter, height: Self.photoDiameter)
                    .clipShape(.circle)
            }
            .accessibilityHidden(true)

            Text(displayName)
                .font(.title2.weight(.semibold))
                .foregroundStyle(Theme.primaryText)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    private var displayName: String {
        guard let name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return String(localized: "Default User")
        }
        return name
    }

    @ViewBuilder
    private var photoView: some View {
        if let photo {
            photo
                .resizable()
                .scaledToFill()
        } else {
            // The fill sits behind the symbol rather than on it, so it covers the whole circle, not just the
            // symbol's narrower frame.
            ZStack {
                Theme.surface
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(Self.photoDiameter * 0.22)
                    .foregroundStyle(Theme.secondaryText)
            }
        }
    }

    /// Driven by the clock rather than a repeating animation, so the spin can't stall after switching tabs
    /// or returning from another screen. Pausing it for Reduce Motion leaves the ring still.
    private var ring: some View {
        TimelineView(.animation(paused: reduceMotion)) { context in
            let elapsed = context.date.timeIntervalSinceReferenceDate
            let progress = elapsed.truncatingRemainder(dividingBy: Self.ringTurnDuration) / Self.ringTurnDuration
            Circle()
                .strokeBorder(
                    Theme.accent,
                    style: StrokeStyle(lineWidth: Self.ringLineWidth, lineCap: .round, dash: Self.ringDash)
                )
                .rotationEffect(.degrees(reduceMotion ? 0 : progress * Self.fullTurnDegrees))
        }
        .frame(
            width: Self.photoDiameter + (Self.ringGap + Self.ringLineWidth) * 2,
            height: Self.photoDiameter + (Self.ringGap + Self.ringLineWidth) * 2
        )
    }
}

extension ProfileHeader {
    /// Shows a saved photo, decoding it from the JPEG data the profile stores.
    init(name: String, photoData: Data?) {
        self.init(name: name, photo: photoData.flatMap(UIImage.init(data:)).map(Image.init(uiImage:)))
    }
}

#Preview {
    VStack(spacing: 40) {
        ProfileHeader()
        ProfileHeader(name: "Peter", photo: Image(systemName: "graduationcap.fill"))
    }
    .padding()
    .frame(maxHeight: .infinity)
    .background(Theme.background)
}
