import Foundation
import OSLog

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "HomeworkPal"

    /// Saving and loading the student's planner data.
    static let persistence = Logger(subsystem: subsystem, category: "Persistence")
}
