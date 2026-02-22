import SwiftUI

@Observable
@MainActor
class SetTargetPresenter {
    
    private let interactor: SetTargetInteractor
    private let router: SetTargetRouter
    
    init(interactor: SetTargetInteractor, router: SetTargetRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }
    
    func onViewDisappear() {
        interactor.trackEvent(event: Event.onDisappear)
    }

    func onDismissPressed() {
        router.dismissScreen()
    }
    
}

extension SetTargetPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case onDisappear
        
        var eventName: String {
            switch self {
            case .onAppear: return "SetTargetView_Appear"
            case .onDisappear: return "SetTargetView_Disappear"
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
