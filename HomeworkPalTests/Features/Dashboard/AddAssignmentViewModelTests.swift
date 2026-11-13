import Foundation
import Testing
@testable import HomeworkPal

@MainActor
struct AddAssignmentViewModelTests {
    private let courses = [Course.english, Course.soccer]

    @Test func defaultsToFirstCourseAndTomorrowAtEndOfDay() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        let now = try #require(calendar.date(from: DateComponents(year: 2026, month: 11, day: 12, hour: 9)))

        let viewModel = AddAssignmentViewModel(courses: courses, now: now, calendar: calendar)

        let components = calendar.dateComponents([.day, .hour, .minute], from: viewModel.dueDate)
        #expect(viewModel.selectedCourseID == Course.english.id)
        #expect(components == DateComponents(day: 13, hour: 23, minute: 59))
    }

    @Test(arguments: ["", "   ", "\n"])
    func blankTitleCannotBeSaved(title: String) {
        let viewModel = AddAssignmentViewModel(courses: courses)
        viewModel.title = title

        #expect(!viewModel.canSave)
        #expect(viewModel.makeAssignment() == nil)
    }

    @Test func noCoursesCannotBeSaved() {
        let viewModel = AddAssignmentViewModel(courses: [])
        viewModel.title = "Lab report"

        #expect(!viewModel.canSave)
    }

    @Test func makeAssignmentTrimsTitleAndUsesSelectedCourse() throws {
        let viewModel = AddAssignmentViewModel(courses: courses)
        viewModel.title = "  Bring permission form  "
        viewModel.selectedCourseID = Course.soccer.id

        let assignment = try #require(viewModel.makeAssignment())

        #expect(assignment.title == "Bring permission form")
        #expect(assignment.course == Course.soccer)
        #expect(assignment.dueDate == viewModel.dueDate)
        #expect(!assignment.isCompleted)
    }
}
