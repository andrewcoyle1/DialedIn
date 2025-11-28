//
//  WorkoutStartInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol WorkoutStartInteractor {
    var currentUser: UserModel? { get }
    var currentTrainingPlan: TrainingPlan? { get }
    var activeSession: WorkoutSessionModel? { get }
    func addLocalWorkoutSession(session: WorkoutSessionModel) throws
    func startActiveSession(_ session: WorkoutSessionModel)
}

extension CoreInteractor: WorkoutStartInteractor { }
