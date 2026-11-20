import SwiftUI

/// One day in the week strip: weekday letter, date, and how much is due.
struct CalendarDayCell: View {
    private static let badgeHorizontalPadding: CGFloat = 6
    private static let badgeVerticalPadding: CGFloat = 1
    private static let todayRingWidth: CGFloat = 1.5
    private static let minimumDateScale: CGFloat = 0.7

    let day: CalendarDay
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 4) {
                Text(day.date, format: .dateTime.weekday(.narrow))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(isSelected ? Theme.surface : Theme.secondaryText)
                Text(day.date, format: .dateTime.day())
                    .font(.title3.weight(isSelected || day.isToday ? .bold : .medium))
                    .foregroundStyle(isSelected ? Theme.surface : Theme.primaryText)
                    .monospacedDigit()
                    // Seven cells share the width, so a two-digit date shrinks slightly rather than wrapping.
                    .lineLimit(1)
                    .minimumScaleFactor(Self.minimumDateScale)
                workload
            }
            .frame(maxWidth: .infinity, minHeight: Theme.minimumTapTarget)
            .padding(.vertical, 8)
            .background {
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .fill(isSelected ? Theme.primaryText : .clear)
            }
            // Today is ringed in the accent when it isn't selected, so it's easy to find without relying on color alone:
            // the date is also bold.
            .overlay {
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .strokeBorder(Theme.accent, lineWidth: day.isToday && !isSelected ? Self.todayRingWidth : 0)
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    /// "Busy" on crowded days, otherwise the number due, or a quiet dot when nothing is.
    @ViewBuilder
    private var workload: some View {
        if day.isBusy {
            Text("Busy")
                .font(.caption2.weight(.bold))
                .foregroundStyle(Theme.primaryText)
                .padding(.horizontal, Self.badgeHorizontalPadding)
                .padding(.vertical, Self.badgeVerticalPadding)
                .background(Theme.accent, in: .capsule)
        } else if day.isEmpty {
            Text("·")
                .font(.caption2.weight(.bold))
                .foregroundStyle(isSelected ? Theme.surface : Theme.secondaryText)
        } else {
            Text(day.assignments.count, format: .number)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(isSelected ? Theme.surface : Theme.secondaryText)
        }
    }

    private var accessibilityLabel: Text {
        let date = Text(day.date, format: .dateTime.weekday(.wide).month(.wide).day())
        let count = Text("^[\(day.assignments.count) assignment](inflect: true)")
        let busy = day.isBusy ? Text(", busy") : Text("")
        let today = day.isToday ? Text(", today") : Text("")
        return Text("\(date), \(count)\(busy)\(today)")
    }
}

#if DEBUG
#Preview {
    let planner = PlannerViewModel()
    let viewModel = CalendarViewModel(planner: planner)
    HStack(spacing: 4) {
        ForEach(viewModel.days) { day in
            CalendarDayCell(day: day, isSelected: viewModel.isSelected(day)) {}
        }
    }
    .padding()
    .background(Theme.surface)
}
#endif
