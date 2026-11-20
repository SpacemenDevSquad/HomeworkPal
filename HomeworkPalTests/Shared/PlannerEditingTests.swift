import Foundation
import Testing
@testable import HomeworkPal

@MainActor
struct PlannerEditingTests {
    @Test func editingACourseUpdatesItsAssignmentsToo() throws {
        let essay = Assignment(title: "Essay", course: .english, dueDate: .now)
        let planner = PlannerViewModel(courses: [.english], assignments: [essay])

        var renamed = Course.english
        renamed.name = "English Lit"
        renamed.colorHex = "#C8605A"
        planner.updateCourse(renamed)

        #expect(planner.courses == [renamed])
        #expect(planner.assignments.first?.course == renamed)
    }

    @Test func editingAnAssignmentReplacesIt() {
        let essay = Assignment(title: "Essay", course: .english, dueDate: .now)
        let planner = PlannerViewModel(courses: [.english, .biology], assignments: [essay])

        var edited = essay
        edited.title = "Final essay"
        edited.course = .biology
        planner.updateAssignment(edited)

        #expect(planner.assignments == [edited])
        #expect(planner.errorMessage == nil)
    }
}

@MainActor
struct AssignmentDetailViewModelTests {
    @Test func completionTogglesWithoutConfirmation() {
        let essay = Assignment(title: "Essay", course: .english, dueDate: .now)
        let planner = PlannerViewModel(courses: [.english], assignments: [essay])
        let viewModel = AssignmentDetailViewModel(planner: planner, assignmentID: essay.id)

        viewModel.toggleCompletion()
        #expect(viewModel.assignment?.isCompleted == true)

        viewModel.toggleCompletion()
        #expect(viewModel.assignment?.isCompleted == false)
    }

    @Test func savedEditsShowUpRightAway() {
        let essay = Assignment(title: "Essay", course: .english, dueDate: .now)
        let planner = PlannerViewModel(courses: [.english], assignments: [essay])
        let viewModel = AssignmentDetailViewModel(planner: planner, assignmentID: essay.id)

        var edited = essay
        edited.title = "Rewrite"
        viewModel.save(edited)

        #expect(viewModel.assignment?.title == "Rewrite")
    }
}

@MainActor
struct EditFormTests {
    @Test func assignmentFormPrefillsAndKeepsStatus() throws {
        let essay = Assignment(title: "Essay", course: .english, dueDate: .now, isCompleted: true, isAddedToCalendar: true)
        let viewModel = AddAssignmentViewModel(courses: [.english, .biology], editing: essay)

        #expect(viewModel.isEditing)
        #expect(viewModel.title == "Essay")
        #expect(viewModel.selectedCourseID == Course.english.id)

        viewModel.title = "Essay v2"
        viewModel.notes = "  Use MLA format \n"
        viewModel.selectedCourseID = Course.biology.id
        let edited = try #require(viewModel.makeAssignment())

        #expect(edited.id == essay.id)
        #expect(edited.title == "Essay v2")
        #expect(edited.notes == "Use MLA format")
        #expect(edited.course == .biology)
        #expect(edited.isCompleted)
        #expect(edited.isAddedToCalendar)
    }

    @Test func assignmentPickerListsClassesBeforeActivities() {
        let viewModel = AddAssignmentViewModel(courses: [.soccer, .english, .theater, .biology])

        #expect(viewModel.classes == [.english, .biology])
        #expect(viewModel.activities == [.soccer, .theater])
        // Defaults to the first class even when an activity was added first.
        #expect(viewModel.selectedCourseID == Course.english.id)
    }

    @Test func courseFormPrefillsAndAllowsItsOwnName() throws {
        let viewModel = AddCourseViewModel(existingCourses: Course.sampleData, editing: .soccer)

        #expect(viewModel.isEditing)
        #expect(viewModel.kind == .activity)
        #expect(viewModel.name == "Soccer")
        #expect(!viewModel.isDuplicateName)
        #expect(viewModel.selectedColorHex == Course.soccer.colorHex)
        #expect(viewModel.location == "North Field")

        viewModel.kind = .schoolClass
        let edited = try #require(viewModel.makeCourse())

        #expect(edited.id == Course.soccer.id)
        #expect(edited.kind == .schoolClass)
        #expect(edited.location == "North Field")
    }

    @Test func courseFormStillRejectsAnotherCoursesName() {
        let viewModel = AddCourseViewModel(existingCourses: Course.sampleData, editing: .soccer)
        viewModel.name = "English"

        #expect(viewModel.isDuplicateName)
    }
}

@MainActor
struct FormValidationMessageTests {
    @Test func courseFormExplainsAMissingName() {
        let classForm = AddCourseViewModel(existingCourses: [])
        let activityForm = AddCourseViewModel(existingCourses: [], kind: .activity)

        #expect(classForm.validationMessage != nil)
        #expect(classForm.isMissingName)
        #expect(activityForm.validationMessage != nil)

        classForm.name = "Chemistry"
        #expect(classForm.validationMessage == nil)
        #expect(classForm.canSave)
    }

    @Test func courseFormExplainsADuplicateName() {
        let viewModel = AddCourseViewModel(existingCourses: [.english])
        viewModel.name = "english"
        #expect(viewModel.validationMessage != nil)
        #expect(!viewModel.canSave)

        viewModel.name = "Art"
        #expect(viewModel.canSave)
    }

    @Test func assignmentFormExplainsWhatsMissing() {
        let noCourses = AddAssignmentViewModel(courses: [])
        noCourses.title = "Essay"
        #expect(noCourses.validationMessage != nil)

        let viewModel = AddAssignmentViewModel(courses: [.english])
        #expect(viewModel.isMissingTitle)
        #expect(viewModel.validationMessage != nil)

        viewModel.title = "Essay"
        #expect(viewModel.validationMessage == nil)
        #expect(viewModel.canSave)
    }
}
