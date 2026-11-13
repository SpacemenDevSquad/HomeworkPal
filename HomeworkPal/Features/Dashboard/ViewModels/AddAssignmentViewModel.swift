import Combine
import Foundation

@MainActor
final class AddAssignmentViewModel: ObservableObject {
    private static let defaultDueHour = 23
    private static let defaultDueMinute = 59

    @Published var title = ""
    @Published var selectedCourseID: Course.ID?
    @Published var dueDate: Date

    let courses: [Course]

    init(courses: [Course], now: Date = .now, calendar: Calendar = .current) {
        self.courses = courses
        self.selectedCourseID = courses.first?.id
        self.dueDate = Self.defaultDueDate(from: now, calendar: calendar)
    }

    var canSave: Bool {
        !trimmedTitle.isEmpty && selectedCourse != nil
    }

    /// Builds the new assignment from the form, or returns `nil` if required fields are missing.
    func makeAssignment() -> Assignment? {
        guard canSave, let selectedCourse else { return nil }
        return Assignment(title: trimmedTitle, course: selectedCourse, dueDate: dueDate)
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
