import SwiftUI

@Observable
@MainActor
class FoodLogSettingsPresenter {
    
    private let interactor: FoodLogSettingsInteractor
    private let router: FoodLogSettingsRouter
    
    init(interactor: FoodLogSettingsInteractor, router: FoodLogSettingsRouter) {
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

extension FoodLogSettingsPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case onDisappear
        
        var eventName: String {
            switch self {
            case .onAppear: return "FoodLogSettingsView_Appear"
            case .onDisappear: return "FoodLogSettingsView_Disappear"
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
