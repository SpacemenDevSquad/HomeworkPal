import Foundation

/// A class or extracurricular activity that assignments belong to.
struct Course: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    var name: String
    /// Six-digit RGB hex string, kept as plain data so the model stays `Codable` and UI-framework free.
    var colorHex: String

    init(id: UUID = UUID(), name: String, colorHex: String) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
    }
}

// MARK: - Sample Data

extension Course {
    static let english = Course(name: "English", colorHex: "#0088FF")
    static let chemistry = Course(name: "Chemistry", colorHex: "#FF8D28")
    static let biology = Course(name: "Biology", colorHex: "#34C759")
    static let calculus = Course(name: "Calculus", colorHex: "#FF383C")
    static let soccer = Course(name: "Soccer", colorHex: "#00C3D0")
    static let theater = Course(name: "Theater", colorHex: "#CB30E0")

    static let sampleData: [Course] = [english, chemistry, biology, calculus, soccer, theater]
}
