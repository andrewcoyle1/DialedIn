import SwiftUI

@Observable
@MainActor
class SetTargetPresenter {
    
    private let interactor: SetTargetInteractor
    private let router: SetTargetRouter
    
    init(interactor: SetTargetInteractor, router: SetTargetRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onDismissPressed() {
        router.dismissScreen()
    }
}
