import Foundation

/// The student's name and photo, shown at the top of Settings. There's only ever one.
///
/// `nonisolated` because it's plain data that SwiftData records convert to and from off the main actor.
nonisolated struct UserProfile: Equatable, Sendable {
    /// Empty until the student sets a name.
    var name: String
    /// A square JPEG, already cropped, or `nil` to show the placeholder.
    var photoData: Data?

    init(name: String = "", photoData: Data? = nil) {
        self.name = name
        self.photoData = photoData
    }
}
