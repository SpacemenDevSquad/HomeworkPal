import EventKit
import EventKitUI
import SwiftUI

/// Apple's Add Event sheet, pre-filled from an assignment.
///
/// The sheet runs in a separate system process and saves the event itself, so HomeworkPal never needs
/// calendar permission and never sees the student's other events. SwiftUI has no equivalent, hence UIKit.
struct AddToCalendarSheet: UIViewControllerRepresentable {
    let assignment: Assignment
    /// Called only when the student taps Add, never on Cancel.
    let onSaved: () -> Void
    /// Called when the student taps Cancel.
    let onCancelled: () -> Void

    init(assignment: Assignment, onSaved: @escaping () -> Void, onCancelled: @escaping () -> Void = {}) {
        self.assignment = assignment
        self.onSaved = onSaved
        self.onCancelled = onCancelled
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let details = assignment.calendarEventDetails
        let event = EKEvent(eventStore: context.coordinator.eventStore)
        event.title = details.title
        event.startDate = details.startDate
        event.endDate = details.endDate
        event.notes = details.notes
        // No calendar or alarm is set: the system sheet picks the student's default calendar, and
        // warnings before the due date come from HomeworkPal's own reminders.

        let controller = EKEventEditViewController()
        controller.eventStore = context.coordinator.eventStore
        controller.event = event
        controller.editViewDelegate = context.coordinator
        updateCoordinator(context)
        return controller
    }

    func updateUIViewController(_ controller: EKEventEditViewController, context: Context) {
        updateCoordinator(context)
    }

    private func updateCoordinator(_ context: Context) {
        context.coordinator.onSaved = onSaved
        context.coordinator.onCancelled = onCancelled
        context.coordinator.dismiss = context.environment.dismiss
    }

    final class Coordinator: NSObject, EKEventEditViewDelegate {
        let eventStore = EKEventStore()
        var onSaved: () -> Void = {}
        var onCancelled: () -> Void = {}
        var dismiss: DismissAction?

        func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
            switch action {
            case .saved:
                onSaved()
            case .canceled:
                onCancelled()
            default:
                break
            }
            // Dismissing through SwiftUI keeps the presenting `.sheet(item:)` binding in sync.
            dismiss?()
        }
    }
}

#Preview {
    AddToCalendarSheet(assignment: Assignment.sampleData[0]) {}
}
