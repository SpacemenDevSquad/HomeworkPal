import SwiftUI

struct AddAssignmentView: View {
    @StateObject private var viewModel: AddAssignmentViewModel
    @Environment(\.dismiss) private var dismiss

    private let onSave: (Assignment) -> Void

    init(courses: [Course], onSave: @escaping (Assignment) -> Void) {
        _viewModel = StateObject(wrappedValue: AddAssignmentViewModel(courses: courses))
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                detailsSection
                courseSection
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .foregroundStyle(Theme.primaryText)
            .tint(Theme.primaryText)
            .navigationTitle("New Assignment")
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

    private var detailsSection: some View {
        Section {
            TextField(text: $viewModel.title, prompt: Text("Title").foregroundStyle(Theme.secondaryText)) {
                Text("Title")
            }
            DatePicker("Due", selection: $viewModel.dueDate)
        }
        .listRowBackground(Theme.surface)
    }

    private var courseSection: some View {
        Section {
            Picker("Class or Activity", selection: $viewModel.selectedCourseID) {
                ForEach(viewModel.courses) { course in
                    Label {
                        Text(course.name)
                            .foregroundStyle(Theme.primaryText)
                    } icon: {
                        Image(systemName: "circle.fill")
                            .foregroundStyle(course.color)
                            .accessibilityHidden(true)
                    }
                    .tag(course.id as Course.ID?)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
        } header: {
            Text("Class or Activity")
                .foregroundStyle(Theme.primaryText)
        }
        .listRowBackground(Theme.surface)
    }

    private func save() {
        guard let assignment = viewModel.makeAssignment() else { return }
        onSave(assignment)
        dismiss()
    }
}

#Preview {
    AddAssignmentView(courses: Course.sampleData) { _ in }
}

#Preview("No Classes") {
    AddAssignmentView(courses: []) { _ in }
}
