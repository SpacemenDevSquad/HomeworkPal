import Foundation

/// Whether a course is a school class or an extracurricular activity. They're listed on separate tabs.
nonisolated enum CourseKind: String, CaseIterable, Codable, Sendable, Identifiable {
    case schoolClass = "class"
    case activity

    var id: String { rawValue }
}

/// A class or extracurricular activity that assignments belong to.
///
/// `nonisolated` because it's plain data that SwiftData records convert to and from off the main actor.
nonisolated struct Course: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    var name: String
    /// Six-digit RGB hex string, kept as plain data so the model stays `Codable` and UI-framework free.
    var colorHex: String
    var kind: CourseKind
    /// Where it meets, such as a room or field. Optional.
    var location: String?

    init(
        id: UUID = UUID(),
        name: String,
        colorHex: String,
        kind: CourseKind = .schoolClass,
        location: String? = nil
    ) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.kind = kind
        self.location = location
    }
}

// MARK: - Sample Data

#if DEBUG
/// Preview and test data only. Debug-only so it can never ship in a release build.
extension Course {
    static let english = Course(name: "English", colorHex: "#5A7FC2")
    static let chemistry = Course(name: "Chemistry", colorHex: "#D98E4F")
    static let biology = Course(name: "Biology", colorHex: "#6FA772")
    static let calculus = Course(name: "Calculus", colorHex: "#C8605A")
    static let soccer = Course(name: "Soccer", colorHex: "#4A9BA3", kind: .activity, location: "North Field")
    static let theater = Course(name: "Theater", colorHex: "#8C6BB8", kind: .activity)

    static let sampleData: [Course] = [english, chemistry, biology, calculus, soccer, theater]
}
#endif
