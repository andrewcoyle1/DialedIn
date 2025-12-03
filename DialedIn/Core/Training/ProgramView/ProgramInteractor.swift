//
//  ProgramInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol ProgramInteractor {
    var currentTrainingPlan: TrainingPlan? { get }
    func getAdherenceRate() -> Double
    func getCurrentWeek() -> TrainingWeek?
    func getUpcomingWorkouts(limit: Int) -> [ScheduledWorkout]
    func getTodaysWorkouts() -> [ScheduledWorkout]
    func trackEvent(event: LoggableEvent)
    func getWeeklyProgress(for weekNumber: Int) -> WeekProgress
    func getWorkoutTemplate(id: String) async throws -> WorkoutTemplateModel
    func getLocalWorkoutSession(id: String) throws -> WorkoutSessionModel
    func getAuthId() throws -> String
    func syncFromRemote() async throws
}

extension CoreInteractor: ProgramInteractor { }
