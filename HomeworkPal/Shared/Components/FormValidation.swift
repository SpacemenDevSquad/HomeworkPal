import SwiftUI

/// Slides a view side to side a few times, like a head shake, to signal that something is missing.
///
/// Drive it by incrementing `attempts` inside `withAnimation`; each increment plays one shake.
struct ShakeEffect: GeometryEffect {
    private static let travel: CGFloat = 8
    private static let shakesPerAttempt: CGFloat = 3

    var animatableData: CGFloat

    init(attempts: Int) {
        animatableData = CGFloat(attempts)
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let offset = Self.travel * sin(animatableData * .pi * 2 * Self.shakesPerAttempt)
        return ProjectionTransform(CGAffineTransform(translationX: offset, y: 0))
    }
}

/// The "what to fix" callout shown at the top of a form after a save is rejected.
/// An icon plus text, so it doesn't rely on color alone.
struct ValidationBanner: View {
    let message: LocalizedStringResource

    var body: some View {
        Label {
            Text(message)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Theme.primaryText)
        } icon: {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Theme.accent)
        }
        .accessibilityElement(children: .combine)
    }
}

/// Shake timing and feedback shared by the add and edit forms.
struct RejectedSaveFeedback: ViewModifier {
    private static let shakeDuration = 0.45

    let attempts: Int
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            // With Reduce Motion on, the banner and haptic still explain the problem without the motion.
            .modifier(ShakeEffect(attempts: reduceMotion ? 0 : attempts))
            .animation(.linear(duration: Self.shakeDuration), value: attempts)
            .sensoryFeedback(.error, trigger: attempts)
    }
}

extension View {
    /// Shakes the view and plays an error haptic each time `attempts` goes up.
    func rejectedSaveFeedback(attempts: Int) -> some View {
        modifier(RejectedSaveFeedback(attempts: attempts))
    }
}
