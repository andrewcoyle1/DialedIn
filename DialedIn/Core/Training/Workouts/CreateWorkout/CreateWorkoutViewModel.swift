//
//  CreateWorkoutViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI
import PhotosUI

@Observable
@MainActor
class CreateWorkoutViewModel {
    private let userManager: UserManager
    private let workoutTemplateManager: WorkoutTemplateManager
    private let aiManager: AIManager
    private let logManager: LogManager
    
    // Optional template for edit mode
    var workoutTemplate: WorkoutTemplateModel?
    
    var workoutName: String = ""
    var workoutTemplateDescription: String?
    var selectedPhotoItem: PhotosPickerItem?
    var selectedImageData: Data?
    var isImagePickerPresented: Bool = false
    var exercises: [ExerciseTemplateModel] = []

    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif

    var isSaving: Bool = false
    var showAddExerciseModal: Bool = false
    var saveError: String?
    private(set) var isGenerating: Bool = false
    var generatedImage: UIImage?
    var alert: AnyAppAlert?
    
    var canSave: Bool {
        !workoutName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var isEditMode: Bool {
        workoutTemplate != nil
    }
    
    init(
        container: DependencyContainer,
        workoutTemplate: WorkoutTemplateModel? = nil
    ) {
        self.userManager = container.resolve(UserManager.self)!
        self.workoutTemplateManager = container.resolve(WorkoutTemplateManager.self)!
        self.aiManager = container.resolve(AIManager.self)!
        self.logManager = container.resolve(LogManager.self)!
        self.workoutTemplate = workoutTemplate
    }
    
    func onImageSelectorPressed() {
        // Show the image picker sheet for selecting a profile image
        isImagePickerPresented = true
    }
        
    func loadInitialState() {
        guard let template = workoutTemplate else { return }
        // Pre-populate fields for edit mode
        workoutName = template.name
        workoutTemplateDescription = template.description
        exercises = template.exercises
    }
    
    func cancel(onDismiss: @escaping () -> Void) {
        onDismiss()
    }
    
    func onSavePressed(onDismiss: @escaping () -> Void) async throws {
        guard !isSaving, canSave else { return }
        isSaving = true
        
        do {
            guard let userId = userManager.currentUser?.userId else {
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
        onDismiss()
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
        try await workoutTemplateManager.updateWorkoutTemplate(workout: updatedWorkout, image: uiImage)
        #elseif canImport(AppKit)
        let nsImage = selectedImageData.flatMap { NSImage(data: $0) }
        try await workoutTemplateManager.updateWorkoutTemplate(workout: updatedWorkout, image: nsImage)
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
    }
    
    func onAddExercisePressed() {
        showAddExerciseModal = true
    }

    func onGenerateImagePressed() {
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
