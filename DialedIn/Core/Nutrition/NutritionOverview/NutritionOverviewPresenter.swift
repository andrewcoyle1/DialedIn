import SwiftUI

@Observable
@MainActor
class NutritionOverviewPresenter {
    
    private let interactor: NutritionOverviewInteractor
    private let router: NutritionOverviewRouter
    
    var showsContributors: Bool = false
    
    init(interactor: NutritionOverviewInteractor, router: NutritionOverviewRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear(delegate: NutritionOverviewDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }
    
    func onViewDisappear(delegate: NutritionOverviewDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }
}

extension NutritionOverviewPresenter {
    
    enum Event: LoggableEvent {
        case onAppear(delegate: NutritionOverviewDelegate)
        case onDisappear(delegate: NutritionOverviewDelegate)

        var eventName: String {
            switch self {
            case .onAppear:                 return "NutritionOverviewView_Appear"
            case .onDisappear:              return "NutritionOverviewView_Disappear"
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
