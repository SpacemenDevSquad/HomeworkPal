import SwiftUI

struct AddCourseView: View {
    private static let swatchSize: CGFloat = 36
    private static let swatchSpacing: CGFloat = 12
    private static let selectionRingWidth: CGFloat = 3

    @StateObject private var viewModel: AddCourseViewModel
    @Environment(\.dismiss) private var dismiss

    private let onSave: (Course) -> Void

    init(existingCourses: [Course], onSave: @escaping (Course) -> Void) {
        _viewModel = StateObject(wrappedValue: AddCourseViewModel(existingCourses: existingCourses))
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                nameSection
                colorSection
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .foregroundStyle(Theme.primaryText)
            .tint(Theme.primaryText)
            .navigationTitle("New Class")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: save) {
                        Text("Add")
                            .foregroundStyle(Theme.primaryText)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(Theme.accent)
                    .disabled(!viewModel.canSave)
                }
            }
        }
        .presentationBackground(Theme.background)
    }

    private var nameSection: some View {
        Section {
            TextField(text: $viewModel.name, prompt: Text("Name").foregroundStyle(Theme.secondaryText)) {
                Text("Name")
            }
        } footer: {
            if viewModel.isDuplicateName {
                Text("A class or activity with this name already exists.")
                    .foregroundStyle(Theme.primaryText)
            }
        }
        .listRowBackground(Theme.surface)
    }

    private var colorSection: some View {
        Section {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: Theme.minimumTapTarget), spacing: Self.swatchSpacing)],
                spacing: Self.swatchSpacing
            ) {
                ForEach(viewModel.colorOptions) { option in
                    colorSwatch(for: option)
                }
            }
            .padding(.vertical, 4)
        } header: {
            Text("Color")
                .foregroundStyle(Theme.primaryText)
        }
        .listRowBackground(Theme.surface)
    }

    // Selection is shown with a ring and a checkmark, so it doesn't rely on color alone.
    private func colorSwatch(for option: CourseColorOption) -> some View {
        let isSelected = viewModel.selectedColorHex == option.hex
        return Button {
            viewModel.selectedColorHex = option.hex
        } label: {
            Circle()
                .fill(Color(hex: option.hex) ?? Theme.accent)
                .frame(width: Self.swatchSize, height: Self.swatchSize)
                .overlay {
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Theme.primaryText)
                    }
                }
                .padding(Self.selectionRingWidth)
                .overlay {
                    Circle()
                        .strokeBorder(isSelected ? Theme.primaryText : .clear, lineWidth: Self.selectionRingWidth / 1.5)
                }
                .frame(minWidth: Theme.minimumTapTarget, minHeight: Theme.minimumTapTarget)
                .contentShape(.circle)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(option.name))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func save() {
        guard let course = viewModel.makeCourse() else { return }
        onSave(course)
        dismiss()
    }
}

#if DEBUG
#Preview {
    AddCourseView(existingCourses: Course.sampleData) { _ in }
}

#Preview("No Existing Classes") {
    AddCourseView(existingCourses: []) { _ in }
}
#endif
