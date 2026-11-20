import SwiftUI

struct AddAssignmentView: View {
    @StateObject private var viewModel: AddAssignmentViewModel
    @Environment(\.dismiss) private var dismiss
    /// Counts rejected saves; each one shakes the form and shows what's missing.
    @State private var rejectedSaveCount = 0
    @State private var isConfirmingDeletion = false
    @FocusState private var isTitleFocused: Bool

    private let onSave: (Assignment, Bool) -> Void
    private let onDelete: (() -> Void)?
    /// The saved title, so the delete warning names the assignment even if the title field has been edited.
    private let originalTitle: String

    /// - Parameters:
    ///   - editing: The assignment to edit. Leave `nil` to add a new one.
    ///   - onSave: Receives the assignment and whether the student asked to add it to Apple Calendar.
    ///   - onDelete: Called once the student confirms deletion. When set, editing shows a Delete button.
    init(
        courses: [Course],
        editing: Assignment? = nil,
        onSave: @escaping (Assignment, Bool) -> Void,
        onDelete: (() -> Void)? = nil
    ) {
        _viewModel = StateObject(wrappedValue: AddAssignmentViewModel(courses: courses, editing: editing))
        self.onSave = onSave
        self.onDelete = onDelete
        self.originalTitle = editing?.title ?? ""
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
                detailsSection
                notesSection
                courseSection
                if viewModel.isEditing, onDelete != nil {
                    DeleteButtonSection(title: "Delete Assignment") {
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
            .navigationTitle(viewModel.isEditing ? "Edit Assignment" : "New Assignment")
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
            .alert("Delete Assignment?", isPresented: $isConfirmingDeletion) {
                Button("Delete", role: .destructive, action: delete)
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("\"\(originalTitle)\" will be permanently deleted.")
            }
        }
        .presentationBackground(Theme.background)
    }

    private func delete() {
        onDelete?()
        dismiss()
    }

    private var notesSection: some View {
        Section {
            TextField(
                text: $viewModel.notes,
                prompt: Text("Instructions, page numbers, links…").foregroundStyle(Theme.secondaryText),
                axis: .vertical
            ) {
                Text("Notes")
            }
            .lineLimit(3...8)
        } header: {
            Text("Notes")
                .foregroundStyle(Theme.primaryText)
        }
        .listRowBackground(Theme.surface)
    }

    private var detailsSection: some View {
        Section {
            TextField(text: $viewModel.title, prompt: Text("Title").foregroundStyle(Theme.secondaryText)) {
                Text("Title")
            }
            .focused($isTitleFocused)
            DatePicker("Due", selection: $viewModel.dueDate)
            // Editing offers Add to Calendar from the assignment's own screen instead.
            if !viewModel.isEditing {
                Toggle("Add to Apple Calendar", isOn: $viewModel.addToCalendar)
            }
        }
        .listRowBackground(Theme.surface)
    }

    // Classes and activities are separate form sections, classes first, with their names as standard
    // section headings above each group. Rows act as one single-choice list across both sections.
    @ViewBuilder
    private var courseSection: some View {
        if viewModel.courses.isEmpty {
            Section {
                // Every assignment needs a class, so explain where to make one instead of showing an empty list.
                Text("Add a class or activity in the Activities tab first.")
                    .foregroundStyle(Theme.secondaryText)
            } header: {
                Text("Class or Activity")
                    .foregroundStyle(Theme.primaryText)
            }
            .listRowBackground(Theme.surface)
        } else {
            courseGroup(title: "Classes", courses: viewModel.classes)
            courseGroup(title: "Activities", courses: viewModel.activities)
        }
    }

    @ViewBuilder
    private func courseGroup(title: LocalizedStringKey, courses: [Course]) -> some View {
        if !courses.isEmpty {
            Section {
                ForEach(courses) { course in
                    courseRow(for: course)
                }
            } header: {
                Text(title)
                    .foregroundStyle(Theme.primaryText)
            }
            .listRowBackground(Theme.surface)
        }
    }

    // The selected row shows a checkmark, so the choice doesn't rely on color alone.
    private func courseRow(for course: Course) -> some View {
        let isSelected = viewModel.selectedCourseID == course.id
        return Button {
            viewModel.selectedCourseID = course.id
        } label: {
            HStack {
                Label {
                    Text(course.name)
                        .foregroundStyle(Theme.primaryText)
                } icon: {
                    Image(systemName: "circle.fill")
                        .foregroundStyle(course.color)
                        .accessibilityHidden(true)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Theme.primaryText)
                        .accessibilityHidden(true)
                }
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected) { _, nowSelected in nowSelected }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func save() {
        guard let assignment = viewModel.makeAssignment() else {
            rejectedSaveCount += 1
            if viewModel.isMissingTitle {
                isTitleFocused = true
            }
            return
        }
        onSave(assignment, viewModel.addToCalendar)
        dismiss()
    }
}

#if DEBUG
#Preview {
    AddAssignmentView(courses: Course.sampleData) { _, _ in }
}

#Preview("Editing") {
    AddAssignmentView(courses: Course.sampleData, editing: Assignment.sampleData[4], onSave: { _, _ in }, onDelete: {})
}

#Preview("No Classes") {
    AddAssignmentView(courses: []) { _, _ in }
}
#endif
