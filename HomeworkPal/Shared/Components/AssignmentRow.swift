import SwiftUI

struct AssignmentRow: View {
    private static let minimumTapTarget: CGFloat = 44
    private static let stripeWidth: CGFloat = 4
    private static let courseDotSize: CGFloat = 8

    let assignment: Assignment
    let isOverdue: Bool
    let onToggle: () -> Void

    private var courseColor: Color { assignment.course.color }

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: Self.stripeWidth / 2)
                .fill(courseColor)
                .frame(width: Self.stripeWidth)
                .accessibilityHidden(true)

            checkbox

            VStack(alignment: .leading, spacing: 4) {
                Text(assignment.title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(Theme.primaryText)
                courseLabel
            }

            Spacer(minLength: 8)

            dueDateLabel
        }
        .padding(12)
        .background(Theme.surface, in: .rect(cornerRadius: Theme.cornerRadius))
        .shadow(
            color: Theme.primaryText.opacity(Theme.cardShadowOpacity),
            radius: Theme.cardShadowRadius,
            y: Theme.cardShadowOffset
        )
        .accessibilityElement(children: .combine)
    }

    private var checkbox: some View {
        Button(action: onToggle) {
            Image(systemName: assignment.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundStyle(Theme.primaryText)
                .frame(minWidth: Self.minimumTapTarget, minHeight: Self.minimumTapTarget)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(assignment.isCompleted ? Text("Mark incomplete") : Text("Mark complete"))
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
            Text(assignment.dueDate, format: .dateTime.weekday(.abbreviated).hour().minute())
                .fontWeight(isOverdue ? .semibold : .regular)
                .foregroundStyle(isOverdue ? Theme.primaryText : Theme.secondaryText)
        }
        .font(.caption)
    }
}

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
    }
    .padding()
    .background(Theme.background)
}
