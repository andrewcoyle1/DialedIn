//
//  WorkoutTemplateDetailInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol WorkoutTemplateDetailInteractor {
    var currentUser: UserModel? { get }
    var activeSession: WorkoutSessionModel? { get }
    func addLocalWorkoutSession(session: WorkoutSessionModel) throws
    func startActiveSession(_ session: WorkoutSessionModel)
    func deleteWorkoutTemplate(id: String) async throws
    func getPreference(templateId: String) -> ExerciseUnitPreference
}

extension CoreInteractor: WorkoutTemplateDetailInteractor { }
