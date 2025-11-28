//
//  CreateExercisePresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI
import PhotosUI

@Observable
@MainActor
class CreateExercisePresenter {
    private let interactor: CreateExerciseInteractor
    private let router: CreateExerciseRouter

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
    var isSaving: Bool = false

    var canSave: Bool {
        !(exerciseName?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
    }
    
    init(
        interactor: CreateExerciseInteractor,
        router: CreateExerciseRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func onImageSelectorPressed() {
        // Show the image picker sheet for selecting an image
        interactor.trackEvent(event: Event.imageSelectorStart)
        isImagePickerPresented = true
    }

    func onImageSelectorChanged(_ newItem: PhotosPickerItem) async {
        do {
            if let data = try await newItem.loadTransferable(type: Data.self) {
                await MainActor.run {
                    selectedImageData = data
                    interactor.trackEvent(event: Event.imageSelectorSuccess)
                }
            } else {
                await MainActor.run {
                    interactor.trackEvent(event: Event.imageSelectorCancel)
                }
            }
        } catch {
            await MainActor.run {
                interactor.trackEvent(event: Event.imageSelectorFail(error: error))
            }
        }
    }

    private func dismissScreen() {
        router.dismissScreen()
    }

    func onSavePressed() async {
        guard let exerciseName, !isSaving, canSave else { return }
        isSaving = true
        
        do {
            interactor.trackEvent(event: Event.createExerciseStart)
            guard let userId = interactor.currentUser?.userId else {
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
            try await interactor.createExerciseTemplate(exercise: newExercise, image: uiImage)
            #elseif canImport(AppKit)
            let nsImage = selectedImageData.flatMap { NSImage(data: $0) }
            try await interactor.createExerciseTemplate(exercise: newExercise, image: nsImage)
            #endif
            // Track created template on the user document
            try await interactor.addCreatedExerciseTemplate(exerciseId: newExercise.id)
            // Auto-bookmark authored templates
            try await interactor.addBookmarkedExerciseTemplate(exerciseId: newExercise.id)
            try await interactor.bookmarkExerciseTemplate(id: newExercise.id, isBookmarked: true)
            interactor.trackEvent(event: Event.createExerciseSuccess)
        } catch {
            interactor.trackEvent(event: Event.createExerciseFail(error: error))
            router.showSimpleAlert(title: "Unable to save exercise", subtitle: "Please check your internet connection and try again.")
            isSaving = false
            return
        }
        isSaving = false
        dismissScreen()
    }

    func onGenerateImagePressed() {
        isGenerating = true
        Task {
            do {
                interactor.trackEvent(event: Event.exerciseGenerateImageStart)
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

                generatedImage = try await interactor.generateImage(input: prompt)
                interactor.trackEvent(event: Event.exerciseGenerateImageSuccess)
            } catch {
                interactor.trackEvent(event: Event.exerciseGenerateImageFail(error: error))
                router.showSimpleAlert(title: "Unable to generate image", subtitle: "Please try again later.")
            }
            isGenerating = false
        }
    }

    func onCancelPressed() {
        dismissScreen()
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
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
