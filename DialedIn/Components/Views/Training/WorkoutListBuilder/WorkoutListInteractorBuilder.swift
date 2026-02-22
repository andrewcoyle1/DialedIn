//
//  WorkoutListInteractorBuilder.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol WorkoutListInteractorBuilder: GlobalInteractor {
    var currentUser: UserModel? { get }
    func incrementWorkoutTemplateInteraction(id: String) async throws
    func getWorkoutTemplatesByName(name: String) async throws -> [WorkoutTemplateModel]
    func getAllLocalWorkoutTemplates() throws -> [WorkoutTemplateModel]
    func getWorkoutTemplatesForAuthor(authorId: String) async throws -> [WorkoutTemplateModel]
    func getTopWorkoutTemplatesByClicks(limitTo: Int) async throws -> [WorkoutTemplateModel]
    func getWorkoutTemplates(ids: [String], limitTo: Int) async throws -> [WorkoutTemplateModel]
}

extension CoreInteractor: WorkoutListInteractorBuilder { }
