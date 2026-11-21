import Foundation
import SwiftData
import Testing
@testable import HomeworkPal

@MainActor
struct ProfilePersistenceTests {
    private let photo = Data([0xFF, 0xD8, 0xFF])

    private func makeService() throws -> (SwiftDataPlannerService, ModelContainer) {
        let container = try SwiftDataPlannerService.makeContainer(isStoredInMemoryOnly: true)
        return (SwiftDataPlannerService(container: container), container)
    }

    @Test func noProfileUntilOneIsSaved() throws {
        let (service, _) = try makeService()

        #expect(try service.fetchProfile() == nil)
    }

    @Test func savedProfileSurvivesARelaunch() throws {
        let (service, container) = try makeService()
        let profile = UserProfile(name: "Sam", photoData: photo)

        try service.saveProfile(profile)

        #expect(try SwiftDataPlannerService(container: container).fetchProfile() == profile)
    }

    @Test func savingAgainReplacesTheProfileInsteadOfAddingAnother() throws {
        let (service, container) = try makeService()

        try service.saveProfile(UserProfile(name: "Sam"))
        try service.saveProfile(UserProfile(name: "Samantha", photoData: photo))

        #expect(try service.fetchProfile() == UserProfile(name: "Samantha", photoData: photo))
        #expect(try container.mainContext.fetchCount(FetchDescriptor<ProfileRecord>()) == 1)
    }

    @Test func clearingAllDataRemovesTheProfile() throws {
        let (service, _) = try makeService()
        try service.saveProfile(UserProfile(name: "Sam", photoData: photo))

        try service.deleteAllData()

        #expect(try service.fetchProfile() == nil)
    }

    @Test func plannerLoadsUpdatesAndClearsTheProfile() throws {
        let planner = PlannerViewModel(assignments: [])
        #expect(planner.profile == UserProfile())

        planner.updateProfile(UserProfile(name: "Sam"))
        #expect(planner.profile.name == "Sam")

        try planner.deleteAllData()
        #expect(planner.profile == UserProfile())
    }
}
