import SwiftUI

@Observable
@MainActor
class ExpenditureSettingsPresenter {
    
    private let interactor: ExpenditureSettingsInteractor
    private let router: ExpenditureSettingsRouter
    
    init(interactor: ExpenditureSettingsInteractor, router: ExpenditureSettingsRouter) {
        self.interactor = interactor
        self.router = router
    }
}
