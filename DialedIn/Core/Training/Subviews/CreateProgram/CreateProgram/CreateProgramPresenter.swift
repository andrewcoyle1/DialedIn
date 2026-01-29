import SwiftUI

@Observable
@MainActor
class CreateProgramPresenter {
    
    private let interactor: CreateProgramInteractor
    private let router: CreateProgramRouter
    
    init(interactor: CreateProgramInteractor, router: CreateProgramRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onDismissPressed() {
        router.dismissScreen()
    }
    
    func onNextPressed() {
        router.showNameProgramView(delegate: NameProgramDelegate())
    }
}
