import SwiftUI

@Observable
@MainActor
class FoodLibraryPresenter {
    
    private let interactor: FoodLibraryInteractor
    private let router: FoodLibraryRouter
    
    var foodLibraryOption: FoodLibraryOption = .recipes
    
    init(interactor: FoodLibraryInteractor, router: FoodLibraryRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear(delegate: FoodLibraryDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }
    
    func onViewDisappear(delegate: FoodLibraryDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }
}

extension FoodLibraryPresenter {
    
    enum Event: LoggableEvent {
        case onAppear(delegate: FoodLibraryDelegate)
        case onDisappear(delegate: FoodLibraryDelegate)
        
        var eventName: String {
            switch self {
            case .onAppear:                 return "FoodLibraryView_Appear"
            case .onDisappear:              return "FoodLibraryView_Disappear"
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
