import SwiftUI

/// One assignment in the selected day's timeline: its due time on the left and a card on the right.
struct CalendarAgendaRow: View {
    private static let stripeWidth: CGFloat = 5
    private static let cardContentPadding: CGFloat = 12

    /// Scales with Dynamic Type so long times like "11:59 PM" never wrap at larger text sizes.
    @ScaledMetric(relativeTo: .caption) private var timeColumnWidth: CGFloat = 58

    let assignment: Assignment
    let isOverdue: Bool
    let onToggle: () -> Void
    let onAddToCalendar: () -> Void

    private var courseColor: Color { assignment.course.color }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(assignment.dueDate, format: .dateTime.hour().minute())
                .font(.caption.weight(.medium))
                .foregroundStyle(Theme.secondaryText)
                .monospacedDigit()
                .frame(width: timeColumnWidth, alignment: .leading)
                .padding(.top, Self.cardContentPadding + 2)
                .accessibilityHidden(true)

            card
        }
    }

    private var card: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(courseColor)
                .frame(width: Self.stripeWidth)
                .accessibilityHidden(true)

            // Everything but the checkbox opens the assignment, so the checkbox keeps its own tap.
            NavigationLink(value: AssignmentLink(id: assignment.id)) {
                details
            }
            .buttonStyle(.plain)

            checkbox
        }
        .background(Theme.surface)
        .clipShape(.rect(cornerRadius: Theme.cornerRadius))
        .shadow(
            color: Theme.primaryText.opacity(Theme.cardShadowOpacity),
            radius: Theme.cardShadowRadius,
            y: Theme.cardShadowOffset
        )
        .contextMenu {
            Button(action: onAddToCalendar) {
                Label(
                    assignment.isAddedToCalendar ? "Add to Calendar Again" : "Add to Calendar",
                    systemImage: "calendar.badge.plus"
                )
            }
        }
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 4) {
                Text(assignment.course.name)
                if isOverdue {
                    // Overdue is shown with an icon and a word, not by color alone.
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(Theme.accent)
                        .accessibilityHidden(true)
                    Text("Overdue")
                        .fontWeight(.semibold)
                        .foregroundStyle(Theme.primaryText)
                }
                if assignment.isAddedToCalendar {
                    Image(systemName: "calendar")
                        .accessibilityLabel(Text("Added to Calendar"))
                }
            }
            .font(.caption)
            .foregroundStyle(Theme.secondaryText)

            Text(assignment.title)
                .font(.headline)
                .foregroundStyle(assignment.isCompleted ? Theme.secondaryText : Theme.primaryText)
                .strikethrough(assignment.isCompleted, color: Theme.secondaryText)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, Self.cardContentPadding)
        .padding(.leading, Self.cardContentPadding)
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
        // The time column is hidden from VoiceOver, so the due time is read with the card instead.
        .accessibilityValue(Text("Due \(assignment.dueDate, format: .dateTime.hour().minute())"))
    }

    private var checkbox: some View {
        Button(action: onToggle) {
            Image(systemName: assignment.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundStyle(Theme.primaryText)
                .contentTransition(.symbolEffect(.replace))
                .frame(minWidth: Theme.minimumTapTarget, minHeight: Theme.minimumTapTarget)
                .padding(.horizontal, 4)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.success, trigger: assignment.isCompleted) { _, isCompleted in isCompleted }
        .accessibilityLabel(assignment.isCompleted ? Text("Mark incomplete") : Text("Mark complete"))
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        VStack(spacing: 10) {
            CalendarAgendaRow(
                assignment: Assignment(title: "Unit 4 quiz", course: .english, dueDate: .now),
                isOverdue: false,
                onToggle: {},
                onAddToCalendar: {}
            )
            CalendarAgendaRow(
                assignment: Assignment(title: "Reading response", course: .chemistry, dueDate: .now, isCompleted: true),
                isOverdue: false,
                onToggle: {},
                onAddToCalendar: {}
            )
        }
        .padding()
        .frame(maxHeight: .infinity)
        .background(Theme.background)
    }
}
#endif
