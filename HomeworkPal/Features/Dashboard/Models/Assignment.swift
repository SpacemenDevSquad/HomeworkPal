import Foundation

/// A single item with a due date, belonging to a class or activity.
struct Assignment: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    var title: String
    var course: Course
    var dueDate: Date
    var isCompleted: Bool

    init(id: UUID = UUID(), title: String, course: Course, dueDate: Date, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.course = course
        self.dueDate = dueDate
        self.isCompleted = isCompleted
    }
}

// MARK: - Sample Data

extension Assignment {
    static var sampleData: [Assignment] {
        let calendar = Calendar.current
        let now = Date.now

        func date(days: Int, hour: Int, minute: Int = 0) -> Date {
            let day = calendar.date(byAdding: .day, value: days, to: now) ?? now
            return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
        }

        return [
            Assignment(title: "Reading response: Ch. 4", course: .english, dueDate: date(days: -1, hour: 8)),
            Assignment(title: "Problem set 6", course: .calculus, dueDate: date(days: 0, hour: 23, minute: 59)),
            Assignment(title: "Bring permission form", course: .soccer, dueDate: date(days: 0, hour: 23, minute: 30)),
            Assignment(title: "Cell structure quiz", course: .biology, dueDate: date(days: 1, hour: 9)),
            Assignment(title: "Lab report: Titration", course: .chemistry, dueDate: date(days: 3, hour: 23, minute: 59)),
            Assignment(title: "Turn in costume measurements", course: .theater, dueDate: date(days: 4, hour: 15)),
            Assignment(title: "Unit 3 test", course: .calculus, dueDate: date(days: 5, hour: 10)),
            Assignment(title: "Research essay", course: .english, dueDate: date(days: 14, hour: 23, minute: 59)),
            Assignment(title: "Ecosystem poster", course: .biology, dueDate: date(days: 21, hour: 8))
        ]
    }
}
