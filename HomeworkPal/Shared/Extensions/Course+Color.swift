import SwiftUI

extension Course {
    /// The display color for this class or activity, falling back to the app accent if the stored hex is invalid.
    var color: Color {
        Color(hex: colorHex) ?? Theme.accent
    }
}
