//
//  RemoteTemplateService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

protocol RemoteWorkoutTemplateService {
    func createWorkoutTemplate(workout: WorkoutTemplateModel, image: PlatformImage?) async throws
    func getWorkoutTemplate(id: String) async throws -> WorkoutTemplateModel
    func getWorkoutTemplates(ids: [String], limitTo: Int) async throws -> [WorkoutTemplateModel]
    func getWorkoutTemplatesByName(name: String) async throws -> [WorkoutTemplateModel]
    func getWorkoutTemplatesForAuthor(authorId: String) async throws -> [WorkoutTemplateModel]
    func getTopWorkoutTemplatesByClicks(limitTo: Int) async throws -> [WorkoutTemplateModel]
    func incrementWorkoutTemplateInteraction(id: String) async throws
    func removeAuthorIdFromWorkoutTemplate(id: String) async throws
    func removeAuthorIdFromAllWorkoutTemplates(id: String) async throws
    func bookmarkWorkoutTemplate(id: String, isBookmarked: Bool) async throws
    func favouriteWorkoutTemplate(id: String, isFavourited: Bool) async throws
}
