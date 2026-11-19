import Foundation
import Testing
@testable import HomeworkPal

@MainActor
struct AddCourseViewModelTests {
    @Test func defaultsToFirstColorNotAlreadyUsed() {
        let viewModel = AddCourseViewModel(existingCourses: [.english, .chemistry])

        // English and Chemistry take the first two presets (blue, orange), so green is next.
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
}
