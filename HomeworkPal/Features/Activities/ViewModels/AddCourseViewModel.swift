import Combine
import Foundation

@MainActor
final class AddCourseViewModel: ObservableObject {
    /// The course being edited, or `nil` when adding a new one.
    let editingCourse: Course?

    @Published var kind: CourseKind
    @Published var name = ""
    @Published var selectedColorHex: String
    @Published var location = ""

    let colorOptions = CourseColorOption.all

    /// Normalized names already in use, so two classes can't share a name and become indistinguishable.
    private let existingNames: Set<String>

    init(existingCourses: [Course], kind: CourseKind = .schoolClass, editing editingCourse: Course? = nil) {
        self.editingCourse = editingCourse
        self.kind = editingCourse?.kind ?? kind
        // A course being edited may keep its own name.
        existingNames = Set(existingCourses.filter { $0.id != editingCourse?.id }.map { Self.normalized($0.name) })

        // Defaults to the first color not already taken, so a new class stands apart from the others.
        let usedHexes = Set(existingCourses.map(\.colorHex))
        let firstUnused = CourseColorOption.suggestionOrder.first { !usedHexes.contains($0.hex) }
        selectedColorHex = (firstUnused ?? CourseColorOption.suggestionOrder.first)?.hex ?? ""

        if let editingCourse {
            name = editingCourse.name
            selectedColorHex = editingCourse.colorHex
            location = editingCourse.location ?? ""
        }
    }

    var isEditing: Bool {
        editingCourse != nil
    }

    /// The preset matching the current selection, used to name the color in the picker's header.
    var selectedColorOption: CourseColorOption? {
        colorOptions.first { $0.hex == selectedColorHex }
    }

    var isDuplicateName: Bool {
        existingNames.contains(Self.normalized(name))
    }

    var isMissingName: Bool {
        trimmedName.isEmpty
    }

    /// What the student needs to fix before saving, or `nil` when the form is ready.
    var validationMessage: LocalizedStringResource? {
        if isMissingName {
            return kind == .activity ? "Give this activity a name." : "Give this class a name."
        }
        if isDuplicateName {
            return "You already have a class or activity named \"\(trimmedName)\". Choose a different name."
        }
        return nil
    }

    var canSave: Bool {
        validationMessage == nil
    }

    /// Builds the new course from the form, or returns `nil` if the name is missing or already used.
    func makeCourse() -> Course? {
        guard canSave else { return nil }
        let trimmedLocation = location.trimmingCharacters(in: .whitespacesAndNewlines)
        return Course(
            id: editingCourse?.id ?? UUID(),
            name: trimmedName,
            colorHex: selectedColorHex,
            kind: kind,
            location: trimmedLocation.isEmpty ? nil : trimmedLocation
        )
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func normalized(_ name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
