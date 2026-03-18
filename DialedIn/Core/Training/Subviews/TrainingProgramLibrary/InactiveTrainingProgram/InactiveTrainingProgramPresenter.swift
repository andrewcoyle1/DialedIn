import SwiftUI

@Observable
@MainActor
class InactiveTrainingProgramPresenter {
    
    private let interactor: InactiveTrainingProgramInteractor
    private let router: InactiveTrainingProgramRouter
    
    init(interactor: InactiveTrainingProgramInteractor, router: InactiveTrainingProgramRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear(delegate: InactiveTrainingProgramDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }
    
    func onViewDisappear(delegate: InactiveTrainingProgramDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }
}

extension InactiveTrainingProgramPresenter {
    
    enum Event: LoggableEvent {
        case onAppear(delegate: InactiveTrainingProgramDelegate)
        case onDisappear(delegate: InactiveTrainingProgramDelegate)

        var eventName: String {
            switch self {
            case .onAppear:                 return "InactiveTrainingProgramView_Appear"
            case .onDisappear:              return "InactiveTrainingProgramView_Disappear"
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
