import SwiftUI

@Observable
@MainActor
class ProgramSettingsPresenter {
    
    private let interactor: ProgramSettingsInteractor
    private let router: ProgramSettingsRouter
    
    init(interactor: ProgramSettingsInteractor, router: ProgramSettingsRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onDismissPressed() {
        router.dismissScreen()
    }
}
