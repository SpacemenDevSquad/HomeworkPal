import Combine
import Foundation

/// Which way the calendar moves when the shown week changes, so the week can slide in from the matching side.
enum WeekChangeDirection: Equatable {
    case forward
    case backward
}

@MainActor
final class CalendarViewModel: ObservableObject {
    private static let daysInWeek = 7

    /// The first day of the week being shown, respecting the locale's first weekday.
    @Published private(set) var weekStart: Date
    /// The start of the day whose assignments are listed below the week strip. Always within the shown week.
    @Published private(set) var selectedDate: Date

    /// The assignment Apple's Add Event sheet is open for. Drives the calendar sheet.
    @Published var assignmentToAddToCalendar: Assignment?
    /// The day awaiting confirmation before all its assignments are added to Calendar. Drives the confirmation alert.
    @Published var dayPendingAddAll: CalendarDay?

    /// Assignments still waiting for their turn in Apple's sheet during Add All, in due-date order.
    private var queuedCalendarAssignments: [Assignment] = []
    private let planner: PlannerViewModel
    private let calendar: Calendar
    /// Read on demand rather than stored, so "today" stays correct if the app stays open past midnight.
    private let currentDate: () -> Date

    init(
        planner: PlannerViewModel,
        calendar: Calendar = .current,
        currentDate: @escaping () -> Date = { .now }
    ) {
        self.planner = planner
        self.calendar = calendar
        self.currentDate = currentDate
        let today = calendar.startOfDay(for: currentDate())
        self.weekStart = Self.startOfWeek(containing: today, calendar: calendar)
        self.selectedDate = today
        PlannerObservation.forwardChanges(from: planner, to: self)
    }

    /// The seven days of the shown week, each with everything due on it.
    var days: [CalendarDay] {
        let sortedAssignments = planner.assignments.sorted { $0.dueDate < $1.dueDate }
        let assignmentsByDay = Dictionary(grouping: sortedAssignments) { calendar.startOfDay(for: $0.dueDate) }

        return (0..<Self.daysInWeek).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: weekStart) else { return nil }
            return CalendarDay(date: date, assignments: assignmentsByDay[date] ?? [], isToday: date == today)
        }
    }

    /// The day listed below the week strip.
    var selectedDay: CalendarDay {
        days.first { $0.date == selectedDate }
            ?? CalendarDay(date: selectedDate, assignments: [], isToday: selectedDate == today)
    }

    /// `true` while today is the selected day, so the Today button can hide itself.
    var isShowingToday: Bool {
        selectedDate == today
    }

    var isShowingCurrentWeek: Bool {
        weekStart == Self.startOfWeek(containing: today, calendar: calendar)
    }

    func isSelected(_ day: CalendarDay) -> Bool {
        day.date == selectedDate
    }

    func select(_ day: CalendarDay) {
        selectedDate = day.date
    }

    func showPreviousWeek() {
        moveWeek(by: -1)
    }

    func showNextWeek() {
        moveWeek(by: 1)
    }

    func showToday() {
        show(today)
    }

    /// Shows the week containing `date` and selects that day, such as a day picked from the month calendar.
    func show(_ date: Date) {
        let day = calendar.startOfDay(for: date)
        weekStart = Self.startOfWeek(containing: day, calendar: calendar)
        selectedDate = day
    }

    /// Whether reaching the week containing `date` means moving forward or backward from the shown week.
    func direction(toWeekContaining date: Date) -> WeekChangeDirection {
        Self.startOfWeek(containing: date, calendar: calendar) < weekStart ? .backward : .forward
    }

    /// The day the month picker opens on.
    var pickerStartDate: Date {
        selectedDate
    }

    /// Completed work is done, so it's never shown as overdue.
    func isOverdue(_ assignment: Assignment) -> Bool {
        !assignment.isCompleted
            && DueBucket.bucket(for: assignment.dueDate, now: currentDate(), calendar: calendar) == .overdue
    }

    /// Checks off or reopens the assignment. It stays on its day either way.
    func toggleCompletion(of assignment: Assignment) {
        if assignment.isCompleted {
            planner.markIncomplete(assignment)
        } else {
            planner.markComplete(assignment)
        }
    }

    func requestCalendarEvent(for assignment: Assignment) {
        assignmentToAddToCalendar = assignment
    }

    func markAddedToCalendar(_ assignment: Assignment) {
        planner.markAddedToCalendar(assignment)
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
            if let current = planner.assignments.first(where: { $0.id == next.id }), !current.isCompleted, !current.isAddedToCalendar {
                assignmentToAddToCalendar = current
                return
            }
        }
    }

    /// Cancel in Apple's sheet ends the whole Add All run rather than skipping to the next assignment.
    func cancelQueuedCalendarEvents() {
        queuedCalendarAssignments.removeAll()
    }

    private var today: Date {
        calendar.startOfDay(for: currentDate())
    }

    /// Moving into the current week selects today; any other week keeps the same weekday selected.
    private func moveWeek(by weekCount: Int) {
        guard let newWeekStart = calendar.date(byAdding: .weekOfYear, value: weekCount, to: weekStart) else { return }
        if newWeekStart == Self.startOfWeek(containing: today, calendar: calendar) {
            show(today)
            return
        }
        let newSelection = calendar.date(byAdding: .weekOfYear, value: weekCount, to: selectedDate) ?? newWeekStart
        weekStart = newWeekStart
        selectedDate = newSelection
    }

    private static func startOfWeek(containing date: Date, calendar: Calendar) -> Date {
        calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? calendar.startOfDay(for: date)
    }
}
