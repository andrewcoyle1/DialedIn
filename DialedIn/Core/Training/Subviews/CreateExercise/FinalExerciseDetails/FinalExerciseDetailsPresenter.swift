import SwiftUI

@Observable
@MainActor
class FinalExerciseDetailsPresenter {
    
    private let interactor: FinalExerciseDetailsInteractor
    private let router: FinalExerciseDetailsRouter

    var rangeOfMotion: Int = 0
    var stability: Int = 0
    var bodyweightContribution: Int = 75
    var alternateNames: String = ""
    var exerciseDescription: String = ""

    init(interactor: FinalExerciseDetailsInteractor, router: FinalExerciseDetailsRouter) {
        self.interactor = interactor
        self.router = router
    }

    func onNextPressed(delegate: FinalExerciseDetailsDelegate) {
        let alternateNamesArray: [String] = self.alternateNames.components(separatedBy: ",")
        router.showExerciseSaveView(
            delegate: ExerciseSaveDelegate(
                exerciseName: delegate.name,
                trackableMetricA: delegate.trackableMetricA,
                trackableMetricB: delegate.trackableMetricB,
                type: delegate.exerciseType,
                laterality: delegate.laterality,
                targetMuscles: delegate.targetMuscles,
                isBodyweight: delegate.isBodyweight,
                resistanceEquipment: delegate.resistanceEquipment,
                supportEquipment: delegate.supportEquipment,
                rangeOfMotion: self.rangeOfMotion,
                stability: self.stability,
                bodyweightContribution: self.bodyweightContribution,
                alternativeNames: alternateNamesArray,
                exerciseDescription: self.exerciseDescription
            )
        )
    }

    func onViewAppear(delegate: FinalExerciseDetailsDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }
    
    func onViewDisappear(delegate: FinalExerciseDetailsDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }
}

extension FinalExerciseDetailsPresenter {
    
    enum Event: LoggableEvent {
        case onAppear(delegate: FinalExerciseDetailsDelegate)
        case onDisappear(delegate: FinalExerciseDetailsDelegate)

        var eventName: String {
            switch self {
            case .onAppear:                 return "FinalExerciseDetailsView_Appear"
            case .onDisappear:              return "FinalExerciseDetailsView_Disappear"
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
