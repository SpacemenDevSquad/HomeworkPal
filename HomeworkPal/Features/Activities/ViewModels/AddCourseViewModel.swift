import Combine
import Foundation

@MainActor
final class AddCourseViewModel: ObservableObject {
    @Published var name = ""
    @Published var selectedColorHex: String

    let colorOptions = CourseColorOption.all

    /// Normalized names already in use, so two classes can't share a name and become indistinguishable.
    private let existingNames: Set<String>

    init(existingCourses: [Course]) {
        existingNames = Set(existingCourses.map { Self.normalized($0.name) })

        // Defaults to the first color not already taken, so a new class stands apart from the others.
        let usedHexes = Set(existingCourses.map(\.colorHex))
        let firstUnused = CourseColorOption.all.first { !usedHexes.contains($0.hex) }
        selectedColorHex = (firstUnused ?? CourseColorOption.all.first)?.hex ?? ""
    }

    var isDuplicateName: Bool {
        existingNames.contains(Self.normalized(name))
    }

    var canSave: Bool {
        !trimmedName.isEmpty && !isDuplicateName
    }

    /// Builds the new course from the form, or returns `nil` if the name is missing or already used.
    func makeCourse() -> Course? {
        guard canSave else { return nil }
        return Course(name: trimmedName, colorHex: selectedColorHex)
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func normalized(_ name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
