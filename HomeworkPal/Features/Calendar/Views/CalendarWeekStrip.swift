import SwiftUI

/// The seven days of the shown week. Tap a day to list it. The arrows above change weeks; swiping is a shortcut.
struct CalendarWeekStrip: View {
    /// How far a horizontal drag must travel before it counts as a swipe to another week.
    private static let swipeDistance: CGFloat = 50

    @ObservedObject var viewModel: CalendarViewModel
    /// Called with `1` for the next week or `-1` for the previous one.
    let onChangeWeek: (Int) -> Void

    var body: some View {
        HStack(spacing: 4) {
            ForEach(viewModel.days) { day in
                CalendarDayCell(day: day, isSelected: viewModel.isSelected(day)) {
                    withAnimation(.snappy) { viewModel.select(day) }
                }
                .contextMenu {
                    if !day.assignmentsNotAddedToCalendar.isEmpty {
                        Button {
                            viewModel.requestAddAll(for: day)
                        } label: {
                            Label("Add All to Calendar", systemImage: "calendar.badge.plus")
                        }
                    }
                }
            }
        }
        .padding(8)
        // Seven fixed-width columns can't grow forever; the selected day's full date and the list below
        // keep scaling, so nothing is lost at the largest text sizes.
        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
        .background(Theme.surface, in: .rect(cornerRadius: Theme.cornerRadius))
        .shadow(
            color: Theme.primaryText.opacity(Theme.cardShadowOpacity),
            radius: Theme.cardShadowRadius,
            y: Theme.cardShadowOffset
        )
        .contentShape(.rect)
        .gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { value in
                    let horizontal = value.translation.width
                    // Only clearly sideways drags change the week, so vertical scrolling isn't hijacked.
                    guard abs(horizontal) > abs(value.translation.height), abs(horizontal) > Self.swipeDistance else { return }
                    onChangeWeek(horizontal < 0 ? 1 : -1)
                }
        )
    }
}

#if DEBUG
#Preview {
    CalendarWeekStrip(viewModel: CalendarViewModel(planner: PlannerViewModel())) { _ in }
        .padding()
        .background(Theme.background)
}
#endif
