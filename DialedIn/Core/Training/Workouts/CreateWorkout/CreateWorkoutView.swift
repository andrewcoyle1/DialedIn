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
    @Environment(AIManager.self) private var aiManager
    
    @State private var workoutName: String = ""
    @State private var workoutTemplateDescription: String?
    
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var isImagePickerPresented: Bool = false
    @State var exercises: [ExerciseTemplateModel] = []

    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif

    @State var isSaving: Bool = false
    private var canSave: Bool {
        !workoutName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    @State private var showAddExerciseModal: Bool = false
    @State private var saveError: String?
    
    @State private var isGenerating: Bool = false
    @State private var generatedImage: UIImage?
    @State private var alert: AnyAppAlert?
    
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
                #if DEBUG || MOCK
                ToolbarSpacer(.fixed, placement: .topBarLeading)
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showDebugView = true
                    } label: {
                        Image(systemName: "info")
                    }
                }
                #endif
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
            #if DEBUG || MOCK
            .sheet(isPresented: $showDebugView, content: {
                DevSettingsView()
            })
            #endif
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
            .showCustomAlert(alert: $alert)
        }
    }
    
    private var imageSection: some View {
        Section {
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
                                #if canImport(UIKit)
                                if let generatedImage {
                                    Image(uiImage: generatedImage)
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
                .photosPicker(isPresented: $isImagePickerPresented, selection: $selectedPhotoItem, matching: .images)
                Spacer()
            }
        } header: {
            HStack {
                Text("Workout Image")
                Spacer()
                Button {
                    onGenerateImagePressed()
                } label: {
                    Image(systemName: "wand.and.sparkles")
                        .font(.system(size: 20))
                }
                .disabled(isGenerating || workoutName.isEmpty)
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
            let uiImage = selectedImageData.flatMap { UIImage(data: $0) } ?? generatedImage
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

    private func onGenerateImagePressed() {
        isGenerating = true
        Task {
            do {
                logManager.trackEvent(eventName: "AI_Image_Generate_Start", parameters: [
                    "subject": "workout",
                    "has_name": !workoutName.isEmpty
                ])
                let imageDescriptionBuilder = ImageDescriptionBuilder(
                    subject: .workout,
                    mode: .marketingConcise,
                    name: workoutName,
                    description: workoutTemplateDescription,
                    contextNotes: "",
                    desiredStyle: "",
                    backgroundPreference: "",
                    lightingPreference: "",
                    framingNotes: ""
                )
                let prompt = imageDescriptionBuilder.build()
                generatedImage = try await aiManager.generateImage(input: prompt)
                logManager.trackEvent(eventName: "AI_Image_Generate_Success")
            } catch {
                logManager.trackEvent(eventName: "AI_Image_Generate_Fail", parameters: error.eventParameters, type: .severe)
                alert = AnyAppAlert(error: error)
            }
            isGenerating = false
        }
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
