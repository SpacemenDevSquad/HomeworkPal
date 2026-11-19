import EventKit
import Foundation

/// Adds events to Apple Calendar without being able to read it.
protocol CalendarEventServiceProtocol {
    /// Asks for add-only (write-only) calendar access. Returns whether the student allowed it.
    func requestAddOnlyAccess() async throws -> Bool
    func save(_ details: CalendarEventDetails) throws
}

final class CalendarEventService: CalendarEventServiceProtocol {
    // Created on first use so constructing the service (and its ViewModel) stays cheap.
    private lazy var eventStore = EKEventStore()

    func requestAddOnlyAccess() async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            // `@Sendable` keeps the handler off the main actor: EventKit calls it on a background queue, and a
            // main-actor-isolated closure would trap there under Swift 6.
            eventStore.requestWriteOnlyAccessToEvents { @Sendable isGranted, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: isGranted)
                }
            }
        }
    }

    func save(_ details: CalendarEventDetails) throws {
        let event = EKEvent(eventStore: eventStore)
        event.title = details.title
        event.startDate = details.startDate
        event.endDate = details.endDate
        event.notes = details.notes
        // Add-only access can't list calendars, so events go to the student's default calendar.
        event.calendar = eventStore.defaultCalendarForNewEvents
        try eventStore.save(event, span: .thisEvent)
    }
}
