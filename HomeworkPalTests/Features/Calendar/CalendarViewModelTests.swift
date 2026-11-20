import Foundation
import Testing
@testable import HomeworkPal

@MainActor
struct CalendarViewModelTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/New_York") ?? .gmt
        calendar.firstWeekday = 1
        return calendar
    }()

    /// Wednesday, November 18, 2026 at noon. The week runs Sunday Nov 15 through Saturday Nov 21.
    private var now: Date {
        date(day: 18, hour: 12)
    }

    private func date(month: Int = 11, day: Int, hour: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: month, day: day, hour: hour)) ?? .distantPast
    }

    private func makeViewModel(assignments: [Assignment]) -> CalendarViewModel {
        let fixedNow = now
        return CalendarViewModel(
            planner: PlannerViewModel(courses: Course.sampleData, assignments: assignments),
            calendar: calendar,
            currentDate: { fixedNow }
        )
    }

    @Test func daysCoverTheCurrentWeekStartingOnFirstWeekday() {
        let viewModel = makeViewModel(assignments: [])

        #expect(viewModel.days.map(\.date) == (15...21).map { date(day: $0) })
        #expect(viewModel.days.filter(\.isToday).map(\.date) == [date(day: 18)])
        #expect(viewModel.isShowingCurrentWeek)
    }

    @Test func assignmentsAreGroupedOnTheirDueDaySoonestFirst() {
        let evening = Assignment(title: "Essay", course: .english, dueDate: date(day: 17, hour: 23))
        let morning = Assignment(title: "Quiz", course: .biology, dueDate: date(day: 17, hour: 9))
        let viewModel = makeViewModel(assignments: [evening, morning])

        let tuesday = viewModel.days.first { $0.date == date(day: 17) }

        #expect(tuesday?.assignments == [morning, evening])
        #expect(viewModel.days.filter { !$0.isEmpty }.count == 1)
    }

    @Test func assignmentsOutsideTheWeekAreExcluded() {
        let nextWeek = Assignment(title: "Project", course: .theater, dueDate: date(day: 22, hour: 9))
        let viewModel = makeViewModel(assignments: [nextWeek])

        #expect(viewModel.days.allSatisfy { $0.isEmpty })
    }

    @Test func completedAssignmentsStayOnTheirDay() {
        let completed = Assignment(title: "Done", course: .english, dueDate: date(day: 18, hour: 9), isCompleted: true)
        let viewModel = makeViewModel(assignments: [completed])

        #expect(viewModel.selectedDay.assignments == [completed])
        #expect(!viewModel.isOverdue(completed))
    }

    @Test func dayWithThreeItemsIsBusy() {
        let assignments = (9...11).map { Assignment(title: "Item \($0)", course: .calculus, dueDate: date(day: 19, hour: $0)) }
        let viewModel = makeViewModel(assignments: assignments + [Assignment(title: "Solo", course: .english, dueDate: date(day: 20, hour: 9))])

        #expect(viewModel.days.filter(\.isBusy).map(\.date) == [date(day: 19)])
    }


    @Test func nextAndPreviousWeekMoveByOneWeek() {
        let viewModel = makeViewModel(assignments: [])

        viewModel.showNextWeek()
        #expect(viewModel.weekStart == date(day: 22))
        #expect(!viewModel.isShowingCurrentWeek)

        viewModel.showPreviousWeek()
        viewModel.showPreviousWeek()
        #expect(viewModel.weekStart == date(day: 8))
    }

    @Test func showTodayReturnsToTodayFromAnotherWeek() {
        let viewModel = makeViewModel(assignments: [])

        viewModel.showNextWeek()
        #expect(!viewModel.isShowingToday)
        viewModel.showToday()

        #expect(viewModel.isShowingCurrentWeek)
        #expect(viewModel.selectedDate == date(day: 18))
        #expect(viewModel.isShowingToday)
    }

    @Test func showJumpsToTheWeekContainingTheDateAndSelectsIt() {
        let viewModel = makeViewModel(assignments: [])

        // Wednesday, January 13, 2027 falls in the week starting Sunday, January 10.
        viewModel.show(calendar.date(from: DateComponents(year: 2027, month: 1, day: 13, hour: 9)) ?? .distantPast)

        #expect(viewModel.weekStart == calendar.date(from: DateComponents(year: 2027, month: 1, day: 10)))
        #expect(viewModel.selectedDate == calendar.date(from: DateComponents(year: 2027, month: 1, day: 13)))
        #expect(!viewModel.isShowingCurrentWeek)
    }

    @Test func directionComparesAgainstTheShownWeek() {
        let viewModel = makeViewModel(assignments: [])

        #expect(viewModel.direction(toWeekContaining: date(day: 25)) == .forward)
        #expect(viewModel.direction(toWeekContaining: date(day: 3)) == .backward)

        viewModel.showNextWeek()
        #expect(viewModel.direction(toWeekContaining: now) == .backward)
    }

    @Test func pickerOpensOnTheSelectedDay() {
        let viewModel = makeViewModel(assignments: [])
        #expect(viewModel.pickerStartDate == date(day: 18))

        viewModel.showNextWeek()
        #expect(viewModel.pickerStartDate == date(day: 25))
    }

    @Test func weekNavigationCrossesMonthBoundaries() {
        let viewModel = makeViewModel(assignments: [])

        viewModel.showNextWeek()
        viewModel.showNextWeek()

        #expect(viewModel.days.map(\.date).last == date(month: 12, day: 5))
    }

    @Test func todayIsSelectedAtFirst() {
        let viewModel = makeViewModel(assignments: [])

        #expect(viewModel.selectedDate == date(day: 18))
        #expect(viewModel.isShowingToday)
    }

    @Test func selectingADayListsItsAssignments() throws {
        let mondayQuiz = Assignment(title: "Quiz", course: .biology, dueDate: date(day: 16, hour: 9))
        let viewModel = makeViewModel(assignments: [mondayQuiz])
        let monday = try #require(viewModel.days.first { $0.date == date(day: 16) })

        viewModel.select(monday)

        #expect(viewModel.isSelected(monday))
        #expect(viewModel.selectedDay.assignments == [mondayQuiz])
        #expect(!viewModel.isShowingToday)
    }

    @Test func changingWeekKeepsTheSameWeekdaySelected() throws {
        let viewModel = makeViewModel(assignments: [])
        let monday = try #require(viewModel.days.first { $0.date == date(day: 16) })
        viewModel.select(monday)

        viewModel.showNextWeek()
        #expect(viewModel.selectedDate == date(day: 23))

        // Coming back to this week selects today rather than the remembered weekday.
        viewModel.showPreviousWeek()
        #expect(viewModel.selectedDate == date(day: 18))
    }

    @Test func pastDueAssignmentIsOverdue() {
        let pastDue = Assignment(title: "Late", course: .english, dueDate: date(day: 18, hour: 8))
        let upcoming = Assignment(title: "Soon", course: .english, dueDate: date(day: 18, hour: 20))
        let viewModel = makeViewModel(assignments: [pastDue, upcoming])

        #expect(viewModel.isOverdue(pastDue))
        #expect(!viewModel.isOverdue(upcoming))
    }

    @Test func checkingOffKeepsTheAssignmentOnItsDayAndCanBeUndone() {
        let assignment = Assignment(title: "Essay", course: .english, dueDate: date(day: 18, hour: 20))
        let viewModel = makeViewModel(assignments: [assignment])

        viewModel.toggleCompletion(of: assignment)
        #expect(viewModel.selectedDay.assignments.map(\.isCompleted) == [true])

        viewModel.toggleCompletion(of: viewModel.selectedDay.assignments[0])
        #expect(viewModel.selectedDay.assignments.map(\.isCompleted) == [false])
    }

    @Test func requestCalendarEventSetsAssignment() {
        let assignment = Assignment(title: "Essay", course: .english, dueDate: date(day: 19, hour: 9))
        let viewModel = makeViewModel(assignments: [assignment])

        viewModel.requestCalendarEvent(for: assignment)

        #expect(viewModel.assignmentToAddToCalendar == assignment)
    }

    @Test func markAddedToCalendarSetsFlagAndKeepsDay() {
        let assignment = Assignment(title: "Essay", course: .english, dueDate: date(day: 19, hour: 9))
        let viewModel = makeViewModel(assignments: [assignment])

        viewModel.markAddedToCalendar(assignment)

        let thursday = viewModel.days.first { $0.date == date(day: 19) }
        #expect(thursday?.assignments.first?.isAddedToCalendar == true)
    }

    @Test func markAddedToCalendarIgnoresUnknownAssignment() {
        let assignment = Assignment(title: "Essay", course: .english, dueDate: date(day: 19, hour: 9))
        let unknown = Assignment(title: "Other", course: .biology, dueDate: date(day: 20, hour: 9))
        let viewModel = makeViewModel(assignments: [assignment])

        viewModel.markAddedToCalendar(unknown)

        #expect(viewModel.days.flatMap(\.assignments) == [assignment])
    }

    // MARK: - Add All to Calendar

    /// Three assignments due Thursday, Nov 19: one already added, two not. Built once per test so IDs stay stable.
    private func thursdayAssignments() -> (addedEssay: Assignment, openQuiz: Assignment, openLab: Assignment) {
        (
            Assignment(title: "Essay", course: .english, dueDate: date(day: 19, hour: 9), isAddedToCalendar: true),
            Assignment(title: "Quiz", course: .biology, dueDate: date(day: 19, hour: 10)),
            Assignment(title: "Lab", course: .chemistry, dueDate: date(day: 19, hour: 11))
        )
    }

    private func thursday(in viewModel: CalendarViewModel) throws -> CalendarDay {
        try #require(viewModel.days.first { $0.date == date(day: 19) })
    }

    @Test func dayListsOnlyOpenAssignmentsNotYetAdded() throws {
        let (addedEssay, openQuiz, openLab) = thursdayAssignments()
        let finishedLab = Assignment(title: openLab.title, course: openLab.course, dueDate: openLab.dueDate, isCompleted: true)
        let viewModel = makeViewModel(assignments: [addedEssay, openQuiz, finishedLab])

        let notAdded = try thursday(in: viewModel).assignmentsNotAddedToCalendar
        #expect(notAdded == [openQuiz])
    }

    @Test func requestAddAllSetsPendingDay() throws {
        let (_, openQuiz, _) = thursdayAssignments()
        let viewModel = makeViewModel(assignments: [openQuiz])
        let day = try thursday(in: viewModel)

        viewModel.requestAddAll(for: day)

        #expect(viewModel.dayPendingAddAll?.id == day.id)
    }

    @Test func requestAddAllIgnoresDayWithEverythingAdded() throws {
        let (addedEssay, _, _) = thursdayAssignments()
        let viewModel = makeViewModel(assignments: [addedEssay])

        viewModel.requestAddAll(for: try thursday(in: viewModel))

        #expect(viewModel.dayPendingAddAll == nil)
    }

    @Test func addAllOpensSheetForFirstAssignmentNotYetAdded() throws {
        let (addedEssay, openQuiz, openLab) = thursdayAssignments()
        let viewModel = makeViewModel(assignments: [addedEssay, openQuiz, openLab])

        viewModel.addAllToCalendar(on: try thursday(in: viewModel))

        #expect(viewModel.assignmentToAddToCalendar == openQuiz)
    }

    @Test func closingSheetOpensNextQueuedAssignment() throws {
        let (_, openQuiz, openLab) = thursdayAssignments()
        let viewModel = makeViewModel(assignments: [openQuiz, openLab])
        viewModel.addAllToCalendar(on: try thursday(in: viewModel))

        viewModel.markAddedToCalendar(openQuiz)
        viewModel.assignmentToAddToCalendar = nil
        viewModel.presentNextQueuedCalendarEvent()
        #expect(viewModel.assignmentToAddToCalendar == openLab)

        viewModel.assignmentToAddToCalendar = nil
        viewModel.presentNextQueuedCalendarEvent()
        #expect(viewModel.assignmentToAddToCalendar == nil)
    }

    @Test func presentNextWaitsWhileSheetIsOpen() throws {
        let (_, openQuiz, openLab) = thursdayAssignments()
        let viewModel = makeViewModel(assignments: [openQuiz, openLab])
        viewModel.addAllToCalendar(on: try thursday(in: viewModel))

        viewModel.presentNextQueuedCalendarEvent()

        #expect(viewModel.assignmentToAddToCalendar == openQuiz)
    }

    @Test func cancellingEndsAddAll() throws {
        let (_, openQuiz, openLab) = thursdayAssignments()
        let viewModel = makeViewModel(assignments: [openQuiz, openLab])
        viewModel.addAllToCalendar(on: try thursday(in: viewModel))

        viewModel.cancelQueuedCalendarEvents()
        viewModel.assignmentToAddToCalendar = nil
        viewModel.presentNextQueuedCalendarEvent()

        #expect(viewModel.assignmentToAddToCalendar == nil)
    }

    @Test func addAllSkipsAssignmentsAddedOrCompletedWhileQueued() throws {
        let (_, openQuiz, openLab) = thursdayAssignments()
        let viewModel = makeViewModel(assignments: [openQuiz, openLab])
        viewModel.addAllToCalendar(on: try thursday(in: viewModel))

        viewModel.markAddedToCalendar(openLab)
        viewModel.assignmentToAddToCalendar = nil
        viewModel.presentNextQueuedCalendarEvent()

        #expect(viewModel.assignmentToAddToCalendar == nil)
    }

    @Test func addAllWithNothingLeftOpensNoSheet() throws {
        let (addedEssay, _, _) = thursdayAssignments()
        let viewModel = makeViewModel(assignments: [addedEssay])

        viewModel.addAllToCalendar(on: try thursday(in: viewModel))

        #expect(viewModel.assignmentToAddToCalendar == nil)
    }
}
