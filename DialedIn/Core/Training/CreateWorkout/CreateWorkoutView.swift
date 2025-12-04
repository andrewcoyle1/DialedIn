//
//  CreateWorkoutView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI
import PhotosUI
import SwiftfulRouting

struct CreateWorkoutDelegate {
    var workoutTemplate: WorkoutTemplateModel?
}

struct CreateWorkoutView: View {

    @State var presenter: CreateWorkoutPresenter

    var delegate: CreateWorkoutDelegate

    var body: some View {
        List {
            imageSection
            nameSection
            exerciseTemplatesSection
        }
        .navigationTitle(presenter.isEditMode ? "Edit Workout" : "Create Workout")
        .onAppear { presenter.loadInitialState(workoutTemplate: delegate.workoutTemplate) }
        .toolbar {
            toolbarContent
        }
        .onChange(of: presenter.selectedPhotoItem) {
            guard let newItem = presenter.selectedPhotoItem else { return }
            
            Task {
                do {
                    if let data = try await newItem.loadTransferable(type: Data.self) {
                        await MainActor.run {
                            presenter.selectedImageData = data
                        }
                    }
                } catch {
                    
                }
            }
        }
        .alert("Error", isPresented: .constant(presenter.saveError != nil)) {
            Button("OK") {
                presenter.saveError = nil
            }
        } message: {
            Text(presenter.saveError ?? "")
        }
    }
    
    private var imageSection: some View {
        Section {
            HStack {
                Spacer()
                Button {
                    presenter.onImageSelectorPressed()
                } label: {
                    ZStack {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.001))
                        Group {
                            if let data = presenter.selectedImageData {
                                #if canImport(UIKit)
                                if let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                }
                                #elseif canImport(AppKit)
                                if let nsImage = NSImage(data: data) {
                                    Image(nsImage: nsImage)
                                        .resizable()
                                        .scaledToFill()
                                }
                                #endif
                            } else {
                                #if canImport(UIKit)
                                if let image = presenter.generatedImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    Image(systemName: "dumbbell.fill")
                                        .font(.system(size: 120))
                                        .foregroundStyle(.accent)
                                }
                                #else
                                Image(systemName: "dumbbell.fill")
                                    .font(.system(size: 120))
                                    .foregroundStyle(.accent)
                                #endif
                            }
                        }
                    }
                    .frame(width: 120, height: 120)
                }
                .photosPicker(isPresented: $presenter.isImagePickerPresented, selection: $presenter.selectedPhotoItem, matching: .images)
                Spacer()
            }
        } header: {
            HStack {
                Text("Workout Image")
                Spacer()
                Button {
                    presenter.onGenerateImagePressed()
                } label: {
                    Image(systemName: "wand.and.sparkles")
                        .font(.system(size: 20))
                }
                .disabled(presenter.isGenerating || presenter.workoutName.isEmpty)
            }
        }
        .removeListRowFormatting()
    }
    
    private var nameSection: some View {
        Section {
            TextField("Enter workout name", text: $presenter.workoutName)
            TextField("Enter workout description", text: Binding(
                get: { presenter.workoutTemplateDescription ?? "" },
                set: { newValue in
                    presenter.workoutTemplateDescription = newValue.isEmpty ? nil : newValue
                }
            ))
        } header: {
            Text("Workout name")
        }
    }
    
    private var exerciseTemplatesSection: some View {
        Section {
            if !presenter.exercises.isEmpty {
                ForEach(presenter.exercises) {exercise in
                    CustomListCellView(imageName: exercise.imageURL, title: exercise.name, subtitle: exercise.description)
                        .removeListRowFormatting()
                }
            } else {
                Text("No exercise templates added yet.")
                    .foregroundStyle(.secondary)
            }
            Button {
                presenter.onAddExercisePressed()
            } label: {
                Text("Add exercise template")
            }
        } header: {
            HStack {
                Text("Exercise templates")
                Spacer()
                Button {
                    presenter.onAddExercisePressed()
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.cancel()
            } label: {
            Image(systemName: "xmark")
            }
        }
        #if DEBUG || MOCK
        ToolbarSpacer(.fixed, placement: .topBarLeading)
        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                Task {
                    do {
                        try await presenter.onSavePressed()
                    } catch {
                        await MainActor.run {
                            presenter.saveError = "Failed to save workout. Please try again."
                        }
                    }
                }
            } label: {
            Image(systemName: "checkmark")
            }
            .buttonStyle(.glassProminent)
            .disabled(!presenter.canSave || presenter.isSaving)
        }
    }
}

#Preview("With Exercises") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
        RouterView { router in
            builder.createWorkoutView(router: router, delegate: CreateWorkoutDelegate(workoutTemplate: .mock))
        }
    .previewEnvironment()
}

#Preview("Without Exercises") {
    let builder = CoreBuilder(container: DevPreview.shared.container)

    RouterView { router in
        builder.createWorkoutView(router: router, delegate: CreateWorkoutDelegate())
    }
    .previewEnvironment()
}
