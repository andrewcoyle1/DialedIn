import SwiftUI

@Observable
@MainActor
class FoodDefinitionPresenter {
    
    private let interactor: FoodDefinitionInteractor
    private let router: FoodDefinitionRouter
    
    var foodDefinitionOption: FoodDefinitionOption = .foodDetail
    
    var nutritionWeightUnit: NutritionWeightUnit = .grams
    var energyUnit: EnergyUnit = .kcal

    var isShowingMacros: Bool = true
    var isShowingCarbs: Bool = false
    var isShowingFats: Bool = false
    var isShowingProtein: Bool = false
    var isShowingVitamins: Bool = false
    var isShowingMinerals: Bool = false
    var isShowingOther: Bool = false
    
    init(interactor: FoodDefinitionInteractor, router: FoodDefinitionRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear(delegate: FoodDefinitionDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }
    
    func onViewDisappear(delegate: FoodDefinitionDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }
    
    func onCreatePressed() {
        
    }
    
    func onCreateAndAddPressed() {
        
    }
}

extension FoodDefinitionPresenter {
    
    enum Event: LoggableEvent {
        case onAppear(delegate: FoodDefinitionDelegate)
        case onDisappear(delegate: FoodDefinitionDelegate)

        var eventName: String {
            switch self {
            case .onAppear:                 return "FoodDefinitionView_Appear"
            case .onDisappear:              return "FoodDefinitionView_Disappear"
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
