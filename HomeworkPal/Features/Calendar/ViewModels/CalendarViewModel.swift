import Combine
import Foundation

@MainActor
final class CalendarViewModel: ObservableObject {
    private static let daysInWeek = 7

    @Published private(set) var assignments: [Assignment]
    /// The first day of the week being shown, respecting the locale's first weekday.
    @Published private(set) var weekStart: Date
    /// The day whose assignments are expanded. Only one day is expanded at a time.
    @Published private(set) var expandedDayID: CalendarDay.ID?

    /// The assignment awaiting confirmation before it's checked off. Drives the confirmation alert.
    @Published var pendingCompletion: Assignment?
    /// The assignment Apple's Add Event sheet is open for. Drives the calendar sheet.
    @Published var assignmentToAddToCalendar: Assignment?
    /// The day awaiting confirmation before all its assignments are added to Calendar. Drives the confirmation alert.
    @Published var dayPendingAddAll: CalendarDay?

    /// Assignments still waiting for their turn in Apple's sheet during Add All, in due-date order.
    private var queuedCalendarAssignments: [Assignment] = []
    private let calendar: Calendar
    /// Read on demand rather than stored, so "today" stays correct if the app stays open past midnight.
    private let currentDate: () -> Date

    init(
        assignments: [Assignment] = Assignment.sampleData,
        calendar: Calendar = .current,
        currentDate: @escaping () -> Date = { .now }
    ) {
        self.assignments = assignments
        self.calendar = calendar
        self.currentDate = currentDate
        self.weekStart = Self.startOfWeek(containing: currentDate(), calendar: calendar)
    }

    /// The seven days of the shown week, each with its open assignments.
    var days: [CalendarDay] {
        let openAssignments = assignments
            .filter { !$0.isCompleted }
            .sorted { $0.dueDate < $1.dueDate }
        let assignmentsByDay = Dictionary(grouping: openAssignments) { calendar.startOfDay(for: $0.dueDate) }
        let today = calendar.startOfDay(for: currentDate())

        return (0..<Self.daysInWeek).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: weekStart) else { return nil }
            return CalendarDay(date: date, assignments: assignmentsByDay[date] ?? [], isToday: date == today)
        }
    }

    /// From the first to the last day of the shown week, for the week title.
    var weekRange: Range<Date> {
        let lastDay = calendar.date(byAdding: .day, value: Self.daysInWeek - 1, to: weekStart) ?? weekStart
        return weekStart..<lastDay
    }

    var isShowingCurrentWeek: Bool {
        weekStart == Self.startOfWeek(containing: currentDate(), calendar: calendar)
    }

    func showPreviousWeek() {
        moveWeek(by: -1)
    }

    func showNextWeek() {
        moveWeek(by: 1)
    }

    func showCurrentWeek() {
        weekStart = Self.startOfWeek(containing: currentDate(), calendar: calendar)
        expandedDayID = nil
    }

    /// Expands the day to show every item, or collapses it if it's already open. Empty days have nothing to expand.
    func toggleExpansion(of day: CalendarDay) {
        guard !day.isEmpty else { return }
        expandedDayID = expandedDayID == day.id ? nil : day.id
    }

    func isExpanded(_ day: CalendarDay) -> Bool {
        expandedDayID == day.id
    }

    func isOverdue(_ assignment: Assignment) -> Bool {
        DueBucket.bucket(for: assignment.dueDate, now: currentDate(), calendar: calendar) == .overdue
    }

    /// Asks the user to confirm before checking the assignment off.
    func requestCompletion(for assignment: Assignment) {
        pendingCompletion = assignment
    }

    func markComplete(_ assignment: Assignment) {
        guard let index = assignments.firstIndex(where: { $0.id == assignment.id }) else { return }
        assignments[index].isCompleted = true
    }

    func requestCalendarEvent(for assignment: Assignment) {
        assignmentToAddToCalendar = assignment
    }

    func markAddedToCalendar(_ assignment: Assignment) {
        guard let index = assignments.firstIndex(where: { $0.id == assignment.id }) else { return }
        assignments[index].isAddedToCalendar = true
    }

    /// Asks the student to confirm before adding the day's remaining assignments. Days with nothing left to add are ignored.
    func requestAddAll(for day: CalendarDay) {
        guard !day.assignmentsNotAddedToCalendar.isEmpty else { return }
        dayPendingAddAll = day
    }

    /// Starts Add All: Apple's sheet opens for each of the day's not-yet-added assignments, one at a time.
    func addAllToCalendar(on day: CalendarDay) {
        // Re-read the day so anything added or completed since the confirmation was shown is respected.
        queuedCalendarAssignments = days.first { $0.id == day.id }?.assignmentsNotAddedToCalendar ?? []
        presentNextQueuedCalendarEvent()
    }

    /// Opens Apple's sheet for the next queued assignment once the previous sheet has closed.
    func presentNextQueuedCalendarEvent() {
        guard assignmentToAddToCalendar == nil else { return }
        // Skip anything completed or added since Add All started.
        while let next = queuedCalendarAssignments.first {
            queuedCalendarAssignments.removeFirst()
            if let current = assignments.first(where: { $0.id == next.id }), !current.isCompleted, !current.isAddedToCalendar {
                assignmentToAddToCalendar = current
                return
            }
        }
    }

    /// Cancel in Apple's sheet ends the whole Add All run rather than skipping to the next assignment.
    func cancelQueuedCalendarEvents() {
        queuedCalendarAssignments.removeAll()
    }

    private func moveWeek(by weekCount: Int) {
        guard let newWeekStart = calendar.date(byAdding: .weekOfYear, value: weekCount, to: weekStart) else { return }
        weekStart = newWeekStart
        expandedDayID = nil
    }

    private static func startOfWeek(containing date: Date, calendar: Calendar) -> Date {
        calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? calendar.startOfDay(for: date)
    }
}
