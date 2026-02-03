import SwiftUI

@Observable
@MainActor
class CustomiseDashboardPresenter {
    
    private let interactor: CustomiseDashboardInteractor
    private let router: CustomiseDashboardRouter
    
    init(interactor: CustomiseDashboardInteractor, router: CustomiseDashboardRouter) {
        self.interactor = interactor
        self.router = router
    }
}
