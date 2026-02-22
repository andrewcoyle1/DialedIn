import SwiftUI

@Observable
@MainActor
class CustomiseDashboardPresenter {
    
    private let interactor: CustomiseDashboardInteractor
    private let router: CustomiseDashboardRouter
    
    init(interactor: CustomiseDashboardInteractor, router: CustomiseDashboardRouter) {
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

extension CustomiseDashboardPresenter {
    
    enum Event: LoggableEvent {
        case onAppear
        case onDisappear
        
        var eventName: String {
            switch self {
            case .onAppear:     return "CustomiseDashboardView_Appear"
            case .onDisappear:  return "CustomiseDashboardView_Disappear"
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
