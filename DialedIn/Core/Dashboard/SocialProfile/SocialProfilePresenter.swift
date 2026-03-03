import SwiftUI

@Observable
@MainActor
class SocialProfilePresenter {

    private let interactor: SocialProfileInteractor
    private let router: SocialProfileRouter

    private var profileUser: UserModel?
    var followers: [UserModel] = []

    var followersCount: Int { followers.count }

    var followingCount: Int {
        profileUser?.followingIds?.count ?? 0
    }

    var mutualFollowers: [UserModel] {
        guard let profileFollowingIds = profileUser?.followingIds else { return [] }
        return interactor.followingUsers.filter { profileFollowingIds.contains($0.userId) }
    }

    init(interactor: SocialProfileInteractor, router: SocialProfileRouter) {
        self.interactor = interactor
        self.router = router
    }

    func onViewAppear(delegate: SocialProfileDelegate) {
        profileUser = delegate.user
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
        loadFollowers(userId: delegate.user.userId)
    }

    private func loadFollowers(userId: String) {
        Task {
            do {
                followers = try await interactor.fetchFollowers(userId: userId)
            } catch {
                // Silent — followers stay empty in mock mode
            }
        }
    }

    func onFollowersPressed() {
        let delegate = FollowersListDelegate(followers: followers)
        router.showFollowersList(delegate: delegate)
    }

    func onViewDisappear(delegate: SocialProfileDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }

    func onChatPressed(user: UserModel) {

    }
}

extension SocialProfilePresenter {
    
    enum Event: LoggableEvent {
        case onAppear(delegate: SocialProfileDelegate)
        case onDisappear(delegate: SocialProfileDelegate)

        var eventName: String {
            switch self {
            case .onAppear:                 return "SocialProfileView_Appear"
            case .onDisappear:              return "SocialProfileView_Disappear"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .onAppear(delegate: let delegate), .onDisappear(delegate: let delegate):
                return delegate.eventParameters
//            default:
//                return nil
            }
        }
        
        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
    }

}
