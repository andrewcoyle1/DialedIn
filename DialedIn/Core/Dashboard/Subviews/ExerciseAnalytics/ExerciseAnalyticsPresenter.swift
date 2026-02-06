import SwiftUI

@Observable
@MainActor
class ExerciseAnalyticsPresenter {
    
    private let interactor: ExerciseAnalyticsInteractor
    private let router: ExerciseAnalyticsRouter
    
    var isNeverExpanded: Bool = false
    
    init(interactor: ExerciseAnalyticsInteractor, router: ExerciseAnalyticsRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onDismissPressed() {
        router.dismissScreen()
    }
}
