import SwiftUI

@Observable
@MainActor
class SetTrackerRowPresenter {
    
    private let interactor: SetTrackerRowInteractor
    private let router: SetTrackerRowRouter
    
    var exerciseUnitPreferences: [String: (weightUnit: ExerciseWeightUnit, distanceUnit: ExerciseDistanceUnit)] = [:]
    var restPickerTargetSetId: String?
    var restPickerMinutesSelection: Int = 0
    var restPickerSecondsSelection: Int = 0
    var restBeforeSetIdToSec: [String: Int] = [:]
    var onUpdateRestBefore: ((String, Int?) -> Void)?

    var previousLookup: [Int: WorkoutSetModel] = [:]
    var defaultRestDurationSeconds: Int {
        interactor.workoutSettings.defaultRestDurationSeconds
    }

    init(interactor: SetTrackerRowInteractor, router: SetTrackerRowRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear(delegate: SetTrackerRowDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }
    
    func onViewDisappear(delegate: SetTrackerRowDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }
    
    func deleteSet(setId: String, exercise: Binding<WorkoutExerciseModel>) {
        exercise.wrappedValue.sets.removeAll(where: { $0.id == setId })
    }
    
    func onSetComplete(_ exercise: WorkoutExerciseModel, _ set: Binding<WorkoutSetModel>) {
        if set.wrappedValue.completedAt == nil, validateSetData(trackingMode: exercise.trackingMode, set: set.wrappedValue) {
            interactor.startRest(durationSeconds: 90, session: .mock, currentExerciseIndex: 1)
            set.wrappedValue.completedAt = Date()
        } else {
            set.wrappedValue.completedAt = nil
        }
    }

    func onRestPickerRequested(setId: String) {
        restPickerTargetSetId = setId
        let existing = restBeforeSetIdToSec[setId] ?? defaultRestDurationSeconds
        restPickerMinutesSelection = existing / 60
        restPickerSecondsSelection = existing % 60

        router.showRestModal(
            primaryButtonAction: { [weak self] in
                guard let self else { return }
                let total = (self.restPickerMinutesSelection * 60) + self.restPickerSecondsSelection
                let seconds = total > 0 ? total : nil
                self.updateRestBefore(setId: setId, seconds: seconds)
                self.onUpdateRestBefore?(setId, seconds)
                self.router.dismissModal()
            },
            secondaryButtonAction: { [weak self] in self?.router.dismissModal() },
            minutesSelection: Binding(
                get: { self.restPickerMinutesSelection },
                set: { self.restPickerMinutesSelection = $0 }
            ),
            secondsSelection: Binding(
                get: { self.restPickerSecondsSelection },
                set: { self.restPickerSecondsSelection = $0 }
            )
        )
    }

    func updateRestBefore(setId: String, seconds: Int?) {
        if let seconds {
            restBeforeSetIdToSec[setId] = seconds
        } else {
            restBeforeSetIdToSec.removeValue(forKey: setId)
        }
    }

    func onWarmupSetHelpPressed() {
        router.showWarmupSetInfoModal {
            self.router.dismissModal()
        }
    }

    func getUnitPreference(for exercise: WorkoutExerciseModel) -> (weightUnit: ExerciseWeightUnit, distanceUnit: ExerciseDistanceUnit) {
        let templateId: String = exercise.templateId
        if let cached = exerciseUnitPreferences[templateId] {
            return cached
        }
        let preference = interactor.getPreference(templateId: templateId)
        let result = (weightUnit: preference.weightUnit, distanceUnit: preference.distanceUnit)
        exerciseUnitPreferences[templateId] = result
        return result
    }

    func validateSetData(trackingMode: TrackingMode, set: WorkoutSetModel) -> Bool {
        switch trackingMode {
        case .weightReps:
            if let weight = set.weightKg, weight < 0 {
                router.showSimpleAlert(title: "Invalid Set Data", subtitle: "Weight must be a non-negative number")
                return false
            }
            guard let reps = set.reps, reps > 0 else {
                router.showSimpleAlert(title: "Invalid Set Data", subtitle: "Reps must be a positive number")
                return false
            }
            return true
        case .repsOnly:
            guard let reps = set.reps, reps > 0 else {
                router.showSimpleAlert(title: "Invalid Set Data", subtitle: "Reps must be a positive number")
                return false
            }
            return true
        case .timeOnly:
            guard let duration = set.durationSec, duration > 0 else {
                router.showSimpleAlert(title: "Invalid Set Data", subtitle: "Duration must be a positive time")
                return false
            }
            return true
        case .distanceTime:
            guard let distance = set.distanceMeters, distance > 0 else {
                router.showSimpleAlert(title: "Invalid Set Data", subtitle: "Distance must be a positive number")
                return false
            }
            guard let duration = set.durationSec, duration > 0 else {
                router.showSimpleAlert(title: "Invalid Set Data", subtitle: "Duration must be a positive time")
                return false
            }
            return true
        }
    }

    func canComplete(trackingMode: TrackingMode, set: WorkoutSetModel) -> Bool {
        switch trackingMode {
        case .weightReps:
            let hasValidWeight = set.weightKg == nil || set.weightKg! >= 0
            let hasValidReps = set.reps != nil && set.reps! > 0
            return hasValidWeight && hasValidReps
        case .repsOnly:
            return set.reps != nil && set.reps! > 0
        case .timeOnly:
            return set.durationSec != nil && set.durationSec! > 0
        case .distanceTime:
            let hasValidDistance = set.distanceMeters != nil && set.distanceMeters! > 0
            let hasValidTime = set.durationSec != nil && set.durationSec! > 0
            return hasValidDistance && hasValidTime
        }
    }

    func buttonColor(set: WorkoutSetModel, canComplete: Bool) -> Color {
        if set.completedAt != nil {
            return .green
        } else if canComplete {
            return .secondary
        } else {
            return .secondary.opacity(0.3)
        }
    }
}

extension SetTrackerRowPresenter {
    
    enum Event: LoggableEvent {
        case onAppear(delegate: SetTrackerRowDelegate)
        case onDisappear(delegate: SetTrackerRowDelegate)

        var eventName: String {
            switch self {
            case .onAppear:                 return "SetTrackerRowView_Appear"
            case .onDisappear:              return "SetTrackerRowView_Disappear"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .onAppear(delegate: let delegate), .onDisappear(delegate: let delegate):
                return delegate.eventParameters
//            default:
//                return nil
            }
        }
        
        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
    }

}
