import SwiftUI

@Observable
@MainActor
class NutritionAnalyticsPresenter {
    
    private let interactor: NutritionAnalyticsInteractor
    private let router: NutritionAnalyticsRouter
    
    init(interactor: NutritionAnalyticsInteractor, router: NutritionAnalyticsRouter) {
        self.interactor = interactor
        self.router = router
    }
}
