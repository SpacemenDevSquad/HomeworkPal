import Foundation
import Testing
import UIKit
@testable import HomeworkPal

@MainActor
struct EditProfileViewModelTests {
    private let oldPhoto = Data([0x01])
    private let newPhoto = Data([0x02])

    private func makePlanner(profile: UserProfile = UserProfile()) -> PlannerViewModel {
        let planner = PlannerViewModel(assignments: [])
        planner.updateProfile(profile)
        return planner
    }

    @Test func startsWithTheCurrentName() {
        let viewModel = EditProfileViewModel(planner: makePlanner(profile: UserProfile(name: "Sam")))

        #expect(viewModel.name == "Sam")
        #expect(viewModel.path.isEmpty)
    }

    @Test func skippingThePhotoGoesStraightToTheNameAndKeepsTheOldPhoto() {
        let planner = makePlanner(profile: UserProfile(name: "Sam", photoData: oldPhoto))
        let viewModel = EditProfileViewModel(planner: planner)

        viewModel.skipPhoto()
        viewModel.name = "Samantha"
        viewModel.save()

        #expect(planner.profile == UserProfile(name: "Samantha", photoData: oldPhoto))
    }

    @Test func aNewPhotoIsCroppedThenSavedWithTheName() throws {
        let planner = makePlanner(profile: UserProfile(name: "Sam", photoData: oldPhoto))
        let viewModel = EditProfileViewModel(planner: planner)
        let image = try #require(UIImage(systemName: "person"))
        let imageData = try #require(image.pngData())

        viewModel.libraryPhotoLoaded(imageData)
        #expect(viewModel.path == [.crop])
        #expect(viewModel.photoToCrop != nil)

        viewModel.useCroppedPhoto(newPhoto)
        #expect(viewModel.path == [.crop, .name])

        viewModel.save()
        #expect(planner.profile == UserProfile(name: "Sam", photoData: newPhoto))
    }

    @Test func cancellingTheCameraStaysOnThePhotoQuestion() {
        let viewModel = EditProfileViewModel(planner: makePlanner())
        viewModel.takePhoto()

        viewModel.cameraFinished(with: nil)

        #expect(!viewModel.isShowingCamera)
        #expect(viewModel.path.isEmpty)
    }

    @Test func anUnreadablePhotoShowsAnError() {
        let viewModel = EditProfileViewModel(planner: makePlanner())

        viewModel.libraryPhotoLoaded(Data([0x00]))

        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.path.isEmpty)
    }

    @Test func nameIsTrimmedAndBlankMeansDefaultUser() {
        let planner = makePlanner(profile: UserProfile(name: "Sam"))
        let viewModel = EditProfileViewModel(planner: planner)

        viewModel.name = "   "
        viewModel.save()

        #expect(planner.profile.name.isEmpty)
    }
}
