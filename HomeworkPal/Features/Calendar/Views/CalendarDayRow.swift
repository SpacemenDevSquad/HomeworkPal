import SwiftUI

struct CalendarDayRow: View {
    private static let courseDotSize: CGFloat = 8
    private static let dateColumnWidth: CGFloat = 44
    private static let badgeHorizontalPadding: CGFloat = 8
    private static let badgeVerticalPadding: CGFloat = 2

    let day: CalendarDay
    @ObservedObject var viewModel: CalendarViewModel

    private var isExpanded: Bool { viewModel.isExpanded(day) }

    var body: some View {
        VStack(spacing: 10) {
            summaryCard
            if isExpanded {
                ForEach(day.assignments) { assignment in
                    AssignmentRow(assignment: assignment, isOverdue: viewModel.isOverdue(assignment)) {
                        viewModel.requestCompletion(for: assignment)
                    }
                }
            }
        }
    }

    private var summaryCard: some View {
        Button {
            withAnimation { viewModel.toggleExpansion(of: day) }
        } label: {
            HStack(spacing: 12) {
                dateColumn
                VStack(alignment: .leading, spacing: 4) {
                    dueCountLabel
                    courseDots
                }
                Spacer(minLength: 8)
                if day.isBusy {
                    busyBadge
                }
                if !day.isEmpty {
                    Image(systemName: "chevron.down")
                        .rotationEffect(isExpanded ? .degrees(180) : .zero)
                        .foregroundStyle(Theme.secondaryText)
                        .accessibilityHidden(true)
                }
            }
            .padding(12)
            .background(Theme.surface, in: .rect(cornerRadius: Theme.cornerRadius))
            .shadow(
                color: Theme.primaryText.opacity(Theme.cardShadowOpacity),
                radius: Theme.cardShadowRadius,
                y: Theme.cardShadowOffset
            )
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .disabled(day.isEmpty)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(day.isToday ? .isSelected : [])
        .accessibilityHint(isExpanded ? Text("Hides assignments") : Text("Shows assignments"))
    }

    // Today is marked with an accent fill plus bold text, so color is not the only signal.
    private var dateColumn: some View {
        VStack(spacing: 2) {
            Text(day.date, format: .dateTime.weekday(.abbreviated))
                .font(.caption)
                .foregroundStyle(Theme.secondaryText)
            Text(day.date, format: .dateTime.day())
                .font(.title3.weight(day.isToday ? .bold : .regular))
                .foregroundStyle(Theme.primaryText)
        }
        .frame(minWidth: Self.dateColumnWidth, minHeight: Self.dateColumnWidth)
        .background(day.isToday ? Theme.accent : .clear, in: .rect(cornerRadius: Theme.cornerRadius / 2))
    }

    @ViewBuilder
    private var dueCountLabel: some View {
        if day.isEmpty {
            Text("Nothing due")
                .font(.body)
                .foregroundStyle(Theme.secondaryText)
        } else {
            Text("\(day.assignments.count) due")
                .font(.body.weight(.medium))
                .foregroundStyle(Theme.primaryText)
        }
    }

    private var courseDots: some View {
        HStack(spacing: 4) {
            ForEach(day.courses) { course in
                Circle()
                    .fill(course.color)
                    .frame(width: Self.courseDotSize, height: Self.courseDotSize)
            }
        }
        .accessibilityHidden(true)
    }

    private var busyBadge: some View {
        Text("Busy")
            .font(.caption.weight(.semibold))
            .foregroundStyle(Theme.primaryText)
            .padding(.horizontal, Self.badgeHorizontalPadding)
            .padding(.vertical, Self.badgeVerticalPadding)
            .background(Theme.accent, in: .capsule)
    }
}

#if DEBUG
#Preview {
    let viewModel = CalendarViewModel(planner: PlannerViewModel())
    ScrollView {
        VStack(spacing: 10) {
            ForEach(viewModel.days) { day in
                CalendarDayRow(day: day, viewModel: viewModel)
            }
        }
        .padding()
    }
    .background(Theme.background)
}
#endif
