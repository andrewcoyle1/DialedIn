import SwiftUI

@Observable
@MainActor
class TimerDurationPresenter {
    
    private let interactor: TimerDurationInteractor
    private let router: TimerDurationRouter
    
    init(interactor: TimerDurationInteractor, router: TimerDurationRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear(delegate: TimerDurationDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }
    
    func onViewDisappear(delegate: TimerDurationDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }
}

extension TimerDurationPresenter {
    
    enum Event: LoggableEvent {
        case onAppear(delegate: TimerDurationDelegate)
        case onDisappear(delegate: TimerDurationDelegate)

        var eventName: String {
            switch self {
            case .onAppear:                 return "TimerDurationView_Appear"
            case .onDisappear:              return "TimerDurationView_Disappear"
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
