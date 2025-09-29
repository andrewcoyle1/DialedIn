//
//  CreateExerciseView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI
import PhotosUI

struct CreateExerciseView: View {
    
    @Environment(ExerciseTemplateManager.self) private var exerciseTemplateManager
    @Environment(AIManager.self) private var aiManager
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var exerciseName: String = ""
    @State private var exerciseDescription: String?
    @State private var instructions: [String] = []
    @State private var muscleGroups: [MuscleGroup] = []
    @State private var category: ExerciseCategory = .none
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var isImagePickerPresented: Bool = false
    
    @State private var isGenerating: Bool = false
    @State private var generatedImage: UIImage?
    
    @State private var showDebugView: Bool = false
    @State private var alert: AnyAppAlert?
    
    @State var isSaving: Bool = false
    private var canSave: Bool {
        !exerciseName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            List {
                imageSection
                nameSection
                muscleGroupSection
                categorySection
            }
            .navigationBarTitle("New Custom Exercise")
            .navigationSubtitle("Define details and muscle groups")
            .navigationBarTitleDisplayMode(.large)
            .scrollIndicators(.hidden)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        onCancelPressed()
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
                                // TODO: Add log manager
                            }
                        } else {
                            await MainActor.run {
                                // TODO: Add log manager
                            }
                        }
                    } catch {
                        await MainActor.run {
                            // TODO: Add log manager
                        }
                    }
                }
            }
            .sheet(isPresented: $showDebugView) {
                DevSettingsView()
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
                                #elseif canImport(AppKit)
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
                Text("Exercise Image")
                Spacer()
                Button {
                    onGenerateImagePressed()
                } label: {
                    Image(systemName: "wand.and.sparkles")
                        .font(.system(size: 20))
                }
                .disabled(isGenerating || exerciseName.isEmpty)
            }
        }
        .removeListRowFormatting()
    }
    
    private func onGenerateImagePressed() {
        isGenerating = true
        Task {
            do {
                logManager.trackEvent(eventName: "AI_Image_Generate_Start", parameters: [
                    "subject": "exercise",
                    "has_name": !exerciseName.isEmpty
                ])
                let imageDescriptionBuilder = ImageDescriptionBuilder(
                    subject: .exercise,
                    mode: .marketingConcise,
                    name: exerciseName,
                    description: exerciseDescription,
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
    
    private var nameSection: some View {
        Section {
            TextField("Add name", text: $exerciseName)
            TextField("Add description", text: Binding(
                get: { exerciseDescription ?? "" },
                set: { newValue in
                    exerciseDescription = newValue.isEmpty ? nil : newValue
                }
            ))
        } header: {
            Text("Name")
        }
    }
    
    private var muscleGroupSection: some View {
        Section {
            ForEach(MuscleGroup.allCases.filter { $0 != .none }, id: \.self) { group in
                MultipleSelectionRow(
                    title: group.description,
                    isSelected: muscleGroups.contains(group)
                ) {
                    if muscleGroups.contains(group) {
                        muscleGroups.removeAll(where: { $0 == group })
                    } else {
                        muscleGroups.append(group)
                    }
                }
            }
        } header: {
            Text("Muscle Groups")
        }
    }
    
    private var categorySection: some View {
        Section {
            Picker("Select Category", selection: $category) {
                ForEach(ExerciseCategory.allCases, id: \.self) { cat in
                    Text(cat.description).tag(cat)
                }
            }
            .pickerStyle(.menu)
        } header: {
            Text("Category")
        }
    }
    
    private func onImageSelectorPressed() {
        // Show the image picker sheet for selecting a profile image
        isImagePickerPresented = true
    }
    
    private func onSavePressed() async throws {
        guard !isSaving, canSave else { return }
        isSaving = true
        
        do {
            guard let userId = userManager.currentUser?.userId else {
                return
            }
            
            let newExercise = ExerciseTemplateModel(
                exerciseId: UUID().uuidString,
                authorId: userId,
                name: exerciseName,
                description: exerciseDescription,
                instructions: instructions,
                type: category,
                muscleGroups: muscleGroups,
                dateCreated: Date(),
                dateModified: Date(),
                clickCount: 0
            )
            
            #if canImport(UIKit)
            let uiImage = selectedImageData.flatMap { UIImage(data: $0) } ?? generatedImage
            try await exerciseTemplateManager.createExerciseTemplate(exercise: newExercise, image: uiImage)
            #elseif canImport(AppKit)
            let nsImage = selectedImageData.flatMap { NSImage(data: $0) }
            try await exerciseTemplateManager.createExerciseTemplate(exercise: newExercise, image: nsImage)
            #endif
            // Track created template on the user document
            try await userManager.addCreatedExerciseTemplate(exerciseId: newExercise.id)
            // Auto-bookmark authored templates
            try await userManager.addBookmarkedExerciseTemplate(exerciseId: newExercise.id)
            try await exerciseTemplateManager.bookmarkExerciseTemplate(id: newExercise.id, isBookmarked: true)
        } catch {
            logManager.trackEvent(
                eventName: "exercise_create_failed",
                parameters: [
                    "error": String(describing: error),
                    "has_image": (selectedImageData != nil || generatedImage != nil)
                ],
                type: .severe
            )
            alert = AnyAppAlert(title: "Save Failed", subtitle: error.localizedDescription)
            isSaving = false
            return
        }
        isSaving = false
        dismiss()
    }
    
    private func onCancelPressed() {
        dismiss()
    }
}

#Preview("As sheet") {
    @Previewable @State var isPresented: Bool = true
    Button {
        isPresented = true
    } label: {
        Text("Present")
    }
    .sheet(isPresented: $isPresented) {
        CreateExerciseView()
    }
    .previewEnvironment()
}

#Preview("Is saving") {
    @Previewable @State var isPresented: Bool = true
    Button {
        isPresented = true
    } label: {
        Text("Present")
    }
    .sheet(isPresented: $isPresented) {
        CreateExerciseView()
    }
    .previewEnvironment()
}

#Preview("As fullscreen cover") {
    @Previewable @State var isPresented: Bool = true
    Button {
        isPresented = true
    } label: {
        Text("Present")
    }
    .fullScreenCover(isPresented: $isPresented) {
        CreateExerciseView()
    }
    .previewEnvironment()
    
}
