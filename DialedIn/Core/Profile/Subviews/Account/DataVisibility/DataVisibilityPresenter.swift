import SwiftUI

@Observable
@MainActor
class DataVisibilityPresenter {
    
    private let interactor: DataVisibilityInteractor
    private let router: DataVisibilityRouter
    
    init(interactor: DataVisibilityInteractor, router: DataVisibilityRouter) {
        self.interactor = interactor
        self.router = router
    }
}
