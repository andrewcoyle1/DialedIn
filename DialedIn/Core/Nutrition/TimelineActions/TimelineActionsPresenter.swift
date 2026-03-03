import SwiftUI

@Observable
@MainActor
class TimelineActionsPresenter {
    
    private let interactor: TimelineActionsInteractor
    private let router: TimelineActionsRouter
    
    init(interactor: TimelineActionsInteractor, router: TimelineActionsRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear(delegate: TimelineActionsDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }
    
    func onViewDisappear(delegate: TimelineActionsDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }
}

extension TimelineActionsPresenter {
    
    enum Event: LoggableEvent {
        case onAppear(delegate: TimelineActionsDelegate)
        case onDisappear(delegate: TimelineActionsDelegate)

        var eventName: String {
            switch self {
            case .onAppear:                 return "TimelineActionsView_Appear"
            case .onDisappear:              return "TimelineActionsView_Disappear"
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
