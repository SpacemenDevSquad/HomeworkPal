import Combine
import Foundation

@MainActor
final class AddAssignmentViewModel: ObservableObject {
    private static let defaultDueHour = 23
    private static let defaultDueMinute = 59

    @Published var title = ""
    @Published var selectedCourseID: Course.ID?
    @Published var dueDate: Date
    @Published var addToCalendar = false
    @Published var notes = ""

    let courses: [Course]
    /// The assignment being edited, or `nil` when adding a new one.
    let editingAssignment: Assignment?

    init(courses: [Course], editing editingAssignment: Assignment? = nil, now: Date = .now, calendar: Calendar = .current) {
        self.courses = courses
        self.editingAssignment = editingAssignment
        // Classes are listed first, so the first class is the natural default.
        self.selectedCourseID = editingAssignment?.course.id
            ?? (courses.first { $0.kind == .schoolClass } ?? courses.first)?.id
        self.dueDate = editingAssignment?.dueDate ?? Self.defaultDueDate(from: now, calendar: calendar)
        self.title = editingAssignment?.title ?? ""
        self.notes = editingAssignment?.notes ?? ""
    }

    var isEditing: Bool {
        editingAssignment != nil
    }

    /// Classes, listed above activities in the picker.
    var classes: [Course] {
        courses.filter { $0.kind == .schoolClass }
    }

    var activities: [Course] {
        courses.filter { $0.kind == .activity }
    }

    var isMissingTitle: Bool {
        trimmedTitle.isEmpty
    }

    /// What the student needs to fix before saving, or `nil` when the form is ready.
    var validationMessage: LocalizedStringResource? {
        if courses.isEmpty {
            return "Add a class or activity in the Activities tab first."
        }
        if isMissingTitle {
            return "Give this assignment a title."
        }
        if selectedCourse == nil {
            return "Choose a class or activity for this assignment."
        }
        return nil
    }

    var canSave: Bool {
        validationMessage == nil
    }

    /// Builds the new assignment from the form, or returns `nil` if required fields are missing.
    func makeAssignment() -> Assignment? {
        guard canSave, let selectedCourse else { return nil }
        guard let editingAssignment else {
            return Assignment(title: trimmedTitle, course: selectedCourse, dueDate: dueDate, notes: trimmedNotes)
        }
        // Editing keeps the id and the completed and calendar status.
        var edited = editingAssignment
        edited.title = trimmedTitle
        edited.course = selectedCourse
        edited.dueDate = dueDate
        edited.notes = trimmedNotes
        return edited
    }

    private var trimmedNotes: String {
        notes.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var selectedCourse: Course? {
        courses.first { $0.id == selectedCourseID }
    }

    /// Defaults new work to tomorrow at 11:59 PM, the most common due time.
    private static func defaultDueDate(from now: Date, calendar: Calendar) -> Date {
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) ?? now
        return calendar.date(bySettingHour: defaultDueHour, minute: defaultDueMinute, second: 0, of: tomorrow) ?? tomorrow
    }
}
