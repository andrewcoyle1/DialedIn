import SwiftUI

@Observable
@MainActor
class FoodLogSettingsPresenter {
    
    private let interactor: FoodLogSettingsInteractor
    private let router: FoodLogSettingsRouter
    
    init(interactor: FoodLogSettingsInteractor, router: FoodLogSettingsRouter) {
        self.interactor = interactor
        self.router = router
    }
}
