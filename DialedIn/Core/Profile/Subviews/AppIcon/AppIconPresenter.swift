import SwiftUI

@Observable
@MainActor
class AppIconPresenter {
    
    private let interactor: AppIconInteractor
    private let router: AppIconRouter
    
    init(interactor: AppIconInteractor, router: AppIconRouter) {
        self.interactor = interactor
        self.router = router
    }
}
