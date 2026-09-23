//
//  PreviousWorkoutReferenceResolverTests.swift
//  DialedInUnitTests
//
//  The one switch that turns `previousWorkoutReference` into a list of past sessions. Both the
//  tracker's "Prev" column and smart progression go through it, so what it decides here is what
//  both of them show.
//

import Testing
import Foundation
@testable import DialedIn

@MainActor
struct PreviousWorkoutReferenceResolverTests {

    private let start = Date(timeIntervalSince1970: 1_000_000)

    /// Serves a fixed history through the two raw lookups, so the test exercises the shipped
    /// switch and fallback rather than a manager or a sync engine.
    private final class Resolver: PreviousWorkoutReferenceResolving {
        var previousWorkoutReferenceScope: PreviousWorkoutReferenceOption
        var sessions: [WorkoutSessionModel]
        private(set) var templateLookups: [(templateId: String, programId: String?)] = []
        private(set) var exerciseLookups: [String] = []

        init(scope: PreviousWorkoutReferenceOption, sessions: [WorkoutSessionModel]) {
            self.previousWorkoutReferenceScope = scope
            self.sessions = sessions
        }

        func completedSessionsForWorkoutTemplate(
            templateId: String,
            authorId: String,
            inTrainingProgramId: String?,
            limit: Int
        ) async -> [WorkoutSessionModel] {
            templateLookups.append((templateId: templateId, programId: inTrainingProgramId))
            return Array(
                sessions
                    .filter { $0.workoutTemplateId == templateId }
                    .filter { inTrainingProgramId == nil || $0.trainingProgramId == inTrainingProgramId }
                    .sorted { ($0.endedAt ?? .distantPast) > ($1.endedAt ?? .distantPast) }
                    .prefix(max(limit, 0))
            )
        }

        func completedSessionsContainingExercise(
            exerciseTemplateId: String,
            authorId: String,
            inTrainingProgramId: String?,
            limit: Int
        ) async -> [WorkoutSessionModel] {
            exerciseLookups.append(exerciseTemplateId)
            return Array(
                sessions
                    .filter { $0.exercises.contains(where: { $0.templateId == exerciseTemplateId }) }
                    .filter { inTrainingProgramId == nil || $0.trainingProgramId == inTrainingProgramId }
                    .sorted { ($0.endedAt ?? .distantPast) > ($1.endedAt ?? .distantPast) }
                    .prefix(max(limit, 0))
            )
        }
    }

    private func session(
        id: String,
        templateId: String?,
        programId: String? = nil,
        minutesAgo: Int,
        exerciseTemplateIds: [String]
    ) -> WorkoutSessionModel {
        let date = start.addingTimeInterval(Double(-minutesAgo) * 60)
        return WorkoutSessionModel(
            id: id,
            authorId: "author-1",
            name: id,
            workoutTemplateId: templateId,
            trainingProgramId: programId,
            dateCreated: date,
            endedAt: date.addingTimeInterval(60),
            exercises: exerciseTemplateIds.map { templateId in
                WorkoutExerciseModel(
                    id: "\(id)-\(templateId)",
                    authorId: "author-1",
                    templateId: templateId,
                    name: templateId,
                    trackingMode: .weightReps,
                    index: 1,
                    sets: []
                )
            }
        )
    }

    private func resolve(
        _ resolver: Resolver,
        exercise: String = "bench",
        workoutTemplateId: String? = "push",
        programId: String? = "program-1",
        limit: Int = 3
    ) async -> [String] {
        await resolver.previousSessions(
            forExerciseTemplateId: exercise,
            workoutTemplateId: workoutTemplateId,
            authorId: "author-1",
            trainingProgramId: programId,
            limit: limit
        ).map(\.id)
    }

    // MARK: - Same workout, the default

    /// The default scope, and what every existing user's stored `"anyWorkout"` means: this
    /// workout's own history wins even when the exercise was done more recently elsewhere.
    @Test("Test Same-Workout Scope Prefers This Templates Session")
    func testSameWorkoutScopePrefersThisTemplatesSession() async {
        let resolver = Resolver(scope: .sameWorkout, sessions: [
            session(id: "push-old", templateId: "push", minutesAgo: 100, exerciseTemplateIds: ["bench"]),
            session(id: "chest-recent", templateId: "chest", minutesAgo: 1, exerciseTemplateIds: ["bench"])
        ])

        #expect(await resolve(resolver) == ["push-old"])
        #expect(resolver.templateLookups.map(\.programId) == [nil])
        #expect(resolver.exerciseLookups.isEmpty)
    }

    /// The fallback. A template that has never held this exercise — a brand new workout built from
    /// exercises trained for months — must still show that history rather than a blank column.
    @Test("Test Same-Workout Scope Falls Back When The Template Has No History For The Exercise")
    func testSameWorkoutScopeFallsBackWhenTheTemplateHasNoHistoryForTheExercise() async {
        let resolver = Resolver(scope: .sameWorkout, sessions: [
            session(id: "push-old", templateId: "push", minutesAgo: 100, exerciseTemplateIds: ["row"]),
            session(id: "chest-recent", templateId: "chest", minutesAgo: 1, exerciseTemplateIds: ["bench"])
        ])

        #expect(await resolve(resolver) == ["chest-recent"])
        #expect(resolver.exerciseLookups == ["bench"])
    }

    /// A freehand workout has no template to look in, so it goes straight to the exercise's own
    /// history instead of showing nothing.
    @Test("Test A Workout Without A Template Falls Back To The Exercise Lookup")
    func testAWorkoutWithoutATemplateFallsBackToTheExerciseLookup() async {
        let resolver = Resolver(scope: .sameWorkout, sessions: [
            session(id: "chest-recent", templateId: "chest", minutesAgo: 1, exerciseTemplateIds: ["bench"])
        ])

        #expect(await resolve(resolver, workoutTemplateId: nil) == ["chest-recent"])
        #expect(resolver.templateLookups.isEmpty)
    }

    // MARK: - Within the current program

    @Test("Test Program Scope Restricts To This Workouts Program")
    func testProgramScopeRestrictsToThisWorkoutsProgram() async {
        let resolver = Resolver(scope: .workoutsInProgram, sessions: [
            session(id: "in-program", templateId: "push", programId: "program-1", minutesAgo: 100, exerciseTemplateIds: ["bench"]),
            session(id: "other-program", templateId: "push", programId: "program-2", minutesAgo: 1, exerciseTemplateIds: ["bench"])
        ])

        #expect(await resolve(resolver) == ["in-program"])
        #expect(resolver.templateLookups.map(\.programId) == ["program-1"])
    }

    /// Restricting to the program can leave nothing, and nothing is worse than a figure from
    /// outside it — so the fallback applies here too.
    @Test("Test Program Scope Falls Back When The Program Holds No History")
    func testProgramScopeFallsBackWhenTheProgramHoldsNoHistory() async {
        let resolver = Resolver(scope: .workoutsInProgram, sessions: [
            session(id: "other-program", templateId: "push", programId: "program-2", minutesAgo: 1, exerciseTemplateIds: ["bench"])
        ])

        #expect(await resolve(resolver) == ["other-program"])
        #expect(resolver.exerciseLookups == ["bench"])
    }

    /// A one-off workout is in no program, so there is no program for it to be "within".
    @Test("Test Program Scope Does Not Filter A Workout Outside Any Program")
    func testProgramScopeDoesNotFilterAWorkoutOutsideAnyProgram() async {
        let resolver = Resolver(scope: .workoutsInProgram, sessions: [
            session(id: "in-program", templateId: "push", programId: "program-9", minutesAgo: 1, exerciseTemplateIds: ["bench"])
        ])

        #expect(await resolve(resolver, programId: nil) == ["in-program"])
        #expect(resolver.templateLookups.map(\.programId) == [nil])
    }

    // MARK: - Any exercise

    /// The new scope. The template is never consulted at all, so the most recent performance of
    /// the exercise wins wherever it happened.
    @Test("Test Any-Exercise Scope Ignores The Template Entirely")
    func testAnyExerciseScopeIgnoresTheTemplateEntirely() async {
        let resolver = Resolver(scope: .anyExercise, sessions: [
            session(id: "push-old", templateId: "push", minutesAgo: 100, exerciseTemplateIds: ["bench"]),
            session(id: "chest-recent", templateId: "chest", minutesAgo: 1, exerciseTemplateIds: ["bench"])
        ])

        #expect(await resolve(resolver) == ["chest-recent", "push-old"])
        #expect(resolver.templateLookups.isEmpty)
    }

    @Test("Test An Exercise Never Performed Resolves To Nothing")
    func testAnExerciseNeverPerformedResolvesToNothing() async {
        let resolver = Resolver(scope: .sameWorkout, sessions: [
            session(id: "push-old", templateId: "push", minutesAgo: 100, exerciseTemplateIds: ["row"])
        ])

        #expect(await resolve(resolver, exercise: "deadlift").isEmpty)
    }
}
