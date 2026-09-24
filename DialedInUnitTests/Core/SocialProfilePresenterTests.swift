//
//  SocialProfilePresenterTests.swift
//  DialedInUnitTests
//
//  Created by Andrew Coyle on 21/09/2026.
//

import Testing
import Foundation
import SwiftUI
@testable import DialedIn

// MARK: - Social profile

/// Someone else's profile, reached from a feed row.
///
/// The counts here describe that person, not the reader, and "people you both follow" is an
/// intersection — getting it wrong tells the reader they follow someone they do not.
@MainActor
struct SocialProfilePresenterTests {

    private final class Interactor: SpyGlobalInteractor, SocialProfileInteractor {
        var currentUser: UserModel? = DashboardFixture.user("me")
        var followingUsers: [UserModel] = []
        var followers: [UserModel] = []
        var fetchError: Error?
        var followError: Error?
        private(set) var fetchedFollowerIds: [String] = []

        func fetchFollowers(userId: String) async throws -> [UserModel] {
            fetchedFollowerIds.append(userId)
            if let fetchError { throw fetchError }
            return followers
        }

        func followUser(userId: String) async throws {
            if let followError { throw followError }
            currentUser = UserModel(userId: "me", followingIds: (currentUser?.followingIds ?? []) + [userId])
        }

        func unfollowUser(userId: String) async throws {
            if let followError { throw followError }
            currentUser = UserModel(userId: "me", followingIds: (currentUser?.followingIds ?? []).filter { $0 != userId })
        }
    }

    private final class Router: SocialProfileRouter {
        let router: AnyRouter = TestRouting.anyRouter
        private(set) var followersDelegates: [FollowersListDelegate] = []
        private(set) var alertTitles: [String] = []

        func showFollowersList(delegate: FollowersListDelegate) {
            followersDelegates.append(delegate)
        }

        func showAlert(title: String, subtitle: String?, buttons: (@Sendable () -> AnyView)?) {
            alertTitles.append(title)
        }
    }

    private struct Screen {
        let presenter: SocialProfilePresenter
        let interactor: Interactor
        let router: Router
    }

    private func makeScreen() -> Screen {
        let interactor = Interactor()
        let router = Router()
        return Screen(
            presenter: SocialProfilePresenter(interactor: interactor, router: router),
            interactor: interactor,
            router: router
        )
    }

    private func profile(_ id: String, following: [String]?) -> SocialProfileDelegate {
        SocialProfileDelegate(user: UserModel(userId: id, followingIds: following))
    }

    /// The followers shown are the profile's own, fetched for that user id — never the reader's.
    @Test("Test Appearing Loads The Profiles Followers")
    func testAppearingLoadsTheProfilesFollowers() async {
        let screen = makeScreen()
        screen.interactor.followers = [DashboardFixture.user("a"), DashboardFixture.user("b")]

        screen.presenter.onViewAppear(delegate: profile("friend", following: []))
        await TestManagers.eventually { !screen.presenter.followers.isEmpty }

        #expect(screen.interactor.fetchedFollowerIds == ["friend"])
        #expect(screen.presenter.followersCount == 2)
        #expect(screen.interactor.trackedScreenEventNames == ["SocialProfileView_Appear"])
    }

    /// A profile nobody follows, or one whose followers cannot be fetched, reads as zero rather than
    /// carrying over whatever was on screen before.
    @Test("Test A Failed Follower Fetch Leaves The Count At Zero")
    func testAFailedFollowerFetchLeavesTheCountAtZero() async {
        let screen = makeScreen()
        screen.interactor.fetchError = DashboardTestError.failed

        screen.presenter.onViewAppear(delegate: profile("friend", following: ["a"]))
        await TestManagers.eventually { !screen.interactor.fetchedFollowerIds.isEmpty }

        #expect(screen.presenter.followersCount == 0)
    }

    /// Following count is the profile's own list, and a profile that follows nobody has none rather
    /// than an unknown.
    @Test("Test The Following Count Is The Profiles Own")
    func testTheFollowingCountIsTheProfilesOwn() {
        let screen = makeScreen()

        screen.presenter.onViewAppear(delegate: profile("friend", following: ["a", "b", "c"]))
        #expect(screen.presenter.followingCount == 3)

        screen.presenter.onViewAppear(delegate: profile("friend", following: nil))
        #expect(screen.presenter.followingCount == 0)
    }

    /// "People you both follow" is the overlap of the reader's following list and the profile's, so
    /// someone only one of them follows must not appear.
    @Test("Test Mutual Followers Are The Overlap Of Both Lists")
    func testMutualFollowersAreTheOverlapOfBothLists() {
        let screen = makeScreen()
        screen.interactor.followingUsers = [
            DashboardFixture.user("shared"),
            DashboardFixture.user("mine-only")
        ]

        screen.presenter.onViewAppear(delegate: profile("friend", following: ["shared", "theirs-only"]))

        #expect(screen.presenter.mutualFollowers.map(\.userId) == ["shared"])
    }

    /// Before the profile is known there is nothing to intersect with, so the strip of shared faces
    /// stays empty rather than showing the reader their own following list.
    @Test("Test There Are No Mutual Followers Before The Profile Loads")
    func testThereAreNoMutualFollowersBeforeTheProfileLoads() {
        let screen = makeScreen()
        screen.interactor.followingUsers = [DashboardFixture.user("shared")]

        #expect(screen.presenter.mutualFollowers.isEmpty)
    }

    /// Two doors into the same list screen, each carrying its own people and its own title — the
    /// mutual list is not the followers list.
    @Test("Test The Two Follower Lists Open With Their Own People And Titles")
    func testTheTwoFollowerListsOpenWithTheirOwnPeopleAndTitles() async {
        let screen = makeScreen()
        screen.interactor.followers = [DashboardFixture.user("a")]
        screen.interactor.followingUsers = [DashboardFixture.user("shared")]
        screen.presenter.onViewAppear(delegate: profile("friend", following: ["shared"]))
        await TestManagers.eventually { !screen.presenter.followers.isEmpty }

        screen.presenter.onFollowersPressed()
        screen.presenter.onMutualFollowersPressed()

        #expect(screen.router.followersDelegates.map(\.title) == ["Followers", "People You Both Follow"])
        #expect(screen.router.followersDelegates.first?.followers.map(\.userId) == ["a"])
        #expect(screen.router.followersDelegates.last?.followers.map(\.userId) == ["shared"])
    }

    /// The button reads the reader's own following list, so following flips it and unfollowing
    /// flips it back — and the reader's own profile never shows one.
    @Test("Test Following A Profile Flips The Button And Is Tracked")
    func testFollowingAProfileFlipsTheButtonAndIsTracked() async {
        let screen = makeScreen()
        screen.presenter.onViewAppear(delegate: profile("friend", following: []))
        #expect(!screen.presenter.isFollowing)
        #expect(!screen.presenter.isOwnProfile)

        screen.presenter.onFollowPressed()
        await TestManagers.eventually { screen.presenter.isFollowing }

        screen.presenter.onUnfollowPressed()
        await TestManagers.eventually { !screen.presenter.isFollowing }

        #expect(screen.interactor.trackedEventNames == [
            "SocialProfileView_Follow_Pressed", "SocialProfileView_Unfollow_Pressed"
        ])
        #expect(screen.router.alertTitles.isEmpty)
    }

    @Test("Test The Readers Own Profile Has No Follow Button")
    func testTheReadersOwnProfileHasNoFollowButton() {
        let screen = makeScreen()
        screen.presenter.onViewAppear(delegate: profile("me", following: []))

        #expect(screen.presenter.isOwnProfile)
    }

    /// A failed follow leaves the button where it was and says so, rather than silently pretending.
    @Test("Test A Failed Follow Shows An Alert And Leaves The Button")
    func testAFailedFollowShowsAnAlertAndLeavesTheButton() async {
        let screen = makeScreen()
        screen.interactor.followError = DashboardTestError.failed
        screen.presenter.onViewAppear(delegate: profile("friend", following: []))

        screen.presenter.onFollowPressed()
        await TestManagers.eventually { !screen.router.alertTitles.isEmpty }

        #expect(screen.router.alertTitles == ["Unable to follow user"])
        #expect(!screen.presenter.isFollowing)
    }

    @Test("Test Leaving The Profile Is Tracked")
    func testLeavingTheProfileIsTracked() {
        let screen = makeScreen()

        screen.presenter.onViewDisappear(delegate: profile("friend", following: []))

        #expect(screen.interactor.trackedEventNames == ["SocialProfileView_Disappear"])
    }
}

// MARK: - Followers list

/// The people and the title travel in the delegate; the presenter only answers who the reader
/// already follows and forwards the button presses.
@MainActor
struct SocialFollowersListTests {

    private final class Interactor: SpyGlobalInteractor, FollowersListInteractor {
        var currentUser: UserModel? = UserModel(userId: "me", followingIds: ["a"])
        var followError: Error?
        private(set) var followed: [String] = []
        private(set) var unfollowed: [String] = []

        func followUser(userId: String) async throws {
            if let followError { throw followError }
            followed.append(userId)
        }
        func unfollowUser(userId: String) async throws {
            if let followError { throw followError }
            unfollowed.append(userId)
        }
    }

    private final class Router: FollowersListRouter {
        let router: AnyRouter = TestRouting.anyRouter
        private(set) var alertTitles: [String] = []
        private(set) var profileUserIds: [String] = []

        func showAlert(title: String, subtitle: String?, buttons: (@Sendable () -> AnyView)?) {
            alertTitles.append(title)
        }
        func showSocialProfileView(delegate: SocialProfileDelegate) {
            profileUserIds.append(delegate.user.userId)
        }
    }

    @Test("Test The Followers List Defaults To The Followers Title")
    func testTheFollowersListDefaultsToTheFollowersTitle() {
        let delegate = FollowersListDelegate(followers: [DashboardFixture.user("a")])

        #expect(delegate.title == "Followers")
        #expect(delegate.followers.map(\.userId) == ["a"])
    }

    /// Each row's button reads the reader's list, and the reader's own row has none.
    @Test("Test Rows Know Who The Reader Follows And Skip The Reader")
    func testRowsKnowWhoTheReaderFollowsAndSkipTheReader() {
        let presenter = FollowersListPresenter(interactor: Interactor(), router: Router())

        #expect(presenter.isFollowing(userId: "a"))
        #expect(!presenter.isFollowing(userId: "b"))
        #expect(presenter.showsFollowButton(for: DashboardFixture.user("b")))
        #expect(!presenter.showsFollowButton(for: DashboardFixture.user("me")))
    }

    @Test("Test Follow And Unfollow Reach The Interactor And A Row Opens The Profile")
    func testFollowAndUnfollowReachTheInteractorAndARowOpensTheProfile() async {
        let interactor = Interactor()
        let router = Router()
        let presenter = FollowersListPresenter(interactor: interactor, router: router)

        presenter.onFollowPressed(user: DashboardFixture.user("b"))
        presenter.onUnfollowPressed(user: DashboardFixture.user("a"))
        presenter.onUserPressed(user: DashboardFixture.user("b"))
        await TestManagers.eventually { !interactor.unfollowed.isEmpty }

        #expect(interactor.followed == ["b"])
        #expect(interactor.unfollowed == ["a"])
        #expect(router.profileUserIds == ["b"])
    }

    @Test("Test A Failed Follow From The List Shows An Alert")
    func testAFailedFollowFromTheListShowsAnAlert() async {
        let interactor = Interactor()
        interactor.followError = DashboardTestError.failed
        let router = Router()
        let presenter = FollowersListPresenter(interactor: interactor, router: router)

        presenter.onFollowPressed(user: DashboardFixture.user("b"))
        await TestManagers.eventually { !router.alertTitles.isEmpty }

        #expect(router.alertTitles == ["Unable to follow user"])
    }
}
