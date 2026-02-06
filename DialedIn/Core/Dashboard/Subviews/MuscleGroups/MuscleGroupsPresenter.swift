import SwiftUI

@Observable
@MainActor
class MuscleGroupsPresenter {
    
    private let interactor: MuscleGroupsInteractor
    private let router: MuscleGroupsRouter
    
    var upperMuscles: [Muscles] {
        Muscles.allCases.filter { $0.bodyRegion == .upperBody }
    }

    var lowerMuscles: [Muscles] {
        Muscles.allCases.filter { $0.bodyRegion == .lowerBody }
    }

    init(interactor: MuscleGroupsInteractor, router: MuscleGroupsRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onDismissPressed() {
        router.dismissScreen()
    }
}
