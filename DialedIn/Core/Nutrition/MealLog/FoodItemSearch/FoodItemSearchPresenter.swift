import SwiftUI

@Observable
@MainActor
class FoodItemSearchPresenter {
    
    private let interactor: FoodItemSearchInteractor
    private let router: FoodItemSearchRouter
    
    private(set) var fromHistoryFoodItems: [MealLogModel] = [MealLogModel.mock]
    private(set) var fromCommonFoodItems: [MealLogModel] = [MealLogModel.mock]
    private(set) var fromBrandedFoodItems: [MealLogModel] = [MealLogModel.mock]
    private(set) var fromOpenFoodFactsFoodItems: [MealLogModel] = [MealLogModel.mock]
    
    var searchText: String = ""
    
    init(interactor: FoodItemSearchInteractor, router: FoodItemSearchRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear(delegate: FoodItemSearchDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }
    
    func onViewDisappear(delegate: FoodItemSearchDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }
}

extension FoodItemSearchPresenter {
    
    enum Event: LoggableEvent {
        case onAppear(delegate: FoodItemSearchDelegate)
        case onDisappear(delegate: FoodItemSearchDelegate)

        var eventName: String {
            switch self {
            case .onAppear:                 return "FoodItemSearchView_Appear"
            case .onDisappear:              return "FoodItemSearchView_Disappear"
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

enum FocusField: Hashable {
    case searchBar
}
