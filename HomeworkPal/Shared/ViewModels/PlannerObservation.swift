import Combine
import Observation

/// Bridges the shared `PlannerViewModel` to the per-screen `ObservableObject` view models.
///
/// Screens read planner data through their own view model's computed properties. Relying on SwiftUI to
/// notice those indirect reads proved unreliable: a checked-off assignment was saved but the screen kept
/// showing the old state until it was reopened. Forwarding every planner change as the view model's own
/// `objectWillChange` makes each screen redraw whenever courses or assignments change.
@MainActor
enum PlannerObservation {
    static func forwardChanges<Owner: ObservableObject & Sendable>(
        from planner: PlannerViewModel,
        to owner: Owner
    ) where Owner.ObjectWillChangePublisher == ObservableObjectPublisher {
        withObservationTracking {
            _ = planner.courses
            _ = planner.assignments
        } onChange: { [weak owner, weak planner] in
            // `onChange` fires just before the change lands and only once, so hop to the next main-actor
            // turn to announce it after the new values are in place, then start watching again.
            Task { @MainActor in
                guard let owner, let planner else { return }
                owner.objectWillChange.send()
                forwardChanges(from: planner, to: owner)
            }
        }
    }
}
