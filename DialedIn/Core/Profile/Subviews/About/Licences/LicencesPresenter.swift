import SwiftUI

@Observable
@MainActor
class LicencesPresenter {
    
    private let interactor: LicencesInteractor
    private let router: LicencesRouter
    
    init(interactor: LicencesInteractor, router: LicencesRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onDismissPressed() {
        router.dismissScreen()
    }
}
