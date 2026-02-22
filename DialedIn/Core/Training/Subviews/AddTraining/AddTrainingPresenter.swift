import SwiftUI

@Observable
@MainActor
class AddTrainingPresenter {
    
    private let interactor: AddTrainingInteractor
    private let router: AddTrainingRouter
    private let delegate: AddTrainingDelegate
    
    init(interactor: AddTrainingInteractor, router: AddTrainingRouter, delegate: AddTrainingDelegate) {
        self.interactor = interactor
        self.router = router
        self.delegate = delegate
    }
    
    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }
    
    func onViewDisappear() {
        interactor.trackEvent(event: Event.onDisappear)
    }
    
    func onNewProgramPressed() {
        router.dismissScreen()
        delegate.onSelectProgram?()
    }
    
    func onNewEmptyWorkoutPressed() {
        router.dismissScreen()
        delegate.onSelectWorkout?()
    }

    func onNewExercisePressed() {
        router.dismissScreen()
        delegate.onSelectExercise?()
    }

    func dismissScreen() {
        router.dismissScreen()
    }
    
}

extension AddTrainingPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case onDisappear
        
        var eventName: String {
            switch self {
            case .onAppear: return "AddTrainingView_Appear"
            case .onDisappear: return "AddTrainingView_Disappear"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            default:
                return nil
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
