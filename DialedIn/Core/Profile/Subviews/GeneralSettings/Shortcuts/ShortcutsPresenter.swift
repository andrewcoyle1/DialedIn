import SwiftUI

@Observable
@MainActor
class ShortcutsPresenter {
    
    private let interactor: ShortcutsInteractor
    private let router: ShortcutsRouter
    
    init(interactor: ShortcutsInteractor, router: ShortcutsRouter) {
        self.interactor = interactor
        self.router = router
    }
}
