import SwiftUI

/// The navigation value for opening an assignment. Wraps the id so it can't be confused with other UUID routes.
struct AssignmentLink: Hashable {
    let id: Assignment.ID
}

struct AssignmentDetailView: View {
    private static let colorBarWidth: CGFloat = 6

    @StateObject private var viewModel: AssignmentDetailViewModel
    @Environment(\.dismiss) private var dismiss

    init(planner: PlannerViewModel, assignmentID: Assignment.ID) {
        _viewModel = StateObject(wrappedValue: AssignmentDetailViewModel(planner: planner, assignmentID: assignmentID))
    }

    var body: some View {
        Group {
            if let assignment = viewModel.assignment {
                details(for: assignment)
            } else {
                ContentUnavailableView("Assignment Not Found", systemImage: "questionmark.folder")
                    .foregroundStyle(Theme.primaryText)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background)
        .navigationTitle("Assignment")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if viewModel.assignment != nil {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: viewModel.startEditing) {
                        Image(systemName: "pencil")
                            .foregroundStyle(Theme.primaryText)
                    }
                    .accessibilityLabel(Text("Edit Assignment"))
                }
            }
        }
        // Waits for the sheet to finish closing before leaving, because a deleted assignment has nothing to show.
        .sheet(isPresented: $viewModel.isEditing, onDismiss: closeIfAssignmentDeleted) {
            if let assignment = viewModel.assignment {
                AddAssignmentView(
                    courses: viewModel.courses,
                    editing: assignment,
                    onSave: { edited, _ in viewModel.save(edited) },
                    onDelete: viewModel.deleteAssignment
                )
            }
        }
    }

    private func closeIfAssignmentDeleted() {
        guard viewModel.isAssignmentDeleted else { return }
        dismiss()
    }

    private func details(for assignment: Assignment) -> some View {
        Form {
            Section {
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: Self.colorBarWidth / 2)
                        .fill(assignment.course.color)
                        .frame(width: Self.colorBarWidth)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(assignment.title)
                            .font(.title2.bold())
                        Text(assignment.course.name)
                            .font(.subheadline)
                            .foregroundStyle(Theme.secondaryText)
                    }
                }
                .padding(.vertical, 4)
            }
            .listRowBackground(Theme.surface)

            Section {
                LabeledContent("Due") {
                    HStack(spacing: 4) {
                        if viewModel.isOverdue {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundStyle(Theme.accent)
                                .accessibilityLabel(Text("Overdue"))
                        }
                        Text(assignment.dueDate, format: .dateTime.weekday(.wide).month().day().hour().minute())
                    }
                }
                LabeledContent(assignment.course.kind == .activity ? "Activity" : "Class", value: assignment.course.name)
                LabeledContent("Apple Calendar") {
                    Text(assignment.isAddedToCalendar ? "Added" : "Not Added")
                }
            }
            .listRowBackground(Theme.surface)

            if !assignment.notes.isEmpty {
                Section {
                    Text(assignment.notes)
                        .textSelection(.enabled)
                } header: {
                    Text("Notes")
                        .foregroundStyle(Theme.primaryText)
                }
                .listRowBackground(Theme.surface)
            }
        }
        .scrollContentBackground(.hidden)
        // Pinned at the bottom, within thumb reach and always visible however long the notes are.
        .safeAreaInset(edge: .bottom) {
            completionControls(for: assignment)
        }
        .foregroundStyle(Theme.primaryText)
        .tint(Theme.primaryText)
    }
}

extension AssignmentDetailView {
    /// One clear action for open work. Once it's done, a plain "Completed" banner replaces it, with a
    /// smaller, clearly worded way to take it back.
    @ViewBuilder
    fileprivate func completionControls(for assignment: Assignment) -> some View {
        VStack(spacing: 8) {
            if assignment.isCompleted {
                Label("Completed", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: Theme.minimumTapTarget)
                    .background(Theme.surface, in: .capsule)
                    .accessibilityAddTraits(.isStaticText)

                Button("Undo Completion") {
                    withAnimation { viewModel.toggleCompletion() }
                }
                .font(.subheadline)
                .frame(minHeight: Theme.minimumTapTarget)
            } else {
                Button {
                    withAnimation { viewModel.toggleCompletion() }
                } label: {
                    Label("Mark as Complete", systemImage: "checkmark.circle.fill")
                        .font(.headline)
                        .foregroundStyle(Theme.primaryText)
                        .frame(maxWidth: .infinity, minHeight: Theme.minimumTapTarget)
                }
                .buttonStyle(.glassProminent)
                .tint(Theme.accent)
            }
        }
        .foregroundStyle(Theme.primaryText)
        .padding(.horizontal)
        .padding(.bottom, 8)
        .sensoryFeedback(.success, trigger: assignment.isCompleted) { _, isCompleted in isCompleted }
    }
}

#if DEBUG
#Preview {
    let planner = PlannerViewModel()
    NavigationStack {
        AssignmentDetailView(planner: planner, assignmentID: planner.assignments[0].id)
    }
}
#endif
