//
//  CreateWorkoutView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI
import PhotosUI

struct CreateWorkoutView: View {
    
    @Environment(WorkoutTemplateManager.self) private var workoutTemplateManager
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var workoutName: String = ""
    @State private var workoutTemplateDescription: String?
    
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var isImagePickerPresented: Bool = false
    @State var exercises: [ExerciseTemplateModel] = []
    
    @State private var showDebugView: Bool = false
    
    @State var isSaving: Bool = false
    private var canSave: Bool {
        !workoutName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    @State private var showAddExerciseModal: Bool = false
    @State private var saveError: String?
    
    var body: some View {
        NavigationStack {
            List {
                imageSection
                nameSection
                exerciseTemplatesSection
            }
            .navigationTitle("Create Workout")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        cancel()
                    } label: {
                    Image(systemName: "xmark")
                    }
                }
                ToolbarSpacer(.fixed, placement: .topBarLeading)
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showDebugView = true
                    } label: {
                        Image(systemName: "info")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            do {
                                try await onSavePressed()
                            } catch {
                                await MainActor.run {
                                    saveError = "Failed to save workout. Please try again."
                                }
                            }
                        }
                    } label: {
                    Image(systemName: "checkmark")
                    }
                    .buttonStyle(.glassProminent)
                    .disabled(!canSave || isSaving)
                }
            }
            .onChange(of: selectedPhotoItem) {
                guard let newItem = selectedPhotoItem else { return }
                
                Task {
                    do {
                        if let data = try await newItem.loadTransferable(type: Data.self) {
                            await MainActor.run {
                                selectedImageData = data
                            }
                        }
                    } catch {
                        
                    }
                }
            }
            .sheet(isPresented: $showDebugView, content: {
                DevSettingsView()
            })
            .sheet(isPresented: $showAddExerciseModal) {
                AddExerciseModal(selectedExercises: $exercises)
            }
            .alert("Error", isPresented: .constant(saveError != nil)) {
                Button("OK") {
                    saveError = nil
                }
            } message: {
                Text(saveError ?? "")
            }
        }
    }
    
    private var imageSection: some View {
        Section("Workout Image") {
            HStack {
                Spacer()
                Button {
                    onImageSelectorPressed()
                } label: {
                    ZStack {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.001))
                        Group {
                            if let data = selectedImageData {
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
                                Image(systemName: "dumbbell.fill")
                                    .font(.system(size: 120))
                                    .foregroundStyle(.accent)
                            }
                        }
                    }
                    .frame(width: 120, height: 120)
                }
                .photosPicker(isPresented: $isImagePickerPresented, selection: $selectedPhotoItem, matching: .images)
                Spacer()
            }
        }
        .removeListRowFormatting()
    }
    
    private var nameSection: some View {
        Section {
            TextField("Enter workout name", text: $workoutName)
            TextField("Enter workout description", text: Binding(
                get: { workoutTemplateDescription ?? "" },
                set: { newValue in
                    workoutTemplateDescription = newValue.isEmpty ? nil : newValue
                }
            ))
        } header: {
            Text("Workout name")
        }
    }
    
    private var exerciseTemplatesSection: some View {
        Section {
            if !exercises.isEmpty {
                ForEach(exercises) {exercise in
                    CustomListCellView(imageName: exercise.imageURL, title: exercise.name, subtitle: exercise.description)
                        .removeListRowFormatting()
                }
            } else {
                Text("No exercise templates added yet.")
                    .foregroundStyle(.secondary)
            }
            Button {
                onAddExercisePressed()
            } label: {
                Text("Add exercise template")
            }
        } header: {
            HStack {
                Text("Exercise templates")
                Spacer()
                Button {
                    onAddExercisePressed()
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
    }
    
    private func onImageSelectorPressed() {
        // Show the image picker sheet for selecting a profile image
        isImagePickerPresented = true
    }
    
    private func cancel() {
        dismiss()
    }
    
    private func onSavePressed() async throws {
        guard !isSaving, canSave else { return }
        isSaving = true
        
        do {
            guard let userId = userManager.currentUser?.userId else {
                isSaving = false
                return
            }
            
            let newWorkout = WorkoutTemplateModel(
                id: UUID().uuidString,
                authorId: userId,
                name: workoutName,
                description: workoutTemplateDescription,
                imageURL: nil,
                dateCreated: Date(),
                dateModified: Date(),
                exercises: exercises
            )
            
            #if canImport(UIKit)
            let uiImage = selectedImageData.flatMap { UIImage(data: $0) }
            try await workoutTemplateManager.createWorkoutTemplate(workout: newWorkout, image: uiImage)
            #elseif canImport(AppKit)
            let nsImage = selectedImageData.flatMap { NSImage(data: $0) }
            try await workoutTemplateManager.createWorkoutTemplate(workout: newWorkout, image: nsImage)
            #endif
            
            // Track created template on the user document
            try await userManager.addCreatedWorkoutTemplate(workoutId: newWorkout.id)
            // Auto-bookmark authored templates
            try await userManager.addBookmarkedWorkoutTemplate(workoutId: newWorkout.id)
            try await workoutTemplateManager.bookmarkWorkoutTemplate(id: newWorkout.id, isBookmarked: true)
             
        } catch {
            
            isSaving = false
            throw error // Re-throw to allow caller to handle the error
        }
        isSaving = false
        dismiss()
    }
    
    private func onAddExercisePressed() {
        showAddExerciseModal = true
    }
}

#Preview("With Exercises") {
    @Previewable @State var showingSheet: Bool = true
    Button("Show Sheet") {
        showingSheet = true
    }
        .sheet(isPresented: $showingSheet) {
            CreateWorkoutView()
        }
        .previewEnvironment()
}

#Preview("Without Exercises") {
    @Previewable @State var showingSheet: Bool = true
    Button("Show Sheet") {
        showingSheet = true
    }
        .sheet(isPresented: $showingSheet) {
            CreateWorkoutView(exercises: [])
        }
        .previewEnvironment()
}
