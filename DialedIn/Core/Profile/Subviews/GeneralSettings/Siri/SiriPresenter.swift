import SwiftUI

@Observable
@MainActor
class SiriPresenter {
    
    private let interactor: SiriInteractor
    private let router: SiriRouter
    
    init(interactor: SiriInteractor, router: SiriRouter) {
        self.interactor = interactor
        self.router = router
    }
}
