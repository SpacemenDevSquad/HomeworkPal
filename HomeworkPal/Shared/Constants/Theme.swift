import SwiftUI

/// App-wide design tokens backed by the asset catalog.
///
/// The palette follows a 60-30-10 split: tan `background` fills the screen, off-white `surface`
/// raises content into cards, and orange `accent` is reserved for fills. Orange is never used as
/// text because it lacks contrast against both the tan and off-white.
enum Theme {
    static let background = Color("AppBackground")
    static let surface = Color("SurfaceBackground")
    static let primaryText = Color("PrimaryText")
    static let secondaryText = Color("SecondaryText")
    static let accent = Color("AccentColor")

    static let cornerRadius: CGFloat = 14
    static let cardShadowOpacity = 0.08
    static let cardShadowRadius: CGFloat = 6
    static let cardShadowOffset: CGFloat = 2
}
