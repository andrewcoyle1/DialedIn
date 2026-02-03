import SwiftUI

@Observable
@MainActor
class LegalPresenter {
    
    private let interactor: LegalInteractor
    private let router: LegalRouter
    
    init(interactor: LegalInteractor, router: LegalRouter) {
        self.interactor = interactor
        self.router = router
    }
}
