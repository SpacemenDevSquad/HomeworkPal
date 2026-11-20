import SwiftUI

extension Text {
    /// The confirmation shown before deleting a class or activity, warning that its assignments go with it.
    /// Uses automatic grammar agreement so the count reads "1 assignment" or "3 assignments".
    static func courseDeletionMessage(courseName: String, assignmentCount: Int) -> Text {
        guard assignmentCount > 0 else {
            return Text("\"\(courseName)\" will be deleted.")
        }
        return Text("\"\(courseName)\" and its ^[\(assignmentCount) assignment](inflect: true) will be deleted.")
    }
}
