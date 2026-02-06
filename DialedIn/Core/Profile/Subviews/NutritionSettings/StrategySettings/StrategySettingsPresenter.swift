import SwiftUI

@Observable
@MainActor
class StrategySettingsPresenter {
    
    private let interactor: StrategySettingsInteractor
    private let router: StrategySettingsRouter
    
    init(interactor: StrategySettingsInteractor, router: StrategySettingsRouter) {
        self.interactor = interactor
        self.router = router
    }
}
