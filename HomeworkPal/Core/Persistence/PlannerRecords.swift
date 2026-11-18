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

    @Relationship(deleteRule: .cascade, inverse: \AssignmentRecord.course)
    var assignments: [AssignmentRecord]? = []

    init(_ course: Course) {
        id = course.id
        name = course.name
        colorHex = course.colorHex
    }

    var course: Course {
        Course(id: id, name: name, colorHex: colorHex)
    }
}

@Model
final class AssignmentRecord {
    var id = UUID()
    var title = ""
    var dueDate = Date.now
    var isCompleted = false
    var course: CourseRecord?

    init(_ assignment: Assignment, course: CourseRecord) {
        id = assignment.id
        title = assignment.title
        dueDate = assignment.dueDate
        isCompleted = assignment.isCompleted
        self.course = course
    }

    /// The value-type form, or `nil` if the record has lost its course and shouldn't be shown.
    var assignment: Assignment? {
        guard let course else { return nil }
        return Assignment(id: id, title: title, course: course.course, dueDate: dueDate, isCompleted: isCompleted)
    }
}
