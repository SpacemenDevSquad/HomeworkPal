import Foundation
import Testing
@testable import HomeworkPal

@MainActor
struct AddCourseViewModelTests {
    @Test func defaultsToFirstColorNotAlreadyUsed() {
        let viewModel = AddCourseViewModel(existingCourses: [.english, .chemistry])

        // English and Chemistry take the first two suggestions (blue, orange), so green is next.
        #expect(viewModel.selectedColorHex == Course.biology.colorHex)
    }

    @Test(arguments: ["", "   "])
    func blankNameCannotBeSaved(name: String) {
        let viewModel = AddCourseViewModel(existingCourses: [])
        viewModel.name = name

        #expect(!viewModel.canSave)
        #expect(viewModel.makeCourse() == nil)
    }

    @Test(arguments: ["English", "english", "  ENGLISH  "])
    func duplicateNameIsRejectedIgnoringCaseAndSpaces(name: String) {
        let viewModel = AddCourseViewModel(existingCourses: [.english])
        viewModel.name = name

        #expect(viewModel.isDuplicateName)
        #expect(!viewModel.canSave)
    }

    @Test func makeCourseTrimsNameAndUsesSelectedColor() throws {
        let viewModel = AddCourseViewModel(existingCourses: [])
        viewModel.name = "  Robotics Club "
        viewModel.selectedColorHex = "#6155F5"

        let course = try #require(viewModel.makeCourse())

        #expect(course.name == "Robotics Club")
        #expect(course.colorHex == "#6155F5")
    }

    @Test func noRepeatDaysMeansNoSchedule() throws {
        let viewModel = AddCourseViewModel(existingCourses: [], kind: .activity)
        viewModel.name = "Chess Club"
        viewModel.location = "   "

        let course = try #require(viewModel.makeCourse())

        #expect(course.kind == .activity)
        #expect(course.schedule == nil)
        #expect(course.location == nil)
    }

    @Test func repeatDaysTimesAndLocationAreSaved() throws {
        let calendar = Calendar(identifier: .gregorian)
        let now = try #require(calendar.date(from: DateComponents(year: 2026, month: 11, day: 18, hour: 8)))
        let viewModel = AddCourseViewModel(existingCourses: [], kind: .activity, calendar: calendar, now: now)
        viewModel.name = "Soccer"
        viewModel.location = " North Field "
        viewModel.toggleWeekday(.monday)
        viewModel.toggleWeekday(.wednesday)
        viewModel.toggleWeekday(.friday)
        viewModel.toggleWeekday(.wednesday)
        viewModel.startTime = try #require(calendar.date(bySettingHour: 15, minute: 30, second: 0, of: now))
        viewModel.endTime = try #require(calendar.date(bySettingHour: 17, minute: 0, second: 0, of: now))

        let course = try #require(viewModel.makeCourse())
        let schedule = try #require(course.schedule)

        #expect(schedule.weekdays == [.monday, .friday])
        #expect(schedule.startMinutes == 15 * 60 + 30)
        #expect(schedule.endMinutes == 17 * 60)
        #expect(course.location == "North Field")
    }

    @Test func endTimeBeforeStartTimeCannotBeSaved() throws {
        let viewModel = AddCourseViewModel(existingCourses: [])
        viewModel.name = "Math"
        viewModel.toggleWeekday(.tuesday)
        viewModel.endTime = viewModel.startTime

        #expect(viewModel.hasInvalidTimeRange)
        #expect(!viewModel.canSave)

        // Clearing the days drops the schedule, so the times no longer matter.
        viewModel.toggleWeekday(.tuesday)
        #expect(viewModel.canSave)
    }
}

@MainActor
struct CourseColorOptionTests {
    @Test func suggestionOrderOffersEveryPresetExactlyOnce() {
        let suggested = CourseColorOption.suggestionOrder.map(\.hex)

        #expect(suggested.count == CourseColorOption.all.count)
        #expect(Set(suggested) == Set(CourseColorOption.all.map(\.hex)))
    }

    @Test func presetsHaveUniqueValidHexes() {
        let hexes = CourseColorOption.all.map(\.hex)

        #expect(Set(hexes).count == hexes.count)
        #expect(hexes.allSatisfy { $0.count == 7 && UInt32($0.dropFirst(), radix: 16) != nil })
    }
}
