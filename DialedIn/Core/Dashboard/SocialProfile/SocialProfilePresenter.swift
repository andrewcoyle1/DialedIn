import SwiftUI

@Observable
@MainActor
class SocialProfilePresenter {

    private let interactor: SocialProfileInteractor
    private let router: SocialProfileRouter
    let reportFlow: ReportFlow

    private var profileUser: UserModel?
    var followers: [UserModel] = []

    var followersCount: Int { followers.count }

    var followingCount: Int {
        profileUser?.followingIds?.count ?? 0
    }

    /// Whether the reader follows this profile, read live off the reader's own document so the
    /// button flips when the write lands rather than from a local copy.
    var isFollowing: Bool {
        guard let profileUser else { return false }
        return interactor.currentUser?.followingIds?.contains(profileUser.userId) ?? false
    }

    /// The reader's own profile has no follow button.
    var isOwnProfile: Bool {
        profileUser?.userId == interactor.currentUser?.userId
    }

    /// A private profile shows its lists only to people it follows back, and to its owner.
    var isLocked: Bool {
        guard let profileUser, profileUser.isPrivate == true, !isOwnProfile else { return false }
        guard let readerId = interactor.currentUser?.userId else { return true }
        return !(profileUser.followingIds ?? []).contains(readerId)
    }

    /// Whether the reader has blocked this profile, read live so the menu flips when the write lands.
    var isBlocked: Bool {
        guard let profileUser else { return false }
        return interactor.currentUser?.hasBlocked(profileUser.userId) ?? false
    }

    /// Nobody follows an account they have blocked, or themselves.
    var showsFollowButton: Bool {
        !isOwnProfile && !isBlocked
    }

    private var displayName: String {
        profileUser?.fullNameCalculated ?? "User"
    }

    var blockMenuTitle: String {
        isBlocked ? "Unblock" : "Block \(displayName)"
    }

    var mutualFollowers: [UserModel] {
        guard let profileFollowingIds = profileUser?.followingIds else { return [] }
        return interactor.followingUsers.filter { profileFollowingIds.contains($0.userId) }
    }

    init(interactor: SocialProfileInteractor, router: SocialProfileRouter) {
        self.interactor = interactor
        self.router = router
        self.reportFlow = ReportFlow(interactor: interactor, router: router)
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
        guard !isLocked else { return }
        let delegate = FollowersListDelegate(followers: followers)
        router.showFollowersList(delegate: delegate)
    }

    /// The "See all" beside the overlapping avatars was a plain `Text` — styled like a link, wired
    /// to nothing. It opens the same list screen the followers count does.
    func onMutualFollowersPressed() {
        let delegate = FollowersListDelegate(
            followers: mutualFollowers,
            title: "People You Both Follow"
        )
        router.showFollowersList(delegate: delegate)
    }

    func onFollowPressed() {
        guard let profileUser else { return }
        interactor.trackEvent(event: Event.followPressed)
        Task {
            do {
                try await interactor.followUser(userId: profileUser.userId)
            } catch {
                router.showSimpleAlert(title: "Unable to follow user", subtitle: "Please try again.")
            }
        }
    }

    func onUnfollowPressed() {
        guard let profileUser else { return }
        interactor.trackEvent(event: Event.unfollowPressed)
        Task {
            do {
                try await interactor.unfollowUser(userId: profileUser.userId)
            } catch {
                router.showSimpleAlert(title: "Unable to unfollow user", subtitle: "Please try again.")
            }
        }
    }

    func onBlockMenuPressed() {
        if isBlocked {
            onUnblockPressed()
        } else {
            onBlockPressed()
        }
    }

    /// Blocking is asked about first: it also unfollows, and hides the person everywhere.
    func onBlockPressed() {
        guard profileUser != nil, !isOwnProfile else { return }
        router.showAlert(
            title: "Block \(displayName)?",
            subtitle: "They will be hidden from your feed, comments, search and notifications, and you will stop following them.",
            buttons: {
                AnyView(
                    Group {
                        Button("Block", role: .destructive) {
                            self.onBlockConfirmed()
                        }
                        Button("Cancel", role: .cancel) { }
                    }
                )
            }
        )
    }

    func onBlockConfirmed() {
        guard let profileUser else { return }
        interactor.trackEvent(event: Event.blockConfirmed)
        Task {
            do {
                try await interactor.blockUser(userId: profileUser.userId)
            } catch {
                router.showSimpleAlert(title: "Unable to block user", subtitle: "Please try again.")
            }
        }
    }

    func onUnblockPressed() {
        guard let profileUser else { return }
        interactor.trackEvent(event: Event.unblockPressed)
        Task {
            do {
                try await interactor.unblockUser(userId: profileUser.userId)
            } catch {
                router.showSimpleAlert(title: "Unable to unblock user", subtitle: "Please try again.")
            }
        }
    }

    func onReportPressed() {
        guard let profileUser, !isOwnProfile else { return }
        reportFlow.start(ReportedContent(type: .user, id: profileUser.userId, authorUserId: profileUser.userId, noun: "profile"))
    }

    func onViewDisappear(delegate: SocialProfileDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }

}

extension SocialProfilePresenter {
    
    enum Event: LoggableEvent {
        case onAppear(delegate: SocialProfileDelegate)
        case onDisappear(delegate: SocialProfileDelegate)
        case followPressed
        case unfollowPressed
        case blockConfirmed
        case unblockPressed

        var eventName: String {
            switch self {
            case .onAppear:                 return "SocialProfileView_Appear"
            case .onDisappear:              return "SocialProfileView_Disappear"
            case .followPressed:            return "SocialProfileView_Follow_Pressed"
            case .unfollowPressed:          return "SocialProfileView_Unfollow_Pressed"
            case .blockConfirmed:           return "SocialProfileView_Block_Confirmed"
            case .unblockPressed:           return "SocialProfileView_Unblock_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .onAppear(delegate: let delegate), .onDisappear(delegate: let delegate):
                return delegate.eventParameters
            default:
                return nil
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
