//
//  RemoteTemplateService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

protocol RemoteExerciseTemplateService {
    func createExerciseTemplate(exercise: ExerciseModel, image: PlatformImage?) async throws
    func getExerciseTemplate(id: String) async throws -> ExerciseModel
    func getExerciseTemplates(ids: [String], limitTo: Int) async throws -> [ExerciseModel]
    func getExerciseTemplatesByName(name: String) async throws -> [ExerciseModel]
    func getExerciseTemplatesForAuthor(authorId: String) async throws -> [ExerciseModel]
    func getTopExerciseTemplatesByClicks(limitTo: Int) async throws -> [ExerciseModel]
    func incrementExerciseTemplateInteraction(id: String) async throws
    func removeAuthorIdFromExerciseTemplate(id: String) async throws
    func removeAuthorIdFromAllExerciseTemplates(id: String) async throws
    func bookmarkExerciseTemplate(id: String, isBookmarked: Bool) async throws
    func favouriteExerciseTemplate(id: String, isFavourited: Bool) async throws
}
