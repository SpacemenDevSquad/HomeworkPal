import Combine
import Foundation

@MainActor
final class AddCourseViewModel: ObservableObject {
    private static let defaultRepeatMonths = 3
    private static let defaultDurationMinutes = 60
    /// Activities usually happen after school; classes during it.
    private static let defaultActivityStartHour = 15
    private static let defaultClassStartHour = 9

    /// The course being edited, or `nil` when adding a new one.
    let editingCourse: Course?

    @Published var kind: CourseKind
    @Published var name = ""
    @Published var selectedColorHex: String
    /// The days it repeats on. Empty means it has no schedule, and the time fields are hidden.
    @Published var selectedWeekdays: Set<Weekday> = []
    @Published var startTime: Date
    @Published var endTime: Date
    @Published var repeatsUntil: Date
    @Published var location = ""

    let colorOptions = CourseColorOption.all

    /// Normalized names already in use, so two classes can't share a name and become indistinguishable.
    private let existingNames: Set<String>
    private let calendar: Calendar

    init(
        existingCourses: [Course],
        kind: CourseKind = .schoolClass,
        editing editingCourse: Course? = nil,
        calendar: Calendar = .current,
        now: Date = .now
    ) {
        self.editingCourse = editingCourse
        self.kind = editingCourse?.kind ?? kind
        self.calendar = calendar
        // A course being edited may keep its own name.
        existingNames = Set(existingCourses.filter { $0.id != editingCourse?.id }.map { Self.normalized($0.name) })

        // Defaults to the first color not already taken, so a new class stands apart from the others.
        let usedHexes = Set(existingCourses.map(\.colorHex))
        let firstUnused = CourseColorOption.suggestionOrder.first { !usedHexes.contains($0.hex) }
        selectedColorHex = (firstUnused ?? CourseColorOption.suggestionOrder.first)?.hex ?? ""

        let startHour = kind == .activity ? Self.defaultActivityStartHour : Self.defaultClassStartHour
        let startOfToday = calendar.startOfDay(for: now)
        let start = calendar.date(bySettingHour: startHour, minute: 0, second: 0, of: now) ?? now
        startTime = start
        endTime = calendar.date(byAdding: .minute, value: Self.defaultDurationMinutes, to: start) ?? start
        repeatsUntil = calendar.date(byAdding: .month, value: Self.defaultRepeatMonths, to: startOfToday) ?? startOfToday

        if let editingCourse {
            fill(from: editingCourse, now: now)
        }
    }

    var isEditing: Bool {
        editingCourse != nil
    }

    /// The preset matching the current selection, used to name the color in the picker's header.
    var selectedColorOption: CourseColorOption? {
        colorOptions.first { $0.hex == selectedColorHex }
    }

    var hasSchedule: Bool {
        !selectedWeekdays.isEmpty
    }

    var isDuplicateName: Bool {
        existingNames.contains(Self.normalized(name))
    }

    /// A schedule whose end time isn't after its start time can't be saved.
    var hasInvalidTimeRange: Bool {
        hasSchedule && minutesAfterMidnight(endTime) <= minutesAfterMidnight(startTime)
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
        if hasInvalidTimeRange {
            return "Set the end time later than the start time."
        }
        return nil
    }

    var canSave: Bool {
        validationMessage == nil
    }

    func toggleWeekday(_ weekday: Weekday) {
        if selectedWeekdays.contains(weekday) {
            selectedWeekdays.remove(weekday)
        } else {
            selectedWeekdays.insert(weekday)
        }
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
            schedule: schedule,
            location: trimmedLocation.isEmpty ? nil : trimmedLocation
        )
    }

    private var schedule: CourseSchedule? {
        guard hasSchedule else { return nil }
        return CourseSchedule(
            weekdays: selectedWeekdays,
            startMinutes: minutesAfterMidnight(startTime),
            endMinutes: minutesAfterMidnight(endTime),
            repeatsUntil: calendar.startOfDay(for: repeatsUntil)
        )
    }

    private func fill(from course: Course, now: Date) {
        name = course.name
        selectedColorHex = course.colorHex
        location = course.location ?? ""
        guard let schedule = course.schedule else { return }
        selectedWeekdays = schedule.weekdays
        let startOfToday = calendar.startOfDay(for: now)
        startTime = calendar.date(byAdding: .minute, value: schedule.startMinutes, to: startOfToday) ?? startTime
        endTime = calendar.date(byAdding: .minute, value: schedule.endMinutes, to: startOfToday) ?? endTime
        repeatsUntil = schedule.repeatsUntil
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func minutesAfterMidnight(_ date: Date) -> Int {
        let components = calendar.dateComponents([.hour, .minute], from: date)
        return (components.hour ?? 0) * CourseSchedule.minutesPerHour + (components.minute ?? 0)
    }

    private static func normalized(_ name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
