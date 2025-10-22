//
//  AddExerciseModalViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

@Observable
@MainActor
class AddExerciseModalViewModel {
    private let exerciseTemplateManager: ExerciseTemplateManager
    private let logManager: LogManager
    
    private(set) var exercises: [ExerciseTemplateModel] = []
    var searchText: String = ""
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?
    var selectedExercises: Binding<[ExerciseTemplateModel]>
    
    var filteredExercises: [ExerciseTemplateModel] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return exercises }
        return exercises.filter { exercise in
            var fields: [String] = [
                exercise.name,
                exercise.type.description
            ]
            if let description = exercise.description { fields.append(description) }
            fields.append(contentsOf: exercise.muscleGroups.map { $0.description })
            return fields.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }
    
    init(
        container: DependencyContainer,
        selectedExercises: Binding<[ExerciseTemplateModel]>
    ) {
        self.exerciseTemplateManager = container.resolve(ExerciseTemplateManager.self)!
        self.logManager = container.resolve(LogManager.self)!
        self.selectedExercises = selectedExercises
    }
    
    func onExercisePressed(exercise: ExerciseTemplateModel) {
        if let index = selectedExercises.wrappedValue.firstIndex(where: { $0.id == exercise.id }) {
            selectedExercises.wrappedValue.remove(at: index)
        } else {
            selectedExercises.wrappedValue.append(exercise)
        }
    }
    
    func loadExercises() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        
        // Always load system exercises from local storage
        let systemExercises = (try? exerciseTemplateManager.getSystemExerciseTemplates()) ?? []
        
        do {
            // Load top exercises from remote
            let trendingExercises = try await exerciseTemplateManager.getTopExerciseTemplatesByClicks(limitTo: 50)
            
            // Combine system exercises and trending exercises
            // System exercises first, then trending (deduplicated)
            let systemIds = Set(systemExercises.map { $0.id })
            let uniqueTrending = trendingExercises.filter { !systemIds.contains($0.id) }
            
            await MainActor.run {
                exercises = systemExercises + uniqueTrending
                isLoading = false
            }
        } catch {
            // Fallback to all local exercises if remote fails
            do {
                let localExercises = try exerciseTemplateManager.getAllLocalExerciseTemplates()
                await MainActor.run {
                    exercises = localExercises
                    isLoading = false
                }
            } catch {
                // At minimum, show system exercises even if everything else fails
                await MainActor.run {
                    exercises = systemExercises
                    isLoading = false
                    if systemExercises.isEmpty {
                        errorMessage = "Failed to load exercises. Please check your connection and try again."
                    }
                }
            }
        }
    }
    
    func searchExercises() async {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If search is empty, reload top exercises
        guard !query.isEmpty else {
            await loadExercises()
            return
        }
        
        // Don't search for very short queries to avoid too many API calls
        guard query.count >= 2 else { return }
        
        // Always include system exercises in search
        let systemExercises = (try? exerciseTemplateManager.getSystemExerciseTemplates()) ?? []
        
        do {
            // Search remote exercises
            let remoteResults = try await exerciseTemplateManager.getExerciseTemplatesByName(name: query)
            
            // Combine system exercises and remote results (deduplicated)
            let systemIds = Set(systemExercises.map { $0.id })
            let uniqueRemote = remoteResults.filter { !systemIds.contains($0.id) }
            
            await MainActor.run {
                exercises = systemExercises + uniqueRemote
            }
        } catch {
            // If remote search fails, just show system exercises
            await MainActor.run {
                exercises = systemExercises
            }
        }
    }
}
