import SwiftUI

struct CourseRow: View {
    private static let colorBarWidth: CGFloat = 14
    /// Extra room between the color bar and the name, on top of the list's standard row inset.
    private static let nameLeadingPadding: CGFloat = 10

    let course: Course
    let openAssignmentCount: Int

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(course.name)
                    .font(.body.weight(.medium))
                    .foregroundStyle(Theme.primaryText)
                if let location = course.location {
                    Text(location)
                        .font(.footnote)
                        .foregroundStyle(Theme.secondaryText)
                }
            }

            Spacer(minLength: 8)

            dueCountLabel
        }
        .padding(.leading, Self.nameLeadingPadding)
        .frame(minHeight: Theme.minimumTapTarget)
        .accessibilityElement(children: .combine)
    }

    /// The row's list background: the surface with a solid bar of the course color filling
    /// its left edge. Applied via `.listRowBackground` so the bar spans the full row height, flush
    /// with the card edge, rather than sitting inside the row's content insets.
    static func background(for course: Course) -> some View {
        Theme.surface
            .overlay(alignment: .leading) {
                // Square-cornered so bars in neighboring rows meet with no gap between them.
                Rectangle()
                    .fill(course.color)
                    .frame(width: colorBarWidth)
            }
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private var dueCountLabel: some View {
        if openAssignmentCount == 0 {
            Text("Nothing due")
                .font(.subheadline)
                .foregroundStyle(Theme.secondaryText)
        } else {
            Text("\(openAssignmentCount) due")
                .font(.subheadline)
                .foregroundStyle(Theme.secondaryText)
        }
    }
}

#if DEBUG
#Preview {
    List {
        CourseRow(course: .chemistry, openAssignmentCount: 2)
            .listRowBackground(CourseRow.background(for: .chemistry))
        CourseRow(course: .soccer, openAssignmentCount: 1)
            .listRowBackground(CourseRow.background(for: .soccer))
        CourseRow(course: .theater, openAssignmentCount: 0)
            .listRowBackground(CourseRow.background(for: .theater))
    }
    .scrollContentBackground(.hidden)
    .background(Theme.background)
}
#endif
