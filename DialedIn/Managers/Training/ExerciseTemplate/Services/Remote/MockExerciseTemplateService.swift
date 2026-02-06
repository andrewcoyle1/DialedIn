//
//  MockExerciseTemplateService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

struct MockExerciseTemplateService: RemoteExerciseTemplateService {
    let exercises: [ExerciseModel]
    let delay: Double
    let showError: Bool
    
    init(exercises: [ExerciseModel] = ExerciseModel.mocks, delay: Double = 0.0, showError: Bool = false) {
        self.exercises = exercises
        self.delay = delay
        self.showError = showError
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    func createExerciseTemplate(exercise: ExerciseModel, image: PlatformImage?) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    func getExerciseTemplate(id: String) async throws -> ExerciseModel {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        
        guard let exercise = exercises.first(where: { $0.id == id}) else {
            throw URLError(.unknown)
        }
        
        return exercise
    }
    
    func getExerciseTemplates(ids: [String], limitTo: Int = 20) async throws -> [ExerciseModel] {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        
        return exercises
            .filter { ids.contains($0.id) }
            .prefix(limitTo)
            .map { $0 }
    }
    
    func getExerciseTemplatesByName(name: String) async throws -> [ExerciseModel] {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        
        return exercises.filter { $0.name.localizedCaseInsensitiveContains(name) }
    }
    
    func getExerciseTemplatesForAuthor(authorId: String) async throws -> [ExerciseModel] {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        
        return exercises.filter { $0.authorId == authorId }
    }
    
    func getTopExerciseTemplatesByClicks(limitTo: Int) async throws -> [ExerciseModel] {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        
        return exercises
            .sorted { ($0.clickCount ?? 0) > ($1.clickCount ?? 0) }
            .prefix(limitTo)
            .map { $0 }
    }
    
    func incrementExerciseTemplateInteraction(id: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func removeAuthorIdFromExerciseTemplate(id: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func removeAuthorIdFromAllExerciseTemplates(id: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func bookmarkExerciseTemplate(id: String, isBookmarked: Bool) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func favouriteExerciseTemplate(id: String, isFavourited: Bool) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
}
