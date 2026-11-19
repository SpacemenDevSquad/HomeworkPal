import Foundation
import Testing
@testable import HomeworkPal

@MainActor
struct AssignmentCalendarEventTests {
    private let dueDate = Date(timeIntervalSinceReferenceDate: 815_000_000)

    private var details: CalendarEventDetails {
        Assignment(title: "Lab report: Titration", course: .chemistry, dueDate: dueDate).calendarEventDetails
    }

    @Test func titleIncludesClassName() {
        #expect(details.title == "Lab report: Titration (Chemistry)")
    }

    @Test func eventIsInstantAtDueDate() {
        #expect(details.startDate == dueDate)
        #expect(details.endDate == dueDate)
    }

    @Test func notesCreditHomeworkPal() {
        #expect(details.notes == "Added by HomeworkPal")
    }

    @Test func studentNotesComeBeforeTheCredit() {
        let assignment = Assignment(title: "Essay", course: .english, dueDate: dueDate, notes: " Pages 40-52 \n")

        #expect(assignment.calendarEventDetails.notes == "Pages 40-52\n\nAdded by HomeworkPal")
    }

    @Test func newAssignmentIsNotAddedToCalendar() {
        #expect(!Assignment(title: "A", course: .english, dueDate: .now).isAddedToCalendar)
    }
}
