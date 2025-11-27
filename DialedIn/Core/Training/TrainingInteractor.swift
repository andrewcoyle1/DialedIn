//
//  TrainingInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol TrainingInteractor {
    var currentTrainingPlan: TrainingPlan? { get }
    func getTodaysWorkouts() -> [ScheduledWorkout]
    func getUpcomingWorkouts(limit: Int) -> [ScheduledWorkout]
    func getWorkoutTemplate(id: String) async throws -> WorkoutTemplateModel
}

extension CoreInteractor: TrainingInteractor { }
