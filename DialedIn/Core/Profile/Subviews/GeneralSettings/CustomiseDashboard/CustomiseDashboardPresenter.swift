import SwiftUI

@Observable
@MainActor
class CustomiseAnalyticsPresenter {
    
    private let interactor: CustomiseAnalyticsInteractor
    private let router: CustomiseAnalyticsRouter
    
    init(interactor: CustomiseAnalyticsInteractor, router: CustomiseAnalyticsRouter) {
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

extension CustomiseAnalyticsPresenter {
    
    enum Event: LoggableEvent {
        case onAppear
        case onDisappear
        
        var eventName: String {
            switch self {
            case .onAppear:     return "CustomiseAnalyticsView_Appear"
            case .onDisappear:  return "CustomiseAnalyticsView_Disappear"
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
