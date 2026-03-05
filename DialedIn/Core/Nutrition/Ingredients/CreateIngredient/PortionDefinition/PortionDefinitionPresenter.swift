import SwiftUI

@Observable
@MainActor
class PortionDefinitionPresenter {
    
    private let interactor: PortionDefinitionInteractor
    private let router: PortionDefinitionRouter
    
    var nutritionDefinitionOption: NutritionDefinitionOption = .serving
    
    var servingWeight: String = ""
    var portionSize: String = "1"
    var portionName: String = "portion"
    
    var portionWeight: String = ""
    var weightPortionSize: String = ""
    var weightPortionName: String = ""
    
    var portionVolume: String = ""
    var volumePortionSize: String = ""
    var volumePortionName: String = ""
    
    var canSave: Bool {
        switch nutritionDefinitionOption {
        case .serving:
            return (!portionSize.isEmpty && !portionName.isEmpty)
        default:
            return true
        }
    }
    
    init(interactor: PortionDefinitionInteractor, router: PortionDefinitionRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear(delegate: PortionDefinitionDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }
    
    func onViewDisappear(delegate: PortionDefinitionDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }
    
    func onNextPressed() {
        switch nutritionDefinitionOption {
        case .serving:
            guard !portionSize.isEmpty, !portionName.isEmpty else { return }
            router.showFoodDefinitionView(
                delegate: FoodDefinitionDelegate(
                    nutritionDefinitionOption: self.nutritionDefinitionOption,
                    servingWeight: self.servingWeight,
                    portionSize: self.portionSize,
                    portionName: self.portionName
                )
            )
        case .standardMass:
            router.showFoodDefinitionView(
                delegate: FoodDefinitionDelegate(
                    nutritionDefinitionOption: self.nutritionDefinitionOption,
                    portionWeight: self.portionWeight,
                    weightPortionSize: self.weightPortionSize,
                    weightPortionName: self.weightPortionName
                )
            )
        case .standardVolume:
            router.showFoodDefinitionView(
                delegate: FoodDefinitionDelegate(
                    nutritionDefinitionOption: self.nutritionDefinitionOption,
                    portionVolume: self.portionVolume,
                    volumePortionSize: self.volumePortionSize,
                    volumePortionName: self.volumePortionName
                )
            )
        }
    }
}

extension PortionDefinitionPresenter {
    
    enum Event: LoggableEvent {
        case onAppear(delegate: PortionDefinitionDelegate)
        case onDisappear(delegate: PortionDefinitionDelegate)

        var eventName: String {
            switch self {
            case .onAppear:                 return "PortionDefinitionView_Appear"
            case .onDisappear:              return "PortionDefinitionView_Disappear"
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
