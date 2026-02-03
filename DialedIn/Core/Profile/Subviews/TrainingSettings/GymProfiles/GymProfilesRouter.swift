import SwiftUI

@MainActor
protocol GymProfilesRouter: GlobalRouter {
    func showGymProfileView(gymProfile: GymProfileModel)
}

extension CoreRouter: GymProfilesRouter { }
