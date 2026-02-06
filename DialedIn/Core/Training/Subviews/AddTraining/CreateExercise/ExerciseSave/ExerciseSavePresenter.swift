import SwiftUI

@Observable
@MainActor
class ExerciseSavePresenter {
    
    private let interactor: ExerciseSaveInteractor
    private let router: ExerciseSaveRouter

    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    init(interactor: ExerciseSaveInteractor, router: ExerciseSaveRouter) {
        self.interactor = interactor
        self.router = router
    }

    func onCreatePressed(delegate: ExerciseSaveDelegate) {
        guard let userId = currentUser?.userId else { return }
        let model = ExerciseModel(from: delegate, authorId: userId)
        Task {
            do {
                try await interactor.createExerciseTemplate(exercise: model, image: nil)
                router.dismissEnvironment()
            } catch {
                router.showSimpleAlert(title: "Unable to Create Exercise", subtitle: "Please try again.")
            }
        }
    }

    func onCreateAndAddPressed(delegate: ExerciseSaveDelegate) {
        
    }

    func onViewAppear(delegate: ExerciseSaveDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }
    
    func onViewDisappear(delegate: ExerciseSaveDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }
}

extension ExerciseSavePresenter {
    
    enum Event: LoggableEvent {
        case onAppear(delegate: ExerciseSaveDelegate)
        case onDisappear(delegate: ExerciseSaveDelegate)

        var eventName: String {
            switch self {
            case .onAppear:                 return "ExerciseSaveView_Appear"
            case .onDisappear:              return "ExerciseSaveView_Disappear"
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
