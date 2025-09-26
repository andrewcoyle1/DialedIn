//
//  RemoteTemplateService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

protocol RemoteExerciseTemplateService {
    func createExerciseTemplate(exercise: ExerciseTemplateModel, image: PlatformImage?) async throws
    func getExerciseTemplate(id: String) async throws -> ExerciseTemplateModel
    func getExerciseTemplates(ids: [String], limitTo: Int) async throws -> [ExerciseTemplateModel]
    func getExerciseTemplatesByName(name: String) async throws -> [ExerciseTemplateModel]
    func getExerciseTemplatesForAuthor(authorId: String) async throws -> [ExerciseTemplateModel]
    func getTopExerciseTemplatesByClicks(limitTo: Int) async throws -> [ExerciseTemplateModel]
    func incrementExerciseTemplateInteraction(id: String) async throws
    func removeAuthorIdFromExerciseTemplate(id: String) async throws
    func removeAuthorIdFromAllExerciseTemplates(id: String) async throws
    func bookmarkExerciseTemplate(id: String, isBookmarked: Bool) async throws
    func favouriteExerciseTemplate(id: String, isFavourited: Bool) async throws
}
