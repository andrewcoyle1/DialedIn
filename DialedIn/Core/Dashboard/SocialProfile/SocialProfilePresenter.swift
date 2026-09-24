import SwiftUI

@Observable
@MainActor
class SocialProfilePresenter {

    private let interactor: SocialProfileInteractor
    private let router: SocialProfileRouter
    let reportFlow: ReportFlow

    private var profileUser: UserModel?
    var followers: [UserModel] = []
    private var fetchedSessions: [WorkoutSessionModel] = []

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

    /// Finished, non-rest sessions, newest first. The reader's own come from the local collection
    /// rather than a fetch; a locked profile shows none.
    var sessions: [WorkoutSessionModel] {
        guard !isLocked else { return [] }
        return (isOwnProfile ? interactor.workoutSessions : fetchedSessions)
            .filter { $0.endedAt != nil && !$0.isRestDay }
            .sorted { $0.dateCreated > $1.dateCreated }
    }

    /// The streak stamped on the author's most recent session that carries one, from two days on.
    /// The reader cannot see anyone else's streak directly, so this is as fresh as their last
    /// finished workout.
    var latestStreak: Int? {
        guard let count = sessions.first(where: { $0.streakCount != nil })?.streakCount, count > 1 else { return nil }
        return count
    }

    /// One entry per calendar day with a finished session, for the consistency grid.
    var trainingDays: Set<Date> {
        Set(sessions.map { Calendar.current.startOfDay(for: $0.dateCreated) })
    }

    /// The grid's data: a point per training day in the last twelve weeks.
    var consistencySeries: TimeSeries {
        let cutoff = Calendar.current.date(byAdding: .weekOfYear, value: -12, to: .now) ?? .distantPast
        let days = trainingDays.filter { $0 >= cutoff }.sorted()
        return TimeSeries(
            name: "Training Days",
            data: days.map { TimeSeriesDatapoint(id: $0.ISO8601Format(), date: $0, value: 1) }
        )
    }

    /// Only the reader's own program resolves without fetching someone else's programs, which
    /// live under their own user document.
    var programName: String? {
        isOwnProfile ? interactor.activeTrainingProgram?.name : nil
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
        if !isLocked, !isOwnProfile {
            loadSessions(userId: delegate.user.userId)
        }
    }

    private func loadSessions(userId: String) {
        Task {
            do {
                fetchedSessions = try await interactor.fetchWorkoutSessions(authorId: userId, limit: 30)
            } catch {
                // Silent — the empty state stands in for sessions that could not be read.
            }
        }
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
