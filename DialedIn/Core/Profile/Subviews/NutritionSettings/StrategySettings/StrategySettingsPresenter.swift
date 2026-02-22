import SwiftUI

@Observable
@MainActor
class StrategySettingsPresenter {
    
    private let interactor: StrategySettingsInteractor
    private let router: StrategySettingsRouter
    
    init(interactor: StrategySettingsInteractor, router: StrategySettingsRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }
    
    func onViewDisappear() {
        interactor.trackEvent(event: Event.onDisappear)
    }
}

extension StrategySettingsPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case onDisappear
        
        var eventName: String {
            switch self {
            case .onAppear: return "StrategySettingsView_Appear"
            case .onDisappear: return "StrategySettingsView_Disappear"
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
