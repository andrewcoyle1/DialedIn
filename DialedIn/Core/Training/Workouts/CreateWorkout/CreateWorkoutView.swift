//
//  CreateWorkoutView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI
import PhotosUI
import CustomRouting

struct CreateWorkoutViewDelegate {
    var workoutTemplate: WorkoutTemplateModel?
}

struct CreateWorkoutView: View {

    @State var viewModel: CreateWorkoutViewModel

    var delegate: CreateWorkoutViewDelegate

    var body: some View {
        List {
            imageSection
            nameSection
            exerciseTemplatesSection
        }
        .navigationTitle(viewModel.isEditMode ? "Edit Workout" : "Create Workout")
        .onAppear { viewModel.loadInitialState(workoutTemplate: delegate.workoutTemplate) }
        .toolbar {
            toolbarContent
        }
        .onChange(of: viewModel.selectedPhotoItem) {
            guard let newItem = viewModel.selectedPhotoItem else { return }
            
            Task {
                do {
                    if let data = try await newItem.loadTransferable(type: Data.self) {
                        await MainActor.run {
                            viewModel.selectedImageData = data
                        }
                    }
                } catch {
                    
                }
            }
        }
        .alert("Error", isPresented: .constant(viewModel.saveError != nil)) {
            Button("OK") {
                viewModel.saveError = nil
            }
        } message: {
            Text(viewModel.saveError ?? "")
        }
    }
    
    private var imageSection: some View {
        Section {
            HStack {
                Spacer()
                Button {
                    viewModel.onImageSelectorPressed()
                } label: {
                    ZStack {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.001))
                        Group {
                            if let data = viewModel.selectedImageData {
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
                                if let image = viewModel.generatedImage {
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
                .photosPicker(isPresented: $viewModel.isImagePickerPresented, selection: $viewModel.selectedPhotoItem, matching: .images)
                Spacer()
            }
        } header: {
            HStack {
                Text("Workout Image")
                Spacer()
                Button {
                    viewModel.onGenerateImagePressed()
                } label: {
                    Image(systemName: "wand.and.sparkles")
                        .font(.system(size: 20))
                }
                .disabled(viewModel.isGenerating || viewModel.workoutName.isEmpty)
            }
        }
        .removeListRowFormatting()
    }
    
    private var nameSection: some View {
        Section {
            TextField("Enter workout name", text: $viewModel.workoutName)
            TextField("Enter workout description", text: Binding(
                get: { viewModel.workoutTemplateDescription ?? "" },
                set: { newValue in
                    viewModel.workoutTemplateDescription = newValue.isEmpty ? nil : newValue
                }
            ))
        } header: {
            Text("Workout name")
        }
    }
    
    private var exerciseTemplatesSection: some View {
        Section {
            if !viewModel.exercises.isEmpty {
                ForEach(viewModel.exercises) {exercise in
                    CustomListCellView(imageName: exercise.imageURL, title: exercise.name, subtitle: exercise.description)
                        .removeListRowFormatting()
                }
            } else {
                Text("No exercise templates added yet.")
                    .foregroundStyle(.secondary)
            }
            Button {
                viewModel.onAddExercisePressed()
            } label: {
                Text("Add exercise template")
            }
        } header: {
            HStack {
                Text("Exercise templates")
                Spacer()
                Button {
                    viewModel.onAddExercisePressed()
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
                viewModel.cancel()
            } label: {
            Image(systemName: "xmark")
            }
        }
        #if DEBUG || MOCK
        ToolbarSpacer(.fixed, placement: .topBarLeading)
        ToolbarItem(placement: .topBarLeading) {
            Button {
                viewModel.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                Task {
                    do {
                        try await viewModel.onSavePressed()
                    } catch {
                        await MainActor.run {
                            viewModel.saveError = "Failed to save workout. Please try again."
                        }
                    }
                }
            } label: {
            Image(systemName: "checkmark")
            }
            .buttonStyle(.glassProminent)
            .disabled(!viewModel.canSave || viewModel.isSaving)
        }
    }
}

#Preview("With Exercises") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
        RouterView { router in
            builder.createWorkoutView(router: router, delegate: CreateWorkoutViewDelegate(workoutTemplate: .mock))
        }
    .previewEnvironment()
}

#Preview("Without Exercises") {
    let builder = CoreBuilder(container: DevPreview.shared.container)

    RouterView { router in
        builder.createWorkoutView(router: router, delegate: CreateWorkoutViewDelegate())
    }
    .previewEnvironment()
}
