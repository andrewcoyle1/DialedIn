import SwiftUI

@Observable
@MainActor
class EditWeightRangePresenter {
    
    private let interactor: EditWeightRangeInteractor
    private let router: EditWeightRangeRouter
    
    init(interactor: EditWeightRangeInteractor, router: EditWeightRangeRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onDismissPressed() {
        router.dismissScreen()
    }
}
