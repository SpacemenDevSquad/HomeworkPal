import SwiftUI

struct CourseRow: View {
    private static let colorDotSize: CGFloat = 14

    let course: Course
    let openAssignmentCount: Int

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(course.color)
                .frame(width: Self.colorDotSize, height: Self.colorDotSize)
                .accessibilityHidden(true)

            Text(course.name)
                .font(.body.weight(.medium))
                .foregroundStyle(Theme.primaryText)

            Spacer(minLength: 8)

            dueCountLabel
        }
        .frame(minHeight: Theme.minimumTapTarget)
        .accessibilityElement(children: .combine)
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
            .listRowBackground(Theme.surface)
        CourseRow(course: .theater, openAssignmentCount: 0)
            .listRowBackground(Theme.surface)
    }
    .scrollContentBackground(.hidden)
    .background(Theme.background)
}
#endif
