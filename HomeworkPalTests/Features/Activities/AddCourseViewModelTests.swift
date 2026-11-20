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

    @Test func blankLocationIsSavedAsNone() throws {
        let viewModel = AddCourseViewModel(existingCourses: [], kind: .activity)
        viewModel.name = "Chess Club"
        viewModel.location = "   "

        let course = try #require(viewModel.makeCourse())

        #expect(course.kind == .activity)
        #expect(course.location == nil)
    }

    @Test func locationIsTrimmedAndSaved() throws {
        let viewModel = AddCourseViewModel(existingCourses: [], kind: .activity)
        viewModel.name = "Soccer"
        viewModel.location = " North Field "

        let course = try #require(viewModel.makeCourse())

        #expect(course.location == "North Field")
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
