//
//  TrainingProgramManagerTests.swift
//  DialedInUnitTests
//
//  Created by Andrew Coyle on 22/09/2026.
//

import Testing
import Foundation
@testable import DialedIn

/// A user's training programs, each a microcycle of workout templates in day order.
///
/// The manager is a thin skin over one sync engine, so the behaviour worth pinning is what it
/// reports when a write fails — those events are the only trace a lost program leaves — and what
/// a program is allowed to contain, because a day with no exercises is how a rest day is spelled
/// and several screens count days rather than sessions.
@MainActor
struct TrainingProgramManagerTests {

    /// Records what the manager hands the log manager. `LogService` is `Sendable`, so the store
    /// has to be one too.
    private final class SpyLogService: LogService, @unchecked Sendable {
        private let lock = NSLock()
        private var names: [String] = []

        var trackedEventNames: [String] {
            lock.withLock { names }
        }

        func identifyUser(userId: String, name: String?, email: String?) { }
        func addUserProperties(dict: [String: Any], isHighPriority: Bool) { }
        func deleteUserProfile() { }
        func trackEvent(event: LoggableEvent) { lock.withLock { names.append(event.eventName) } }
        func trackScreenView(event: LoggableEvent) { lock.withLock { names.append(event.eventName) } }
    }

    private func program(
        id: String,
        name: String = "Block 1",
        templates: [WorkoutTemplateModel]
    ) -> TrainingProgram {
        TrainingProgram(
            id: id,
            authorId: "author-1",
            name: name,
            icon: "dumbbell",
            colour: "#FF0000",
            workoutTemplates: templates
        )
    }

    /// A training day. With no exercises it is a rest day — that absence is the only thing that
    /// marks one.
    private func workout(id: String, name: String, isRest: Bool = false) -> WorkoutTemplateModel {
        WorkoutTemplateModel(
            id: id,
            authorId: "author-1",
            name: name,
            exercises: isRest ? [] : [WorkoutTemplateExercise(exercise: .mock, setRestTimers: false)]
        )
    }

    /// The shorthand for "a program with one training day in it", where the days are not what a
    /// test is about.
    private func program(id: String, name: String = "Block 1") -> TrainingProgram {
        program(id: id, name: name, templates: [workout(id: "w1", name: "Push")])
    }

    // MARK: - Loading

    @Test("Test Programs Are Empty Until Signed In")
    func testProgramsAreEmptyUntilSignedIn() {
        #expect(TestManagers.trainingProgramManager(programs: [program(id: "p1")]).trainingPrograms.isEmpty)
    }

    @Test("Test Signing In Loads The User's Programs")
    func testSigningInLoadsTheUsersPrograms() async {
        let manager = await TestManagers.signedInTrainingProgramManager(
            programs: [program(id: "p1"), program(id: "p2", name: "Block 2")]
        )

        #expect(manager.trainingPrograms.map(\.id).sorted() == ["p1", "p2"])
    }

    /// An account that has programs and loads none is indistinguishable, in the data, from one
    /// that has none — so the empty load is reported at `.severe` rather than left silent.
    @Test("Test Signing In With No Programs Is Reported")
    func testSigningInWithNoProgramsIsReported() async {
        let spy = SpyLogService()

        _ = await TestManagers.signedInTrainingProgramManager(logManager: LogManager(services: [spy]))

        #expect(spy.trackedEventNames.contains("training_program_bulkLoad_empty"))
        #expect(!spy.trackedEventNames.contains("training_program_bulkLoad_success"))
    }

    @Test("Test Signing In With Programs Reports A Successful Load")
    func testSigningInWithProgramsReportsASuccessfulLoad() async {
        let spy = SpyLogService()

        _ = await TestManagers.signedInTrainingProgramManager(
            programs: [program(id: "p1")],
            logManager: LogManager(services: [spy])
        )

        #expect(spy.trackedEventNames.contains("training_program_bulkLoad_success"))
        #expect(!spy.trackedEventNames.contains("training_program_bulkLoad_empty"))
    }

    // MARK: - Writing

    @Test("Test Saving A Program Adds It")
    func testSavingAProgramAddsIt() async throws {
        let manager = await TestManagers.signedInTrainingProgramManager()

        try await manager.saveTrainingProgram(trainingProgram: program(id: "p1"))

        let added = await TestManagers.eventually { manager.trainingPrograms.map(\.id) == ["p1"] }
        #expect(added)
    }

    @Test("Test Saving An Existing Program Replaces It Rather Than Duplicating It")
    func testSavingAnExistingProgramReplacesIt() async throws {
        let manager = await TestManagers.signedInTrainingProgramManager(programs: [program(id: "p1")])

        try await manager.saveTrainingProgram(trainingProgram: program(id: "p1", name: "Hypertrophy Block"))

        let renamed = await TestManagers.eventually {
            manager.trainingPrograms.count == 1 && manager.trainingPrograms.first?.name == "Hypertrophy Block"
        }
        #expect(renamed)
    }

    @Test("Test Saving A Program Keeps Its Day Order")
    func testSavingAProgramKeepsItsDayOrder() async throws {
        let days = [
            workout(id: "d1", name: "Push"),
            workout(id: "d2", name: "Rest", isRest: true),
            workout(id: "d3", name: "Pull")
        ]
        let manager = await TestManagers.signedInTrainingProgramManager()

        try await manager.saveTrainingProgram(trainingProgram: program(id: "p1", templates: days))

        let saved = await TestManagers.eventually { manager.trainingPrograms.first != nil }
        #expect(saved)
        // Day order is positional — the microcycle is the array, so a reordering here moves a
        // user's training days.
        #expect(manager.trainingPrograms.first?.workoutTemplates.map(\.name) == ["Push", "Rest", "Pull"])
    }

    // MARK: - Deleting

    @Test("Test Deleting A Program Removes It And Leaves The Others")
    func testDeletingAProgramRemovesIt() async throws {
        let manager = await TestManagers.signedInTrainingProgramManager(
            programs: [program(id: "p1"), program(id: "p2", name: "Block 2")]
        )

        try await manager.deleteTrainingProgram(programId: "p1")

        let removed = await TestManagers.eventually { manager.trainingPrograms.map(\.id) == ["p2"] }
        #expect(removed)
    }

    /// Deleting a program the user no longer has has to surface rather than report success — a
    /// screen that believes a delete happened stops showing the program it could not remove.
    @Test("Test Deleting A Program That Is Not There Fails Loudly")
    func testDeletingAProgramThatIsNotThereFailsLoudly() async throws {
        let spy = SpyLogService()
        let manager = await TestManagers.signedInTrainingProgramManager(
            programs: [program(id: "p1")],
            logManager: LogManager(services: [spy])
        )

        await #expect(throws: (any Error).self) {
            try await manager.deleteTrainingProgram(programId: "nope")
        }
        #expect(spy.trackedEventNames.contains("training_program_delete_fail"))
        #expect(manager.trainingPrograms.map(\.id) == ["p1"])
    }

    // MARK: - Rest days

    /// A rest day is a workout template with no exercises — there is no flag for it. A program
    /// built without any days gets exactly one, so a new program is a rest day rather than an
    /// empty microcycle.
    @Test("Test A Program With No Days Is Given A Single Rest Day")
    func testAProgramWithNoDaysIsGivenASingleRestDay() async throws {
        let manager = await TestManagers.signedInTrainingProgramManager()

        try await manager.saveTrainingProgram(trainingProgram: program(id: "p1", templates: []))

        let saved = await TestManagers.eventually { manager.trainingPrograms.first != nil }
        #expect(saved)
        let days = try #require(manager.trainingPrograms.first?.workoutTemplates)
        #expect(days.count == 1)
        #expect(days[0].name == "Rest")
        #expect(days[0].exercises.isEmpty)
    }

    /// The rest day is a default of the initialiser, not something the manager enforces: a
    /// program that arrives from Firestore with no days decodes with no days, because decoding
    /// assigns the stored array straight to the property. Nothing downstream may assume a
    /// program always has at least one day.
    @Test("Test A Stored Program With No Days Decodes With No Days")
    func testAStoredProgramWithNoDaysDecodesWithNoDays() throws {
        var stored = program(id: "p1")
        stored.workoutTemplates = []
        let data = try JSONEncoder().encode(stored)

        let decoded = try JSONDecoder().decode(TrainingProgram.self, from: data)

        #expect(decoded.workoutTemplates.isEmpty)
    }

    /// And a rest day the user placed survives the round trip as a rest day — it is only ever
    /// the absence of exercises that says so, so anything that counts "workouts in the program"
    /// has to exclude it itself.
    @Test("Test A Rest Day Placed By The User Stays An Empty Day")
    func testARestDayPlacedByTheUserStaysAnEmptyDay() async throws {
        let days = [workout(id: "d1", name: "Push"), workout(id: "d2", name: "Rest", isRest: true)]
        let manager = await TestManagers.signedInTrainingProgramManager()

        try await manager.saveTrainingProgram(trainingProgram: program(id: "p1", templates: days))

        let saved = await TestManagers.eventually { manager.trainingPrograms.first?.workoutTemplates.count == 2 }
        #expect(saved)
        let restDays = manager.trainingPrograms.first?.workoutTemplates.filter { $0.exercises.isEmpty }
        #expect(restDays?.map(\.name) == ["Rest"])
    }

    // MARK: - Signing out

    @Test("Test Signing Out Drops The Programs")
    func testSigningOutDropsThePrograms() async {
        let manager = await TestManagers.signedInTrainingProgramManager(programs: [program(id: "p1")])
        #expect(manager.trainingPrograms.count == 1)

        manager.signOut()

        #expect(manager.trainingPrograms.isEmpty)
    }
}
