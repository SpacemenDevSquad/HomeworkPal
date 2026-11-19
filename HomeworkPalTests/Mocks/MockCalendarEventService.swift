import Foundation
@testable import HomeworkPal

@MainActor
final class MockCalendarEventService: CalendarEventServiceProtocol {
    struct SaveFailure: Error {}

    var isAccessGranted = true
    /// Event titles whose save should throw, to simulate a failure partway through.
    var failingTitles: Set<String> = []
    private(set) var savedEvents: [CalendarEventDetails] = []

    func requestAddOnlyAccess() async throws -> Bool {
        isAccessGranted
    }

    func save(_ details: CalendarEventDetails) throws {
        if failingTitles.contains(details.title) { throw SaveFailure() }
        savedEvents.append(details)
    }
}
