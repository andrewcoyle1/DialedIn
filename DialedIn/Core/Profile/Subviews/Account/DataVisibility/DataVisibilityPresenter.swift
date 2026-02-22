import SwiftUI

@Observable
@MainActor
class DataVisibilityPresenter {
    
    private let interactor: DataVisibilityInteractor
    private let router: DataVisibilityRouter
    
    init(interactor: DataVisibilityInteractor, router: DataVisibilityRouter) {
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

extension DataVisibilityPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case onDisappear
        
        var eventName: String {
            switch self {
            case .onAppear:     return "DataVisibilityView_Appear"
            case .onDisappear:  return "DataVisibilityView_Disappear"
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
