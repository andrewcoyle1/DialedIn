//
//  ExerciseTemplateDetailViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class ExerciseTemplateDetailViewModel {
    private let userManager: UserManager
    private let exerciseTemplateManager: ExerciseTemplateManager
    private let exerciseUnitPreferenceManager: ExerciseUnitPreferenceManager
    private let exerciseHistoryManager: ExerciseHistoryManager
    
    var section: CustomSection = .description

    private(set) var history: [ExerciseHistoryEntryModel] = []
    private(set) var records: [(String, String)] = []
    private(set) var isLoadingHistory: Bool = false
    var isBookmarked: Bool = false
    var isFavourited: Bool = false
    private(set) var unitPreference: ExerciseUnitPreference?
    var showAlert: AnyAppAlert?
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    init(
        container: DependencyContainer
    ) {
        self.userManager = container.resolve(UserManager.self)!
        self.exerciseTemplateManager = container.resolve(ExerciseTemplateManager.self)!
        self.exerciseUnitPreferenceManager = container.resolve(ExerciseUnitPreferenceManager.self)!
        self.exerciseHistoryManager = container.resolve(ExerciseHistoryManager.self)!
    }
    
    var currentUser: UserModel? {
        userManager.currentUser
    }
    
    var performedSubtitle: String {
        if isLoadingHistory { return "Loading…" }
        let count = history.count
        if count == 0 { return "No history yet" }
        if count == 1 { return "Performed 1 time" }
        return "Performed \(count) times"
    }

    func loadInitialState(exerciseTemplate: ExerciseTemplateModel) async {
        let user = userManager.currentUser
        // Always treat authored templates as bookmarked
        let isAuthor = user?.userId == exerciseTemplate.authorId
        isBookmarked = isAuthor || (user?.bookmarkedExerciseTemplateIds?.contains(exerciseTemplate.id) ?? false) || (user?.createdExerciseTemplateIds?.contains(exerciseTemplate.id) ?? false)
        isFavourited = user?.favouritedExerciseTemplateIds?.contains(exerciseTemplate.id) ?? false
        // Load unit preferences for this exercise
        unitPreference = exerciseUnitPreferenceManager.getPreference(for: exerciseTemplate.id)
        await loadHistory(exerciseTemplate: exerciseTemplate)
    }

    func loadHistory(exerciseTemplate: ExerciseTemplateModel) async {
        guard let userId = userManager.currentUser?.userId else { return }
        isLoadingHistory = true
        do {
            var filtered: [ExerciseHistoryEntryModel] = []
            // Remote by author, filter by template
            let remoteItems = try await exerciseHistoryManager.getExerciseHistoryForAuthor(authorId: userId, limitTo: 200)
            filtered = remoteItems.filter { $0.templateId == exerciseTemplate.id }
            // Fallback to local cache if remote empty
            if filtered.isEmpty {
                if let localItems = try? exerciseHistoryManager.getLocalExerciseHistoryForTemplate(templateId: exerciseTemplate.id, limitTo: 200) {
                    filtered = localItems.filter { $0.authorId == userId }
                }
            }
            await MainActor.run {
                history = filtered
                records = buildRecords(from: filtered)
                isLoadingHistory = false
            }
        } catch {
            // Try local on error
            if let localItems = try? exerciseHistoryManager.getLocalExerciseHistoryForTemplate(templateId: exerciseTemplate.id, limitTo: 200) {
                let filtered = localItems.filter { $0.authorId == userId }
                await MainActor.run {
                    history = filtered
                    records = buildRecords(from: filtered)
                    isLoadingHistory = false
                }
            } else {
                await MainActor.run { isLoadingHistory = false }
            }
        }
    }

    func buildRecords(from entries: [ExerciseHistoryEntryModel]) -> [(String, String)] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        // Simple record sample: best weight x reps from first set of each entry
        // You can refine to compute 1RM, best volume, etc.
        let tuples: [(String, String)] = entries.compactMap { entry in
            guard let first = entry.sets.first else { return nil }
            let dateStr = formatter.string(from: entry.performedAt)
            if let weight = first.weightKg, let reps = first.reps {
                return (dateStr, String(format: "%.0f kg x %d reps", weight, reps))
            } else if let reps = first.reps {
                return (dateStr, "Reps: \(reps)")
            } else if let durationSec = first.durationSec {
                return (dateStr, "Duration: \(durationSec)s")
            } else if let distanceMeters = first.distanceMeters {
                return (dateStr, String(format: "%.0f m", distanceMeters))
            }
            return (dateStr, "Completed")
        }
        return tuples
    }
    
    func onBookmarkPressed(exerciseTemplate: ExerciseTemplateModel) async {
        let newState = !isBookmarked
        do {
            // If unbookmarking and currently favourited, unfavourite first to enforce rule
            if !newState && isFavourited {
                try await exerciseTemplateManager.favouriteExerciseTemplate(id: exerciseTemplate.id, isFavourited: false)
                isFavourited = false
                // Remove from user's favourited list
                try await userManager.removeFavouritedExerciseTemplate(exerciseId: exerciseTemplate.id)
            }
            try await exerciseTemplateManager.bookmarkExerciseTemplate(id: exerciseTemplate.id, isBookmarked: newState)
            if newState {
                try await userManager.addBookmarkedExerciseTemplate(exerciseId: exerciseTemplate.id)
            } else {
                try await userManager.removeBookmarkedExerciseTemplate(exerciseId: exerciseTemplate.id)
            }
            isBookmarked = newState
        } catch {
            showAlert = AnyAppAlert(title: "Failed to update bookmark status", subtitle: "Please try again later")
        }
    }
    
    func onFavoritePressed(exerciseTemplate: ExerciseTemplateModel) async {
        let newState = !isFavourited
        do {
            // If favouriting and not bookmarked, bookmark first to enforce rule
            if newState && !isBookmarked {
                try await exerciseTemplateManager.bookmarkExerciseTemplate(id: exerciseTemplate.id, isBookmarked: true)
                try await userManager.addBookmarkedExerciseTemplate(exerciseId: exerciseTemplate.id)
                isBookmarked = true
            }
            try await exerciseTemplateManager.favouriteExerciseTemplate(id: exerciseTemplate.id, isFavourited: newState)
            if newState {
                try await userManager.addFavouritedExerciseTemplate(exerciseId: exerciseTemplate.id)
            } else {
                try await userManager.removeFavouritedExerciseTemplate(exerciseId: exerciseTemplate.id)
            }
            isFavourited = newState
        } catch {
            showAlert = AnyAppAlert(title: "Failed to update favourite status", subtitle: "Please try again later")
        }
    }
}
