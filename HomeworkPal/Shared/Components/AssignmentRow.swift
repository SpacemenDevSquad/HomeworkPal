import SwiftUI

struct AssignmentRow: View {
    /// How the due date reads on the right of the row.
    enum DueDateStyle {
        /// "Wed 3:00 PM", for work due within the week.
        case weekdayAndTime
        /// "Mon, Nov 16", for work further out or already past.
        case date
    }

    private static let stripeWidth: CGFloat = 4
    private static let courseDotSize: CGFloat = 8

    /// How long a fresh checkmark waits before the assignment is completed. Tapping again in that time
    /// unchecks it, and lists that hide completed work don't remove the row before the check is seen.
    private static let completionDelay: Duration = .seconds(1)

    let assignment: Assignment
    let isOverdue: Bool
    var dueDateStyle: DueDateStyle = .weekdayAndTime
    /// Called to flip the assignment's completed state: after the short delay when checking, right away when unchecking.
    let onToggle: () -> Void
    /// When set, long-pressing the row offers Add to Calendar.
    var onAddToCalendar: (() -> Void)? = nil

    private var courseColor: Color { assignment.course.color }

    /// True between checking an open assignment and its completion being saved.
    @State private var isPendingCompletion = false
    @State private var completionTask: Task<Void, Never>?

    private var showsCheckmark: Bool { assignment.isCompleted || isPendingCompletion }

    // Typed as a key so both titles are localized; a ternary of literals would infer a plain String.
    private var addToCalendarTitle: LocalizedStringKey {
        assignment.isAddedToCalendar ? "Add to Calendar Again" : "Add to Calendar"
    }

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: Self.stripeWidth / 2)
                .fill(courseColor)
                .frame(width: Self.stripeWidth)
                .accessibilityHidden(true)

            checkbox

            // Everything but the checkbox opens the assignment, so the checkbox keeps its own tap.
            NavigationLink(value: AssignmentLink(id: assignment.id)) {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(assignment.title)
                            .font(.body.weight(.medium))
                            .foregroundStyle(Theme.primaryText)
                            .multilineTextAlignment(.leading)
                        courseLabel
                    }

                    Spacer(minLength: 8)

                    dueDateLabel

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.secondaryText)
                        .accessibilityHidden(true)
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
        }
        .padding(12)
        .background(Theme.surface, in: .rect(cornerRadius: Theme.cornerRadius))
        .shadow(
            color: Theme.primaryText.opacity(Theme.cardShadowOpacity),
            radius: Theme.cardShadowRadius,
            y: Theme.cardShadowOffset
        )
        .contextMenu {
            if let onAddToCalendar {
                Button(action: onAddToCalendar) {
                    Label(addToCalendarTitle, systemImage: "calendar.badge.plus")
                }
            }
        }
    }

    private var checkbox: some View {
        Button(action: toggleCompletion) {
            Image(systemName: showsCheckmark ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundStyle(Theme.primaryText)
                .contentTransition(.symbolEffect(.replace))
                .frame(minWidth: Theme.minimumTapTarget, minHeight: Theme.minimumTapTarget)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .animation(.snappy, value: showsCheckmark)
        .sensoryFeedback(.success, trigger: showsCheckmark) { _, isChecked in isChecked }
        .accessibilityLabel(showsCheckmark ? Text("Mark incomplete") : Text("Mark complete"))
    }

    private func toggleCompletion() {
        // Already saved as complete: unchecking is immediate.
        if assignment.isCompleted {
            withAnimation { onToggle() }
            return
        }
        // Checked moments ago and not saved yet: a second tap takes it back.
        if isPendingCompletion {
            completionTask?.cancel()
            completionTask = nil
            isPendingCompletion = false
            return
        }
        isPendingCompletion = true
        completionTask = Task { @MainActor in
            try? await Task.sleep(for: Self.completionDelay)
            guard !Task.isCancelled else { return }
            withAnimation { onToggle() }
            isPendingCompletion = false
            completionTask = nil
        }
    }

    private var courseLabel: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(courseColor)
                .frame(width: Self.courseDotSize, height: Self.courseDotSize)
                .accessibilityHidden(true)
            Text(assignment.course.name)
                .font(.caption)
                .foregroundStyle(Theme.secondaryText)
            if assignment.isAddedToCalendar {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundStyle(Theme.secondaryText)
                    .accessibilityLabel(Text("Added to Calendar"))
            }
        }
    }

    private var dueDateFormat: Date.FormatStyle {
        switch dueDateStyle {
        case .weekdayAndTime: .dateTime.weekday(.abbreviated).hour().minute()
        case .date: .dateTime.weekday(.abbreviated).month(.abbreviated).day()
        }
    }

    // Overdue is signalled by an icon and heavier weight, not by color alone.
    private var dueDateLabel: some View {
        HStack(spacing: 4) {
            if isOverdue {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(Theme.accent)
                    .accessibilityLabel(Text("Overdue"))
            }
            Text(assignment.dueDate, format: dueDateFormat)
                .fontWeight(isOverdue ? .semibold : .regular)
                .foregroundStyle(isOverdue ? Theme.primaryText : Theme.secondaryText)
        }
        .font(.caption)
    }
}

/// Identifies an assignment row within the section that shows it.
///
/// Lazy stacks keep their rows by id, so an assignment that moves between sections under the same id can
/// keep its old row and stale contents. Pairing the id with its section makes a moved row a new view.
struct SectionedRowID<Section: Hashable>: Hashable {
    let section: Section
    let assignment: Assignment.ID
}

#if DEBUG
#Preview {
    VStack {
        AssignmentRow(
            assignment: Assignment(title: "Lab report: Titration", course: .chemistry, dueDate: .now),
            isOverdue: false,
            onToggle: {}
        )
        AssignmentRow(
            assignment: Assignment(title: "Reading response", course: .english, dueDate: .now),
            isOverdue: true,
            onToggle: {}
        )
        AssignmentRow(
            assignment: Assignment(title: "Problem set 6", course: .calculus, dueDate: .now, isAddedToCalendar: true),
            isOverdue: false,
            onToggle: {},
            onAddToCalendar: {}
        )
    }
    .padding()
    .background(Theme.background)
}
#endif
