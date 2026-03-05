import SwiftUI

@Observable
@MainActor
class FoodItemQuickAddPresenter {
    
    private let interactor: FoodItemQuickAddInteractor
    private let router: FoodItemQuickAddRouter
    
    var quickAddName: String = ""
    var energyValue: Double?
    var unitOfEnergy: EnergyUnit = .kcal
    
    var proteinValue: Double?
    var carbsValue: Double?
    var fatsValue: Double?
    var weightUnit: NutritionWeightUnit = .grams
    
    var alcoholValue: Double?
    
    var computedTotalEnergy: Int {
        let proteinValue: Double = self.proteinValue ?? 0.0
        let carbsValue: Double = self.carbsValue ?? 0.0
        let fatsValue: Double = self.fatsValue ?? 0.0
        let alcoholValue: Double = self.alcoholValue ?? 0.0
        let totalEnergy: Double = (proteinValue * 4.0) + (carbsValue * 4.0) + (fatsValue * 9.0) + (alcoholValue * 7.0)
        
        return Int(totalEnergy.rounded())
    }
    
    init(interactor: FoodItemQuickAddInteractor, router: FoodItemQuickAddRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear(delegate: FoodItemQuickAddDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }
    
    func onViewDisappear(delegate: FoodItemQuickAddDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }
}

extension FoodItemQuickAddPresenter {
    
    enum Event: LoggableEvent {
        case onAppear(delegate: FoodItemQuickAddDelegate)
        case onDisappear(delegate: FoodItemQuickAddDelegate)

        var eventName: String {
            switch self {
            case .onAppear:                 return "FoodItemQuickAddView_Appear"
            case .onDisappear:              return "FoodItemQuickAddView_Disappear"
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
