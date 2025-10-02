//
//  MockExerciseTemplateService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

struct MockWorkoutTemplateService: RemoteWorkoutTemplateService {
    let workouts: [WorkoutTemplateModel]
    let delay: Double
    let showError: Bool
    
    init(workouts: [WorkoutTemplateModel] = WorkoutTemplateModel.mocks, delay: Double = 0.0, showError: Bool = false) {
        self.workouts = workouts
        self.delay = delay
        self.showError = showError
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    func createWorkoutTemplate(workout: WorkoutTemplateModel, image: PlatformImage?) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    func getWorkoutTemplate(id: String) async throws -> WorkoutTemplateModel {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        
        guard let workout = workouts.first(where: { $0.id == id}) else {
            throw URLError(.unknown)
        }
        
        return workout
    }
    
    func getWorkoutTemplates(ids: [String], limitTo: Int = 20) async throws -> [WorkoutTemplateModel] {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        
        return workouts.shuffled()
    }
    
    func getWorkoutTemplatesByName(name: String) async throws -> [WorkoutTemplateModel] {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        
        return workouts.shuffled()
    }
    
    func getWorkoutTemplatesForAuthor(authorId: String) async throws -> [WorkoutTemplateModel] {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        
        return workouts.shuffled()
    }
    
    func getTopWorkoutTemplatesByClicks(limitTo: Int) async throws -> [WorkoutTemplateModel] {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        
        return workouts
            .sorted { ($0.clickCount ?? 0) > ($1.clickCount ?? 0) }
            .prefix(limitTo)
            .map { $0 }
    }
    
    func incrementWorkoutTemplateInteraction(id: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func removeAuthorIdFromWorkoutTemplate(id: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func removeAuthorIdFromAllWorkoutTemplates(id: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func bookmarkWorkoutTemplate(id: String, isBookmarked: Bool) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func favouriteWorkoutTemplate(id: String, isFavourited: Bool) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
}
