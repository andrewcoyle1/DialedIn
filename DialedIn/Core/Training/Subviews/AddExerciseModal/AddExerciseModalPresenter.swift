//
//  AddExerciseModalPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

@Observable
@MainActor
class AddExerciseModalPresenter {
    private let interactor: AddExerciseInteractor
    private let router: AddExerciseModalRouter

    private(set) var exercises: [ExerciseModel] = []
    var searchText: String = ""
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?

    var filteredExercises: [ExerciseModel] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return exercises }
        return exercises.filter { exercise in
            var fields: [String] = [
                exercise.name,
                exercise.type?.name ?? ""
            ]
            if let description = exercise.description { fields.append(description) }
            fields.append(contentsOf: exercise.muscleGroups.keys.map { $0.name })
            return fields.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }
    
    init(
        interactor: AddExerciseInteractor,
        router: AddExerciseModalRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func onExercisePressed(exercise: ExerciseModel, selectedExercises: Binding<[ExerciseModel]>) {
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
        let systemExercises = (try? interactor.getSystemExerciseTemplates()) ?? []
        
        do {
            // Load top exercises from remote
            let trendingExercises = try await interactor.getTopExerciseTemplatesByClicks(limitTo: 50)
            
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
                let localExercises = try interactor.getAllLocalExerciseTemplates()
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
        let systemExercises = (try? interactor.getSystemExerciseTemplates()) ?? []
        
        do {
            // Search remote exercises
            let remoteResults = try await interactor.getExerciseTemplatesByName(name: query)
            
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

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    func dismissScreen() {
        router.dismissScreen()
    }
}
