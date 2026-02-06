import SwiftUI

@Observable
@MainActor
class InsightsAndAnalyticsPresenter {
    
    private let interactor: InsightsAndAnalyticsInteractor
    private let router: InsightsAndAnalyticsRouter
    
    init(interactor: InsightsAndAnalyticsInteractor, router: InsightsAndAnalyticsRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onDismissPressed() {
        router.dismissScreen()
    }
}
