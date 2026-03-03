import SwiftUI

@Observable
@MainActor
class ExpenditureSettingsPresenter {
    
    private let interactor: ExpenditureSettingsInteractor
    private let router: ExpenditureSettingsRouter
    
    var stepInformedUpdates: Bool = false
    var predictiveGoalAdjustments: Bool = true
    
    init(interactor: ExpenditureSettingsInteractor, router: ExpenditureSettingsRouter) {
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

extension ExpenditureSettingsPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case onDisappear
        
        var eventName: String {
            switch self {
            case .onAppear: return "ExpenditureSettingsView_Appear"
            case .onDisappear: return "ExpenditureSettingsView_Disappear"
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
