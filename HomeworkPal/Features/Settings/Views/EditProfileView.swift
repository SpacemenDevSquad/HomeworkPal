import PhotosUI
import SwiftUI

/// A short guided sheet: a new photo if the student wants one, then their name, then save.
struct EditProfileView: View {
    @StateObject private var viewModel: EditProfileViewModel
    @Environment(\.dismiss) private var dismiss
    /// The photo picked from the library, loaded into data once chosen.
    @State private var libraryItem: PhotosPickerItem?
    @FocusState private var isNameFocused: Bool

    init(planner: PlannerViewModel) {
        _viewModel = StateObject(wrappedValue: EditProfileViewModel(planner: planner))
    }

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            photoStep
                .navigationDestination(for: EditProfileViewModel.Step.self) { step in
                    switch step {
                    case .crop:
                        if let photo = viewModel.photoToCrop {
                            PhotoCropView(image: photo, onUsePhoto: viewModel.useCroppedPhoto)
                        }
                    case .name:
                        nameStep
                    }
                }
        }
        .tint(Theme.primaryText)
        .presentationBackground(Theme.background)
        .fullScreenCover(isPresented: $viewModel.isShowingCamera) {
            CameraPicker { photo in
                viewModel.cameraFinished(with: photo)
            }
            .ignoresSafeArea()
        }
        .onChange(of: libraryItem) { _, item in
            guard let item else { return }
            Task {
                let data = try? await item.loadTransferable(type: Data.self)
                viewModel.libraryPhotoLoaded(data)
                // Cleared so choosing the same photo again still counts as a new choice.
                libraryItem = nil
            }
        }
        .alert("Something Went Wrong", isPresented: isShowingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    // MARK: - Step 1: Photo

    private var photoStep: some View {
        VStack(spacing: 28) {
            ProfileHeader(name: viewModel.name, photoData: viewModel.photoData)

            Text("Would you like a new photo?")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Theme.primaryText)
                .multilineTextAlignment(.center)

            VStack(spacing: 12) {
                if viewModel.isCameraAvailable {
                    Button(action: viewModel.takePhoto) {
                        Label("Take Photo", systemImage: "camera")
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(Theme.primaryText)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(Theme.accent)
                }

                PhotosPicker(selection: $libraryItem, matching: .images) {
                    Label("Choose from Library", systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(Theme.primaryText)
                }
                .buttonStyle(.glass)

                Button("No Thanks", action: viewModel.skipPhoto)
                    .foregroundStyle(Theme.secondaryText)
                    .frame(minHeight: Theme.minimumTapTarget)
            }
            .controlSize(.large)

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background)
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel) { dismiss() }
            }
        }
    }

    // MARK: - Step 2: Name

    private var nameStep: some View {
        Form {
            Section {
                ProfileHeader(name: viewModel.name, photoData: viewModel.photoData)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
            }

            Section {
                TextField(text: $viewModel.name, prompt: Text("Default User").foregroundStyle(Theme.secondaryText)) {
                    Text("Name")
                }
                .focused($isNameFocused)
                .textContentType(.name)
                .textInputAutocapitalization(.words)
                .submitLabel(.done)
                .onSubmit(save)
            } header: {
                Text("What should we call you?")
                    .foregroundStyle(Theme.primaryText)
            } footer: {
                Text("Leave it blank to stay Default User.")
                    .foregroundStyle(Theme.secondaryText)
            }
            .listRowBackground(Theme.surface)
        }
        .scrollContentBackground(.hidden)
        .background(Theme.background)
        .foregroundStyle(Theme.primaryText)
        .navigationTitle("Your Name")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: save) {
                    Text("Save")
                        .foregroundStyle(Theme.primaryText)
                }
                .buttonStyle(.glassProminent)
                .tint(Theme.accent)
            }
        }
        .onAppear { isNameFocused = true }
    }

    private func save() {
        viewModel.save()
        dismiss()
    }

    private var isShowingError: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }
}

#if DEBUG
#Preview {
    EditProfileView(planner: PlannerViewModel())
}
#endif
