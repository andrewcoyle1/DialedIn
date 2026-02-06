import SwiftUI

@Observable
@MainActor
class HabitsPresenter {
    
    private let interactor: HabitsInteractor
    private let router: HabitsRouter
    
    init(interactor: HabitsInteractor, router: HabitsRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onDismissPressed() {
        router.dismissScreen()
    }
}
