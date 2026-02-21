//
//  ExerciseTemplateDetailPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class ExerciseTemplateDetailPresenter {
    private let interactor: ExerciseTemplateDetailInteractor
    private let router: ExerciseTemplateDetailRouter

    var section: CustomSection = .description

    private(set) var history: [ExerciseHistoryEntryModel] = []
    private(set) var records: [(String, String)] = []
    private(set) var isLoadingHistory: Bool = false
    var isBookmarked: Bool = false
    var isFavourited: Bool = false
    private(set) var unitPreference: ExerciseUnitPreference?

    init(
        interactor: ExerciseTemplateDetailInteractor,
        router: ExerciseTemplateDetailRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    var performedSubtitle: String {
        if isLoadingHistory { return "Loading…" }
        let count = history.count
        if count == 0 { return "No history yet" }
        if count == 1 { return "Performed 1 time" }
        return "Performed \(count) times"
    }

    func loadInitialState(exerciseTemplate: ExerciseModel) async {
        let user = interactor.currentUser
        // Always treat authored templates as bookmarked
        let isAuthor = user?.userId == exerciseTemplate.authorId
        // Load unit preferences for this exercise
        unitPreference = interactor.getPreference(templateId: exerciseTemplate.id)
        await loadHistory(exerciseTemplate: exerciseTemplate)
    }

    func loadHistory(exerciseTemplate: ExerciseModel) async {
        guard let userId = interactor.currentUser?.userId else { return }
        isLoadingHistory = true
        do {
            var filtered: [ExerciseHistoryEntryModel] = []
            // Remote by author, filter by template
            let remoteItems = try await interactor.getExerciseHistoryForAuthor(authorId: userId, limitTo: 200)
            filtered = remoteItems.filter { $0.templateId == exerciseTemplate.id }
            // Fallback to local cache if remote empty
            if filtered.isEmpty {
                if let localItems = try? interactor.getLocalExerciseHistoryForTemplate(templateId: exerciseTemplate.id, limitTo: 200) {
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
            if let localItems = try? interactor.getLocalExerciseHistoryForTemplate(templateId: exerciseTemplate.id, limitTo: 200) {
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
        
    func onDismissPressed() {
        router.dismissScreen()
    }
    
    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }
}

enum CustomSection: Hashable {
    case description
    case history
    case charts
    case records
}
