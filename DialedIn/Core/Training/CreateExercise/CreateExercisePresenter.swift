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

    var trackableMetricA: TrackableExerciseMetric?
    var trackableMetricB: TrackableExerciseMetric?

    var exerciseType: ExerciseType?
    
    var laterality: Laterality?
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif

    private(set) var isGenerating: Bool = false
    private(set) var generatedImage: UIImage?
    var isSaving: Bool = false

    var canSave: Bool {
        let trimmedName = exerciseName?.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasName = !(trimmedName?.isEmpty ?? true)
        let hasMetric = trackableMetricA != nil || trackableMetricB != nil
        return hasName && hasMetric
    }
    
    init(
        interactor: CreateExerciseInteractor,
        router: CreateExerciseRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func trackableMetricPressed(navigationTitle: String, metric: Binding<TrackableExerciseMetric?>) {
        pickItem(navigationTitle: navigationTitle, item: metric, canDelete: true, detents: nil)
    }
    
    func exerciseTypePressed(navigationTitle: String, type: Binding<ExerciseType?>) {
        pickItem(navigationTitle: navigationTitle, item: type, canDelete: false, detents: .fraction(0.45))
    }
    
    func lateralityPressed(navigationTitle: String, item: Binding<Laterality?>) {
        pickItem(navigationTitle: navigationTitle, item: item, canDelete: false, detents: .fraction(0.5))
    }
    
    private func pickItem<Item: PickableItem>(navigationTitle: String, item: Binding<Item?>, canDelete: Bool, detents: PresentationDetentTransformable?) {
        router.showEnumPickerView(
            delegate: EnumPickerDelegate<Item>(
                navigationTitle: navigationTitle,
                chosenItem: item,
                canDelete: canDelete
            ),
            detentsInput: detents
        )
    }
    
    func onNextPressed() {
        let trimmedName = exerciseName?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let name = trimmedName, !name.isEmpty else { return }

        if trackableMetricA == nil, let onlyMetric = trackableMetricB {
            trackableMetricA = onlyMetric
            trackableMetricB = nil
        }

        guard let trackableMetricA else { return }
        router.showMuscleGroupPickerView(
            delegate: MuscleGroupPickerDelegate(
                name: name,
                trackableMetricA: trackableMetricA,
                trackableMetricB: trackableMetricB,
                exerciseType: exerciseType,
                laterality: laterality
            )
        )
    }

    func onCancelPressed() {
        router.dismissScreen()
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
