import Combine
import Foundation
import UIKit

/// Walks the student through a new photo (optional), then their name, and saves both at the end.
@MainActor
final class EditProfileViewModel: ObservableObject {
    /// The screens after the opening photo question, pushed in order.
    enum Step: Hashable {
        case crop
        case name
    }

    /// The steps pushed on top of the photo question.
    @Published var path: [Step] = []
    @Published var name: String
    @Published var isShowingCamera = false
    @Published var errorMessage: String?
    /// The photo just taken or chosen, waiting to be cropped.
    @Published private(set) var photoToCrop: UIImage?
    /// The new cropped photo, or `nil` to keep the current one.
    @Published private(set) var newPhotoData: Data?

    private let planner: PlannerViewModel

    init(planner: PlannerViewModel) {
        self.planner = planner
        name = planner.profile.name
    }

    var isCameraAvailable: Bool {
        CameraPicker.isAvailable
    }

    /// The photo the profile will have once saved: the new one if there is one, otherwise the current one.
    var photoData: Data? {
        newPhotoData ?? planner.profile.photoData
    }

    func takePhoto() {
        isShowingCamera = true
    }

    /// `image` is `nil` when the student closed the camera without taking a photo.
    func cameraFinished(with image: UIImage?) {
        isShowingCamera = false
        guard let image else { return }
        beginCropping(image)
    }

    /// `data` is `nil` when the chosen photo couldn't be loaded.
    func libraryPhotoLoaded(_ data: Data?) {
        guard let data, let image = UIImage(data: data) else {
            errorMessage = String(localized: "That photo couldn't be opened. Please choose another.")
            return
        }
        beginCropping(image)
    }

    func useCroppedPhoto(_ data: Data) {
        newPhotoData = data
        path.append(.name)
    }

    /// Keeps the current photo and moves straight to the name.
    func skipPhoto() {
        newPhotoData = nil
        path = [.name]
    }

    func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        planner.updateProfile(UserProfile(name: trimmedName, photoData: photoData))
    }

    private func beginCropping(_ image: UIImage) {
        photoToCrop = image
        path = [.crop]
    }
}
