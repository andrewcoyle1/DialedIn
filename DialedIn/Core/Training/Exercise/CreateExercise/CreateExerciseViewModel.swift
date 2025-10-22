//
//  CreateExerciseViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI
import PhotosUI

@Observable
@MainActor
class CreateExerciseViewModel {
    private let userManager: UserManager
    private let exerciseTemplateManager: ExerciseTemplateManager
    private let aiManager: AIManager
    private let logManager: LogManager
    
    var selectedPhotoItem: PhotosPickerItem?
    private(set) var selectedImageData: Data?
    var isImagePickerPresented: Bool = false
    var exerciseName: String?
    var exerciseDescription: String?
    private(set) var instructions: [String] = []
    var muscleGroups: [MuscleGroup] = []
    var category: ExerciseCategory = .none

    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif

    private(set) var isGenerating: Bool = false
    private(set) var generatedImage: UIImage?
    var alert: AnyAppAlert?
    var isSaving: Bool = false

    var canSave: Bool {
        !(exerciseName?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
    }
    
    init(
        container: DependencyContainer
    ) {
        self.userManager = container.resolve(UserManager.self)!
        self.exerciseTemplateManager = container.resolve(ExerciseTemplateManager.self)!
        self.aiManager = container.resolve(AIManager.self)!
        self.logManager = container.resolve(LogManager.self)!
    }
    
    func onImageSelectorPressed() {
        // Show the image picker sheet for selecting an image
        logManager.trackEvent(event: Event.imageSelectorStart)
        isImagePickerPresented = true
    }

    func onImageSelectorChanged(_ newItem: PhotosPickerItem) async {
        do {
            if let data = try await newItem.loadTransferable(type: Data.self) {
                await MainActor.run {
                    selectedImageData = data
                    logManager.trackEvent(event: Event.imageSelectorSuccess)
                }
            } else {
                await MainActor.run {
                    logManager.trackEvent(event: Event.imageSelectorCancel)
                }
            }
        } catch {
            await MainActor.run {
                logManager.trackEvent(event: Event.imageSelectorFail(error: error))
            }
        }
    }

    func onSavePressed(onDismiss: @escaping () -> Void) async {
        guard let exerciseName, !isSaving, canSave else { return }
        isSaving = true
        
        do {
            logManager.trackEvent(event: Event.createExerciseStart)
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
            logManager.trackEvent(event: Event.createExerciseSuccess)
        } catch {
            logManager.trackEvent(event: Event.createExerciseFail(error: error))
            alert = AnyAppAlert(title: "Unable to save exercise", subtitle: "Please check your internet connection and try again.")
            isSaving = false
            return
        }
        isSaving = false
        onDismiss()
    }

    func onGenerateImagePressed() {
        isGenerating = true
        Task {
            do {
                logManager.trackEvent(event: Event.exerciseGenerateImageStart)
                let imageDescriptionBuilder = ImageDescriptionBuilder(
                    subject: .exercise,
                    mode: .marketingConcise,
                    name: exerciseName ?? "",
                    description: exerciseDescription,
                    contextNotes: "",
                    desiredStyle: "",
                    backgroundPreference: "",
                    lightingPreference: "",
                    framingNotes: ""
                )

                let prompt = imageDescriptionBuilder.build()

                generatedImage = try await aiManager.generateImage(input: prompt)
                logManager.trackEvent(event: Event.exerciseGenerateImageSuccess)
            } catch {
                logManager.trackEvent(event: Event.exerciseGenerateImageFail(error: error))
                alert = AnyAppAlert(title: "Unable to generate image", subtitle: "Please try again later.")
            }
            isGenerating = false
        }
    }

    func onCancelPressed(onDismiss: @escaping () -> Void) {
        onDismiss()
    }

    enum Event: LoggableEvent {
        case createExerciseStart
        case createExerciseSuccess
        case createExerciseFail(error: Error)
        case exerciseGenerateImageStart
        case exerciseGenerateImageSuccess
        case exerciseGenerateImageFail(error: Error)
        case imageSelectorStart
        case imageSelectorSuccess
        case imageSelectorCancel
        case imageSelectorFail(error: Error)

        var eventName: String {
            switch self {
            case .createExerciseStart:          return "CreateExercise_Start"
            case .createExerciseSuccess:        return "CreateExercise_Success"
            case .createExerciseFail:           return "CreateExercise_Fail"
            case .exerciseGenerateImageStart:   return "ExerciseGenerateImage_Start"
            case .exerciseGenerateImageSuccess: return "ExerciseGenerateImage_Success"
            case .exerciseGenerateImageFail:    return "ExerciseGenerateImage_Fail"
            case .imageSelectorStart:           return "ExerciseImageSelector_Start"
            case .imageSelectorSuccess:         return "ExerciseImageSelector_Success"
            case .imageSelectorCancel:          return "ExerciseImageSelector_Cancel"
            case .imageSelectorFail:            return "ExerciseImageSelector_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .createExerciseFail(error: let error), .exerciseGenerateImageFail(error: let error), .imageSelectorFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .createExerciseFail, .exerciseGenerateImageFail, .imageSelectorFail:
                return .severe
            default:
                return .analytic

            }
        }
    }
}
