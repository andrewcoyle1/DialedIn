//
//  WorkoutSessionManagerTests.swift
//  DialedInUnitTests
//
//  Created by Andrew Coyle on 20/09/2026.
//

import Testing
import Foundation
@testable import DialedIn

/// The logged workouts, and the one in progress.
///
/// The session being tracked is held in its own local document rather than in the synced
/// collection, so an unfinished workout survives the app being killed mid-set without ever
/// appearing in the history. Keeping those two apart is the behaviour worth pinning.
@MainActor
struct WorkoutSessionManagerTests {

    private let start = Date(timeIntervalSince1970: 1_000_000)

    private func session(
        id: String,
        templateId: String? = nil,
        programId: String? = nil,
        daysAgo: Int = 0,
        ended: Bool = true
    ) -> WorkoutSessionModel {
        let date = start.addingTimeInterval(Double(-daysAgo) * 86400)
        return WorkoutSessionModel(
            id: id,
            authorId: "author-1",
            name: "Push Day",
            workoutTemplateId: templateId,
            trainingProgramId: programId,
            dateCreated: date,
            endedAt: ended ? date.addingTimeInterval(3600) : nil,
            exercises: []
        )
    }

    private var history: [WorkoutSessionModel] {
        [
            session(id: "s1", templateId: "push", daysAgo: 10),
            session(id: "s2", templateId: "pull", daysAgo: 5),
            session(id: "s3", templateId: "push", daysAgo: 1)
        ]
    }

    // MARK: - History

    @Test("Test Sessions Are Empty Until Signed In")
    func testSessionsAreEmptyUntilSignedIn() {
        #expect(TestManagers.workoutSessionManager(sessions: history).workoutSessions.isEmpty)
    }

    @Test("Test Signing In Loads The History")
    func testSigningInLoadsTheHistory() async {
        let manager = await TestManagers.signedInWorkoutSessionManager(sessions: history)

        #expect(manager.workoutSessions.count == 3)
    }

    @Test("Test Reading Sessions By Id")
    func testReadingSessionsById() async {
        let manager = await TestManagers.signedInWorkoutSessionManager(sessions: history)

        #expect(manager.getWorkoutSessions(ids: ["s1", "s3"]).map(\.id).sorted() == ["s1", "s3"])
        #expect(manager.getWorkoutSessions(ids: ["nope"]).isEmpty)
        #expect(manager.getWorkoutSessions(ids: []).isEmpty)
    }

    @Test("Test Reading Sessions Honours A Limit")
    func testReadingSessionsHonoursALimit() async {
        let manager = await TestManagers.signedInWorkoutSessionManager(sessions: history)

        #expect(manager.getWorkoutSessions(ids: ["s1", "s2", "s3"], limitTo: 2).count == 2)
    }

    /// What "last time" means on an exercise screen: the most recent session of that workout, not
    /// merely the first one found.
    @Test("Test The Last Session For A Template Is The Most Recent")
    func testTheLastSessionForATemplateIsTheMostRecent() async throws {
        let manager = await TestManagers.signedInWorkoutSessionManager(sessions: history)

        let last = try await manager.getLastWorkoutSessionForTemplate(templateId: "push")

        #expect(last?.id == "s3")
    }

    @Test("Test A Template Never Trained Has No Last Session")
    func testATemplateNeverTrainedHasNoLastSession() async throws {
        let manager = await TestManagers.signedInWorkoutSessionManager(sessions: history)

        #expect(try await manager.getLastWorkoutSessionForTemplate(templateId: "legs") == nil)
    }

    /// The same lookup, narrowed to one program. Passing no program searches everything, which is
    /// what every caller did before `previousWorkoutReference` was honoured.
    @Test("Test The Last Session Can Be Narrowed To One Program")
    func testTheLastSessionCanBeNarrowedToOneProgram() async throws {
        let manager = await TestManagers.signedInWorkoutSessionManager(sessions: [
            session(id: "in-program", templateId: "push", programId: "program-1", daysAgo: 10),
            session(id: "freehand", templateId: "push", daysAgo: 1)
        ])

        let unrestricted = try await manager.getLastCompletedSessionForTemplate(
            templateId: "push",
            authorId: "author-1"
        )
        #expect(unrestricted?.id == "freehand")

        let narrowed = try await manager.getLastCompletedSessionForTemplate(
            templateId: "push",
            authorId: "author-1",
            inTrainingProgramId: "program-1"
        )
        #expect(narrowed?.id == "in-program")
    }

    /// A program with nothing logged in it yet has no previous session, rather than borrowing one
    /// from outside it.
    @Test("Test A Program With No History Has No Last Session")
    func testAProgramWithNoHistoryHasNoLastSession() async throws {
        let manager = await TestManagers.signedInWorkoutSessionManager(sessions: [
            session(id: "freehand", templateId: "push", daysAgo: 1)
        ])

        let narrowed = try await manager.getLastCompletedSessionForTemplate(
            templateId: "push",
            authorId: "author-1",
            inTrainingProgramId: "program-1"
        )

        #expect(narrowed == nil)
    }

    // MARK: - Writing

    @Test("Test Saving A Session Adds It To The History")
    func testSavingASessionAddsItToTheHistory() async throws {
        let manager = await TestManagers.signedInWorkoutSessionManager(sessions: [])

        try await manager.saveWorkoutSession(session(id: "new"))

        let added = await TestManagers.eventually { manager.workoutSessions.map(\.id) == ["new"] }
        #expect(added)
    }

    @Test("Test Deleting A Session Removes It")
    func testDeletingASessionRemovesIt() async throws {
        let manager = await TestManagers.signedInWorkoutSessionManager(sessions: history)

        try await manager.deleteWorkoutSession(id: "s2")

        let removed = await TestManagers.eventually { manager.workoutSessions.count == 2 }
        #expect(removed)
        #expect(!manager.workoutSessions.map(\.id).contains("s2"))
    }

    @Test("Test Deleting An Author's Sessions Empties Their History")
    func testDeletingAnAuthorsSessionsEmptiesTheirHistory() async throws {
        let manager = await TestManagers.signedInWorkoutSessionManager(sessions: history)

        try await manager.deleteAllWorkoutSessionsForAuthor(authorId: "author-1")

        let emptied = await TestManagers.eventually { manager.workoutSessions.isEmpty }
        #expect(emptied)
    }

    // MARK: - The session in progress

    /// A workout being tracked is not history yet, so it must not show up among the logged ones.
    @Test("Test There Is No Active Session To Begin With")
    func testThereIsNoActiveSessionToBeginWith() async {
        let manager = await TestManagers.signedInWorkoutSessionManager(sessions: history)

        #expect(manager.activeSession == nil)
        #expect(manager.workoutSessions.count == 3)
    }

    @Test("Test An Active Session Is Held Apart From The History")
    func testAnActiveSessionIsHeldApartFromTheHistory() async throws {
        let manager = await TestManagers.signedInWorkoutSessionManager(sessions: [])

        try manager.updateActiveSession(session(id: "live", ended: false))

        #expect(manager.activeSession?.id == "live")
        #expect(manager.workoutSessions.isEmpty)
    }

    @Test("Test Updating The Active Session Replaces It")
    func testUpdatingTheActiveSessionReplacesIt() async throws {
        let manager = await TestManagers.signedInWorkoutSessionManager(sessions: [])
        try manager.updateActiveSession(session(id: "live", ended: false))

        var updated = session(id: "live", ended: false)
        updated.updateDuration(1800)
        try manager.updateActiveSession(updated)

        #expect(manager.activeSession?.endedAt != nil)
    }

    @Test("Test Abandoning The Active Session Clears It")
    func testAbandoningTheActiveSessionClearsIt() async throws {
        let manager = await TestManagers.signedInWorkoutSessionManager(sessions: [])
        try manager.updateActiveSession(session(id: "live", ended: false))
        #expect(manager.activeSession != nil)

        try manager.deleteActiveSession()

        #expect(manager.activeSession == nil)
        #expect(manager.workoutSessions.isEmpty)
    }

    /// Finishing a workout moves it from the one-in-progress slot into the history.
    @Test("Test Ending A Session Moves It Into The History")
    func testEndingASessionMovesItIntoTheHistory() async throws {
        let manager = await TestManagers.signedInWorkoutSessionManager(sessions: [])
        try manager.updateActiveSession(session(id: "live", ended: false))

        try await manager.endWorkoutSession(session(id: "live"))

        let logged = await TestManagers.eventually { manager.workoutSessions.map(\.id) == ["live"] }
        #expect(logged)
        #expect(manager.activeSession == nil)
    }
}
