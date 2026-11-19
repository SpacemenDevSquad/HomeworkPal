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
    // The schedule is flattened into plain fields so older records migrate with no schedule
    // (no weekdays) and CloudKit sync stays simple.
    /// `Weekday` raw values; empty means no schedule.
    var scheduleWeekdays: [Int] = []
    var scheduleStartMinutes = 0
    var scheduleEndMinutes = 0
    var scheduleRepeatsUntil: Date?

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
        scheduleWeekdays = course.schedule?.weekdays.map(\.rawValue).sorted() ?? []
        scheduleStartMinutes = course.schedule?.startMinutes ?? 0
        scheduleEndMinutes = course.schedule?.endMinutes ?? 0
        scheduleRepeatsUntil = course.schedule?.repeatsUntil
    }

    var course: Course {
        Course(
            id: id,
            name: name,
            colorHex: colorHex,
            kind: CourseKind(rawValue: kindRawValue) ?? .schoolClass,
            schedule: schedule,
            location: location.isEmpty ? nil : location
        )
    }

    private var schedule: CourseSchedule? {
        let weekdays = Set(scheduleWeekdays.compactMap(Weekday.init(rawValue:)))
        guard !weekdays.isEmpty, let scheduleRepeatsUntil else { return nil }
        return CourseSchedule(
            weekdays: weekdays,
            startMinutes: scheduleStartMinutes,
            endMinutes: scheduleEndMinutes,
            repeatsUntil: scheduleRepeatsUntil
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
