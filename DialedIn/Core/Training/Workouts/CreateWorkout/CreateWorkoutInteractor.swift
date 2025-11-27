//
//  CreateWorkoutInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol CreateWorkoutInteractor {
    var currentUser: UserModel? { get }
    func updateWorkoutTemplate(workout: WorkoutTemplateModel, image: PlatformImage?) async throws
    func createWorkoutTemplate(workout: WorkoutTemplateModel, image: PlatformImage?) async throws
    func addCreatedWorkoutTemplate(workoutId: String) async throws
    func addBookmarkedWorkoutTemplate(workoutId: String) async throws
    func bookmarkWorkoutTemplate(id: String, isBookmarked: Bool) async throws
    func trackEvent(eventName: String, parameters: [String: Any]?, type: LogType)
    func generateImage(input: String) async throws -> UIImage
}

extension CoreInteractor: CreateWorkoutInteractor { }
