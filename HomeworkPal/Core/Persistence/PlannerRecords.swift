import Foundation
import SwiftData

// Stored records are kept separate from the `Course` and `Assignment` value types so the rest of the app
// never touches SwiftData. Every property has a default, relationships are optional, and nothing is
// marked `.unique`, because those are CloudKit's requirements for the planned private iCloud sync.

@Model
final class CourseRecord {
    var id = UUID()
    var name = ""
    var colorHex = ""
    /// Keeps classes in the order the student added them.
    var createdAt = Date.now
    /// `CourseKind` raw value. Records saved before activities existed default to a class.
    var kindRawValue = CourseKind.schoolClass.rawValue
    var location = ""

    @Relationship(deleteRule: .cascade, inverse: \AssignmentRecord.course)
    var assignments: [AssignmentRecord]? = []

    init(_ course: Course) {
        id = course.id
        apply(course)
    }

    /// Copies every editable field from `course`. The id and creation date never change.
    func apply(_ course: Course) {
        name = course.name
        colorHex = course.colorHex
        kindRawValue = course.kind.rawValue
        location = course.location ?? ""
    }

    var course: Course {
        Course(
            id: id,
            name: name,
            colorHex: colorHex,
            kind: CourseKind(rawValue: kindRawValue) ?? .schoolClass,
            location: location.isEmpty ? nil : location
        )
    }
}

@Model
final class AssignmentRecord {
    var id = UUID()
    var title = ""
    var dueDate = Date.now
    var isCompleted = false
    var isAddedToCalendar = false
    var notes = ""
    var course: CourseRecord?

    init(_ assignment: Assignment, course: CourseRecord) {
        id = assignment.id
        apply(assignment, course: course)
    }

    /// Copies every editable field from `assignment`, including which course it belongs to.
    func apply(_ assignment: Assignment, course: CourseRecord) {
        title = assignment.title
        dueDate = assignment.dueDate
        isCompleted = assignment.isCompleted
        isAddedToCalendar = assignment.isAddedToCalendar
        notes = assignment.notes
        self.course = course
    }

    /// The value-type form, or `nil` if the record has lost its course and shouldn't be shown.
    var assignment: Assignment? {
        guard let course else { return nil }
        return Assignment(
            id: id,
            title: title,
            course: course.course,
            dueDate: dueDate,
            isCompleted: isCompleted,
            isAddedToCalendar: isAddedToCalendar,
            notes: notes
        )
    }
}

/// The student's profile. Two devices that each saved one before syncing can briefly leave two records,
/// so readers take the most recently updated.
@Model
final class ProfileRecord {
    var name = ""
    /// Kept outside the database file, and synced to iCloud as a file, since photos are large.
    @Attribute(.externalStorage) var photoData: Data?
    var updatedAt = Date.now

    init(_ profile: UserProfile) {
        name = profile.name
        photoData = profile.photoData
    }

    var profile: UserProfile {
        UserProfile(name: name, photoData: photoData)
    }
}
