//
//  CreateWorkoutPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI
import PhotosUI

@Observable
@MainActor
class CreateWorkoutPresenter {
    
    private let interactor: CreateWorkoutInteractor
    private let router: CreateWorkoutRouter

    // Optional template for edit mode
    var workoutTemplate: WorkoutTemplateModel?
    
    var workoutName: String = ""
    var workoutTemplateDescription: String?
    var selectedPhotoItem: PhotosPickerItem?
    var selectedImageData: Data?
    var isImagePickerPresented: Bool = false
    var exercises: [ExerciseTemplateModel] = []

    var isSaving: Bool = false
    var saveError: String?
    private(set) var isGenerating: Bool = false
    var generatedImage: UIImage?

    var canSave: Bool {
        !workoutName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var isEditMode: Bool {
        workoutTemplate != nil
    }
    
    init(
        interactor: CreateWorkoutInteractor,
        router: CreateWorkoutRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func onImageSelectorPressed() {
        // Show the image picker sheet for selecting a profile image
        isImagePickerPresented = true
    }
        
    func loadInitialState(workoutTemplate: WorkoutTemplateModel?) {
        self.workoutTemplate = workoutTemplate
        guard let template = workoutTemplate else { return }
        // Pre-populate fields for edit mode
        workoutName = template.name
        workoutTemplateDescription = template.description
        exercises = template.exercises
    }
    
    func cancel() {
        router.dismissScreen()
    }

    func onSavePressed() async throws {
        guard !isSaving, canSave else { return }
        isSaving = true
        
        do {
            guard let userId = interactor.currentUser?.userId else {
                isSaving = false
                return
            }
            
            if let existingTemplate = workoutTemplate {
                try await updateExistingWorkout(existingTemplate: existingTemplate, userId: userId)
            } else {
                try await createNewWorkout(userId: userId)
            }
             
        } catch {
            isSaving = false
            throw error // Re-throw to allow caller to handle the error
        }
        isSaving = false
        router.dismissScreen()
    }
    
    func updateExistingWorkout(existingTemplate: WorkoutTemplateModel, userId: String) async throws {
        let updatedWorkout = WorkoutTemplateModel(
            id: existingTemplate.workoutId,
            authorId: existingTemplate.authorId ?? userId,
            name: workoutName,
            description: workoutTemplateDescription,
            imageURL: existingTemplate.imageURL,
            dateCreated: existingTemplate.dateCreated,
            dateModified: Date(),
            exercises: exercises,
            clickCount: existingTemplate.clickCount,
            bookmarkCount: existingTemplate.bookmarkCount,
            favouriteCount: existingTemplate.favouriteCount
        )
        
        #if canImport(UIKit)
        let uiImage = selectedImageData.flatMap { UIImage(data: $0) } ?? generatedImage
        try await interactor.updateWorkoutTemplate(workout: updatedWorkout, image: uiImage)
        #elseif canImport(AppKit)
        let nsImage = selectedImageData.flatMap { NSImage(data: $0) }
        try await interactor.updateWorkoutTemplate(workout: updatedWorkout, image: nsImage)
        #endif
    }
    
    func createNewWorkout(userId: String) async throws {
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
        try await interactor.createWorkoutTemplate(workout: newWorkout, image: uiImage)
        #elseif canImport(AppKit)
        let nsImage = selectedImageData.flatMap { NSImage(data: $0) }
        try await interactor.createWorkoutTemplate(workout: newWorkout, image: nsImage)
        #endif
        
        // Track created template on the user document
        try await interactor.addCreatedWorkoutTemplate(workoutId: newWorkout.id)
        // Auto-bookmark authored templates
        try await interactor.addBookmarkedWorkoutTemplate(workoutId: newWorkout.id)
        try await interactor.bookmarkWorkoutTemplate(id: newWorkout.id, isBookmarked: true)
    }
    
    func onAddExercisePressed() {
        router.showAddExercisesView(
            delegate: AddExerciseModalDelegate(
                selectedExercises: Binding(
                    get: {
                        self.exercises
                    },
                    set: { newValue in
                        self.exercises = newValue
                    }
                )
            )
        )
    }

    func onGenerateImagePressed() {
        isGenerating = true
        Task {
            do {
                interactor.trackEvent(eventName: "AI_Image_Generate_Start", parameters: [
                    "subject": "workout",
                    "has_name": !workoutName.isEmpty
                ], type: .analytic)
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
                generatedImage = try await interactor.generateImage(input: prompt)
                interactor.trackEvent(eventName: "AI_Image_Generate_Success", parameters: [:], type: .analytic)
            } catch {
                interactor.trackEvent(eventName: "AI_Image_Generate_Fail", parameters: error.eventParameters, type: .severe)
                router.showAlert(error: error)
            }
            isGenerating = false
        }
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

}
