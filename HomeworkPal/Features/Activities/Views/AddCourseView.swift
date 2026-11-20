import SwiftUI

struct AddCourseView: View {
    private static let swatchColumns = 6
    private static let swatchSize: CGFloat = 32
    private static let swatchSpacing: CGFloat = 4
    private static let gridVerticalPadding: CGFloat = 6
    private static let selectionRingWidth: CGFloat = 2.5
    /// Space between a selected swatch and its ring, so the ring reads as a separate outline.
    private static let selectionRingGap: CGFloat = 4
    private static let unselectedSwatchScale: CGFloat = 0.92
    private static let hiddenCheckmarkScale: CGFloat = 0.4
    private static let checkmarkShadowOpacity = 0.25
    private static let selectionAnimationDuration = 0.2
    private static let dayBubbleSize: CGFloat = 38

    @StateObject private var viewModel: AddCourseViewModel
    @Environment(\.dismiss) private var dismiss
    /// Counts rejected saves; each one shakes the form and shows what's missing.
    @State private var rejectedSaveCount = 0
    @State private var isConfirmingDeletion = false
    @FocusState private var isNameFocused: Bool

    private let onSave: (Course) -> Void
    private let onDelete: (() -> Void)?
    private let assignmentCount: Int
    /// The saved name, so the delete warning names the item even if the name field has been edited.
    private let originalName: String

    /// - Parameters:
    ///   - editing: The class or activity to edit. Leave `nil` to add a new one of `kind`.
    ///   - assignmentCount: How many assignments deleting it would also remove, for the warning.
    ///   - onDelete: Called once the student confirms deletion. When set, editing shows a Delete button.
    init(
        existingCourses: [Course],
        kind: CourseKind = .schoolClass,
        editing: Course? = nil,
        assignmentCount: Int = 0,
        onSave: @escaping (Course) -> Void,
        onDelete: (() -> Void)? = nil
    ) {
        _viewModel = StateObject(wrappedValue: AddCourseViewModel(existingCourses: existingCourses, kind: kind, editing: editing))
        self.onSave = onSave
        self.onDelete = onDelete
        self.assignmentCount = assignmentCount
        self.originalName = editing?.name ?? ""
    }

    var body: some View {
        NavigationStack {
            Form {
                if rejectedSaveCount > 0, let message = viewModel.validationMessage {
                    Section {
                        ValidationBanner(message: message)
                    }
                    .listRowBackground(Theme.surface)
                }
                if viewModel.isEditing {
                    kindSection
                }
                nameSection
                repeatSection
                locationSection
                colorSection
                if viewModel.isEditing, onDelete != nil {
                    DeleteButtonSection(title: viewModel.kind == .activity ? "Delete Activity" : "Delete Class") {
                        isConfirmingDeletion = true
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .rejectedSaveFeedback(attempts: rejectedSaveCount)
            .animation(.default, value: viewModel.validationMessage == nil)
            .background(Theme.background)
            .foregroundStyle(Theme.primaryText)
            .tint(Theme.primaryText)
            .navigationTitle(navigationTitle)
            .animation(.default, value: viewModel.hasSchedule)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: save) {
                        Text(viewModel.isEditing ? "Save" : "Add")
                            .foregroundStyle(Theme.primaryText)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(Theme.accent)
                    // Left enabled so a tap can explain what's missing instead of doing nothing.
                }
            }
            .alert(viewModel.kind == .activity ? "Delete Activity?" : "Delete Class?", isPresented: $isConfirmingDeletion) {
                Button("Delete", role: .destructive, action: delete)
                Button("Cancel", role: .cancel) {}
            } message: {
                Text.courseDeletionMessage(courseName: originalName, assignmentCount: assignmentCount)
            }
        }
        .presentationBackground(Theme.background)
    }

    private func delete() {
        onDelete?()
        dismiss()
    }

    private var navigationTitle: LocalizedStringKey {
        switch (viewModel.isEditing, viewModel.kind) {
        case (false, .schoolClass): "New Class"
        case (false, .activity): "New Activity"
        case (true, .schoolClass): "Edit Class"
        case (true, .activity): "Edit Activity"
        }
    }

    /// Lets a saved item move between the Classes and Activities tabs.
    private var kindSection: some View {
        Section {
            Picker("Type", selection: $viewModel.kind) {
                Text("Class").tag(CourseKind.schoolClass)
                Text("Activity").tag(CourseKind.activity)
            }
            .pickerStyle(.segmented)
            .listRowInsets(EdgeInsets())
        }
        .listRowBackground(Color.clear)
    }

    private var nameSection: some View {
        Section {
            TextField(text: $viewModel.name, prompt: Text("Name").foregroundStyle(Theme.secondaryText)) {
                Text("Name")
            }
            .focused($isNameFocused)
        } footer: {
            if viewModel.isDuplicateName {
                Text("A class or activity with this name already exists.")
                    .foregroundStyle(Theme.primaryText)
            }
        }
        .listRowBackground(Theme.surface)
    }

    private var repeatSection: some View {
        Section {
            // Each day takes an equal share of the row, so all seven fit on smaller phones too.
            HStack(spacing: 0) {
                ForEach(Weekday.mondayFirst) { weekday in
                    dayBubble(for: weekday)
                }
            }
            .padding(.vertical, Self.gridVerticalPadding)
            .sensoryFeedback(.selection, trigger: viewModel.selectedWeekdays)

            if viewModel.hasSchedule {
                DatePicker("Starts", selection: $viewModel.startTime, displayedComponents: .hourAndMinute)
                DatePicker("Ends", selection: $viewModel.endTime, displayedComponents: .hourAndMinute)
                DatePicker("Repeat Until", selection: $viewModel.repeatsUntil, in: Date.now..., displayedComponents: .date)
            }
        } header: {
            Text("Repeats On")
                .foregroundStyle(Theme.primaryText)
        } footer: {
            Group {
                if viewModel.hasInvalidTimeRange {
                    Text("The end time needs to be after the start time.")
                } else if !viewModel.hasSchedule {
                    Text("Pick the days it meets to set a time.")
                }
            }
            .foregroundStyle(Theme.secondaryText)
        }
        .listRowBackground(Theme.surface)
    }

    // Selected days are filled with the chosen color and use bolder text, so they don't rely on color alone.
    private func dayBubble(for weekday: Weekday) -> some View {
        let isSelected = viewModel.selectedWeekdays.contains(weekday)
        let color = Color(hex: viewModel.selectedColorHex) ?? Theme.accent
        return Button {
            withAnimation(.snappy(duration: Self.selectionAnimationDuration)) {
                viewModel.toggleWeekday(weekday)
            }
        } label: {
            Text(weekday.veryShortSymbol())
                .font(.subheadline.weight(isSelected ? .bold : .medium))
                .foregroundStyle(isSelected ? .white : Theme.primaryText)
                .frame(width: Self.dayBubbleSize, height: Self.dayBubbleSize)
                .background {
                    Circle()
                        .fill(isSelected ? AnyShapeStyle(color.gradient) : AnyShapeStyle(Theme.background))
                }
                .frame(maxWidth: .infinity, minHeight: Theme.minimumTapTarget)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(weekday.fullSymbol()))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var locationSection: some View {
        Section {
            TextField(text: $viewModel.location, prompt: Text("Room, field, or address").foregroundStyle(Theme.secondaryText)) {
                Text("Location")
            }
            .textContentType(.location)
        } header: {
            Text("Location (Optional)")
                .foregroundStyle(Theme.primaryText)
        }
        .listRowBackground(Theme.surface)
    }

    private var colorSection: some View {
        Section {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: Self.swatchSpacing), count: Self.swatchColumns),
                spacing: Self.swatchSpacing
            ) {
                ForEach(viewModel.colorOptions) { option in
                    colorSwatch(for: option)
                }
            }
            .padding(.vertical, Self.gridVerticalPadding)
            .sensoryFeedback(.selection, trigger: viewModel.selectedColorHex)
        } header: {
            HStack {
                Text("Color")
                Spacer()
                if let selected = viewModel.selectedColorOption {
                    Text(selected.name)
                        .foregroundStyle(Theme.secondaryText)
                        .contentTransition(.opacity)
                }
            }
            .foregroundStyle(Theme.primaryText)
            .animation(.easeInOut(duration: Self.selectionAnimationDuration), value: viewModel.selectedColorHex)
        }
        .listRowBackground(Theme.surface)
    }

    // Selection is shown with a ring and a checkmark, so it doesn't rely on color alone.
    private func colorSwatch(for option: CourseColorOption) -> some View {
        let isSelected = viewModel.selectedColorHex == option.hex
        let color = Color(hex: option.hex) ?? Theme.accent
        return Button {
            withAnimation(.snappy(duration: Self.selectionAnimationDuration)) {
                viewModel.selectedColorHex = option.hex
            }
        } label: {
            Circle()
                .fill(color.gradient)
                .frame(width: Self.swatchSize, height: Self.swatchSize)
                .overlay {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(Self.checkmarkShadowOpacity), radius: 1)
                        .scaleEffect(isSelected ? 1 : Self.hiddenCheckmarkScale)
                        .opacity(isSelected ? 1 : 0)
                }
                .padding(Self.selectionRingGap)
                .overlay {
                    Circle()
                        .strokeBorder(color, lineWidth: Self.selectionRingWidth)
                        .opacity(isSelected ? 1 : 0)
                }
                .scaleEffect(isSelected ? 1 : Self.unselectedSwatchScale)
                .frame(minWidth: Theme.minimumTapTarget, minHeight: Theme.minimumTapTarget)
                .contentShape(.circle)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(option.name))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func save() {
        guard let course = viewModel.makeCourse() else {
            rejectedSaveCount += 1
            if viewModel.isMissingName || viewModel.isDuplicateName {
                isNameFocused = true
            }
            return
        }
        onSave(course)
        dismiss()
    }
}

#if DEBUG
#Preview {
    AddCourseView(existingCourses: Course.sampleData) { _ in }
}

#Preview("Editing") {
    AddCourseView(
        existingCourses: Course.sampleData,
        editing: .chemistry,
        assignmentCount: 2,
        onSave: { _ in },
        onDelete: {}
    )
}

#Preview("New Activity") {
    AddCourseView(existingCourses: Course.sampleData, kind: .activity) { _ in }
}

#Preview("No Existing Classes") {
    AddCourseView(existingCourses: []) { _ in }
}
#endif
