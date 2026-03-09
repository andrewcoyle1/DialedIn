import SwiftUI

@Observable
@MainActor
class WorkoutCompletedPresenter {
    
    private let interactor: WorkoutCompletedInteractor
    private let router: WorkoutCompletedRouter
    
    init(interactor: WorkoutCompletedInteractor, router: WorkoutCompletedRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear(delegate: WorkoutCompletedDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }
    
    func onViewDisappear(delegate: WorkoutCompletedDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }
}

extension WorkoutCompletedPresenter {
    
    enum Event: LoggableEvent {
        case onAppear(delegate: WorkoutCompletedDelegate)
        case onDisappear(delegate: WorkoutCompletedDelegate)

        var eventName: String {
            switch self {
            case .onAppear:                 return "WorkoutCompletedView_Appear"
            case .onDisappear:              return "WorkoutCompletedView_Disappear"
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
