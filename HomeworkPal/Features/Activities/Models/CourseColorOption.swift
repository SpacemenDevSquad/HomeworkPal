import Foundation

/// A preset color a student can give a new class or activity.
///
/// The palette is deliberately muted: softer tones sit calmly on the cream cards while staying
/// distinct from one another as a stripe or dot. Presets rather than a free color picker keep
/// every label legible.
struct CourseColorOption: Identifiable, Sendable {
    let name: LocalizedStringResource
    let hex: String

    var id: String { hex }

    static let red = CourseColorOption(name: "Red", hex: "#C8605A")
    static let coral = CourseColorOption(name: "Coral", hex: "#D9806A")
    static let orange = CourseColorOption(name: "Orange", hex: "#D98E4F")
    static let mustard = CourseColorOption(name: "Mustard", hex: "#D4A94A")
    static let olive = CourseColorOption(name: "Olive", hex: "#A3A355")
    static let lime = CourseColorOption(name: "Lime", hex: "#8DAE5B")
    static let green = CourseColorOption(name: "Green", hex: "#6FA772")
    static let jade = CourseColorOption(name: "Jade", hex: "#4FA08A")
    static let teal = CourseColorOption(name: "Teal", hex: "#4A9BA3")
    static let sky = CourseColorOption(name: "Sky", hex: "#5E9BC9")
    static let blue = CourseColorOption(name: "Blue", hex: "#5A7FC2")
    static let indigo = CourseColorOption(name: "Indigo", hex: "#6E6DBB")
    static let violet = CourseColorOption(name: "Violet", hex: "#8C6BB8")
    static let plum = CourseColorOption(name: "Plum", hex: "#A866A8")
    static let orchid = CourseColorOption(name: "Orchid", hex: "#C46A9C")
    static let rose = CourseColorOption(name: "Rose", hex: "#CF6E80")
    static let brown = CourseColorOption(name: "Brown", hex: "#A07A5C")
    static let slate = CourseColorOption(name: "Slate", hex: "#6E7F91")

    /// Every preset in hue order, so the picker reads as a smooth rainbow.
    static let all: [CourseColorOption] = [
        red, coral, orange, mustard, olive, lime,
        green, jade, teal, sky, blue, indigo,
        violet, plum, orchid, rose, brown, slate
    ]

    /// The order new classes are offered colors in. Neighbors in the rainbow are close in hue,
    /// so suggestions jump around the wheel to keep each new class clearly different.
    static let suggestionOrder: [CourseColorOption] = [
        blue, orange, green, red, teal, violet,
        mustard, rose, indigo, jade, plum, sky,
        coral, lime, olive, orchid, brown, slate
    ]
}
