import Foundation

/// A preset color a student can give a new class or activity.
///
/// Presets rather than a free color picker keep every label legible as a stripe or dot on the cream cards.
struct CourseColorOption: Identifiable, Sendable {
    let name: LocalizedStringResource
    let hex: String

    var id: String { hex }

    static let all: [CourseColorOption] = [
        CourseColorOption(name: "Blue", hex: "#0088FF"),
        CourseColorOption(name: "Orange", hex: "#FF8D28"),
        CourseColorOption(name: "Green", hex: "#34C759"),
        CourseColorOption(name: "Red", hex: "#FF383C"),
        CourseColorOption(name: "Teal", hex: "#00C3D0"),
        CourseColorOption(name: "Purple", hex: "#CB30E0"),
        CourseColorOption(name: "Yellow", hex: "#FFCC00"),
        CourseColorOption(name: "Pink", hex: "#FF2D55"),
        CourseColorOption(name: "Indigo", hex: "#6155F5"),
        CourseColorOption(name: "Brown", hex: "#AC7F5E")
    ]
}
