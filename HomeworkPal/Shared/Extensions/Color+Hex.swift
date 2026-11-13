import SwiftUI

extension Color {
    private static let hexDigitCount = 6
    private static let maxChannelValue = 255.0

    /// Creates a color from a six-digit RGB hex string such as `"#FF8D28"`. Returns `nil` if the string is malformed.
    init?(hex: String) {
        let digits = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        guard digits.count == Self.hexDigitCount, let value = UInt32(digits, radix: 16) else { return nil }

        self.init(
            red: Double((value >> 16) & 0xFF) / Self.maxChannelValue,
            green: Double((value >> 8) & 0xFF) / Self.maxChannelValue,
            blue: Double(value & 0xFF) / Self.maxChannelValue
        )
    }
}
