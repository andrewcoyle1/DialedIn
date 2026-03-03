import SwiftUI

@MainActor
protocol SocialProfileRouter: GlobalRouter {
    func showFollowersList(delegate: FollowersListDelegate)
}

extension CoreRouter: SocialProfileRouter { }
