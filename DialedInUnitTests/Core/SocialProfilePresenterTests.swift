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
        private(set) var fetchedFollowerIds: [String] = []

        func fetchFollowers(userId: String) async throws -> [UserModel] {
            fetchedFollowerIds.append(userId)
            if let fetchError { throw fetchError }
            return followers
        }
    }

    private final class Router: SocialProfileRouter {
        let router: AnyRouter = TestRouting.anyRouter
        private(set) var followersDelegates: [FollowersListDelegate] = []

        func showFollowersList(delegate: FollowersListDelegate) {
            followersDelegates.append(delegate)
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

    @Test("Test Leaving The Profile Is Tracked")
    func testLeavingTheProfileIsTracked() {
        let screen = makeScreen()

        screen.presenter.onViewDisappear(delegate: profile("friend", following: []))

        #expect(screen.interactor.trackedEventNames == ["SocialProfileView_Disappear"])
    }
}

// MARK: - Followers list

/// The list itself holds no state: the people and the title travel in the delegate, so the same
/// screen serves "Followers" and "People you both follow" without a second module.
@MainActor
struct SocialFollowersListTests {

    private final class Interactor: SpyGlobalInteractor, FollowersListInteractor { }

    private final class Router: FollowersListRouter {
        let router: AnyRouter = TestRouting.anyRouter
    }

    @Test("Test The Followers List Defaults To The Followers Title")
    func testTheFollowersListDefaultsToTheFollowersTitle() {
        let delegate = FollowersListDelegate(followers: [DashboardFixture.user("a")])

        #expect(delegate.title == "Followers")
        #expect(delegate.followers.map(\.userId) == ["a"])
    }

    /// An empty list is a state the screen draws, not an error — the presenter needs nothing for it.
    @Test("Test The Followers List Presenter Holds No State Of Its Own")
    func testTheFollowersListPresenterHoldsNoStateOfItsOwn() {
        let interactor = Interactor()
        _ = FollowersListPresenter(interactor: interactor, router: Router())

        #expect(interactor.trackedEventNames.isEmpty)
        #expect(FollowersListDelegate(followers: [], title: "People You Both Follow").followers.isEmpty)
    }
}
