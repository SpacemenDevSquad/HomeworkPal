import Foundation
import Testing
@testable import HomeworkPal

/// When sync brings two devices' separate data together, same-named classes are combined.
@MainActor
struct PlannerMergeTests {
    private let english = Course(name: "English", colorHex: "#5A7FC2")
    private let otherDevicesEnglish = Course(name: " english ", colorHex: "#C8605A")
    private let englishClub = Course(name: "English", colorHex: "#6FA772", kind: .activity)

    @Test func sameNameAndTypeMergeIntoTheFirstWithAllAssignments() throws {
        let essay = Assignment(title: "Essay", course: english, dueDate: .now)
        let poem = Assignment(title: "Poem", course: otherDevicesEnglish, dueDate: .now)
        let persistence = InMemoryPlannerService(courses: [english, otherDevicesEnglish], assignments: [essay, poem])
        let planner = PlannerViewModel(persistence: persistence)
        planner.loadPlanner()

        planner.mergeDuplicateCourses()

        #expect(planner.courses == [english])
        #expect(Set(planner.assignments.map(\.title)) == ["Essay", "Poem"])
        #expect(planner.assignments.allSatisfy { $0.course.id == english.id })
        // Saved too, so the merge survives a relaunch and syncs to other devices.
        let saved = try persistence.fetchPlanner()
        #expect(saved.courses == [english])
        #expect(saved.assignments.count == 2)
    }

    @Test func aClassAndAnActivityWithTheSameNameStaySeparate() {
        let planner = PlannerViewModel(courses: [english, englishClub], assignments: [])

        planner.mergeDuplicateCourses()

        #expect(planner.courses == [english, englishClub])
    }

    @Test func refreshingFromTheStoreMergesDuplicates() {
        let persistence = InMemoryPlannerService(courses: [english, otherDevicesEnglish], assignments: [])
        let planner = PlannerViewModel(persistence: persistence)

        planner.refreshFromStore()

        #expect(planner.courses == [english])
    }

    @Test func replacingPersistenceReloadsFromTheNewStore() {
        let planner = PlannerViewModel(courses: [english], assignments: [])

        planner.replacePersistence { InMemoryPlannerService(courses: [englishClub], assignments: []) }

        #expect(planner.courses == [englishClub])
    }
}
