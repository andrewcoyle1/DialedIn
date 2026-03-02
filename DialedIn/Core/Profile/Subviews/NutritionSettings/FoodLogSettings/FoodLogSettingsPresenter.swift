import SwiftUI

@Observable
@MainActor
class FoodLogSettingsPresenter {
    
    private let interactor: FoodLogSettingsInteractor
    private let router: FoodLogSettingsRouter
    
    var showOverages: Bool = false
    
    var showsFoodTimestamps: Bool = true
    var showHourlyMacroTotals: Bool = true
    var showCalendarWeekBanner: Bool = true
    var premove: Bool = false

    var showBrandedFoods: Bool = true
    var showOpenFoodFactsFoods: Bool = true
    
    init(interactor: FoodLogSettingsInteractor, router: FoodLogSettingsRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }
    
    func onViewDisappear() {
        interactor.trackEvent(event: Event.onDisappear)
    }
    
    func onEditHourRangePressed() {
        
    }
    
    func onEditAlignmentPressed() {
        
    }
    
    func onEditAddFoodsToHourPressed() {
        
    }
    
    func onLoggedBannerPressed() {
        
    }
    
    func onTimelineFoodTilesPressed() {
        
    }
    
    func onLoggerFoodTilesPressed() {
        
    }
    
    func onTimeSelectionPressed() {
        
    }
    
    func onFavouriteMeasurementsPressed() {
        
    }
    
    func onOptimisationPressed() {
        
    }
}

extension FoodLogSettingsPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case onDisappear
        
        var eventName: String {
            switch self {
            case .onAppear: return "FoodLogSettingsView_Appear"
            case .onDisappear: return "FoodLogSettingsView_Disappear"
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
