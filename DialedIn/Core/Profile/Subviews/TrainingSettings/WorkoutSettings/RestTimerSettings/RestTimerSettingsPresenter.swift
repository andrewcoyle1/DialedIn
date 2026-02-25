import SwiftUI

@Observable
@MainActor
class RestTimerSettingsPresenter {
    
    private let interactor: RestTimerSettingsInteractor
    private let router: RestTimerSettingsRouter
    
    init(interactor: RestTimerSettingsInteractor, router: RestTimerSettingsRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onTimerDurationPressed() {
        router.showTimerDurationView(delegate: TimerDurationDelegate())
    }
    
    func onViewAppear(delegate: RestTimerSettingsDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }
    
    func onViewDisappear(delegate: RestTimerSettingsDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }
}

extension RestTimerSettingsPresenter {
    
    enum Event: LoggableEvent {
        case onAppear(delegate: RestTimerSettingsDelegate)
        case onDisappear(delegate: RestTimerSettingsDelegate)

        var eventName: String {
            switch self {
            case .onAppear:                 return "RestTimerSettingsView_Appear"
            case .onDisappear:              return "RestTimerSettingsView_Disappear"
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
