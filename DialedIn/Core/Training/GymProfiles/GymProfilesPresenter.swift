import SwiftUI

@Observable
@MainActor
class GymProfilesPresenter {
    
    private let interactor: GymProfilesInteractor
    private let router: GymProfilesRouter
    
    private(set) var gymProfiles: [GymProfileModel] = [GymProfileModel.mock]
    var numGyms: Int {
        gymProfiles.count
    }
    
    init(interactor: GymProfilesInteractor, router: GymProfilesRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onAddGymProfilePressed() {

    }
    
    func onGymProfilePressed(gymProfile: GymProfileModel) {
        router.showGymProfileView(gymProfile: gymProfile)
    }
}
