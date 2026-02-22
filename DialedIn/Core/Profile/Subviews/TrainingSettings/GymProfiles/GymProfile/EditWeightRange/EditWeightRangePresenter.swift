import SwiftUI

@Observable
@MainActor
class EditWeightRangePresenter {
    
    private let interactor: EditWeightRangeInteractor
    private let router: EditWeightRangeRouter
    
    init(interactor: EditWeightRangeInteractor, router: EditWeightRangeRouter) {
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

extension EditWeightRangePresenter {
    enum Event: LoggableEvent {
        case onAppear
        case onDisappear
        
        var eventName: String {
            switch self {
            case .onAppear: return "EditWeightRangeView_Appear"
            case .onDisappear: return "EditWeightRangeView_Disappear"
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
