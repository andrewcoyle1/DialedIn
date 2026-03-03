import SwiftUI

@Observable
@MainActor
class SmartProgressionSettingsPresenter {
    
    private let interactor: SmartProgressionSettingsInteractor
    private let router: SmartProgressionSettingsRouter
    
    var applyInSession: Bool = false
    
    init(interactor: SmartProgressionSettingsInteractor, router: SmartProgressionSettingsRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear(delegate: SmartProgressionSettingsDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }
    
    func onViewDisappear(delegate: SmartProgressionSettingsDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }
}

extension SmartProgressionSettingsPresenter {
    
    enum Event: LoggableEvent {
        case onAppear(delegate: SmartProgressionSettingsDelegate)
        case onDisappear(delegate: SmartProgressionSettingsDelegate)

        var eventName: String {
            switch self {
            case .onAppear:                 return "SmartProgressionSettingsView_Appear"
            case .onDisappear:              return "SmartProgressionSettingsView_Disappear"
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
