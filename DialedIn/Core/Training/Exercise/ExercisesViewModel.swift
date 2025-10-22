//
//  ExercisesViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class ExercisesViewModel {
    private let userManager: UserManager
    private let exerciseTemplateManager: ExerciseTemplateManager
    private let logManager: LogManager
    private let onExerciseSelectionChanged: ((ExerciseTemplateModel) -> Void)?
    
    private(set) var isLoading: Bool = false
    private(set) var searchText: String = ""
    private(set) var showAlert: AnyAppAlert?
    private(set) var searchExerciseTask: Task<Void, Never>?
    private(set) var myExercises: [ExerciseTemplateModel] = []
    private(set) var favouriteExercises: [ExerciseTemplateModel] = []
    private(set) var bookmarkedExercises: [ExerciseTemplateModel] = []
    private(set) var officialExercises: [ExerciseTemplateModel] = []
    private(set) var exercises: [ExerciseTemplateModel] = []

    var isShowingInspector: Bool = false
    var selectedWorkoutTemplate: WorkoutTemplateModel?
    var selectedExerciseTemplate: ExerciseTemplateModel?
    var showCreateExercise: Bool = false
    
    var currentUser: UserModel? {
        userManager.currentUser
    }
    
    var myExerciseIds: Set<String> {
        Set(myExercises.map { $0.id })
    }

    var favouriteExerciseIds: Set<String> {
        Set(favouriteExercises.map { $0.id })
    }

    var myExercisesVisible: [ExerciseTemplateModel] {
        myExercises.filter { !favouriteExerciseIds.contains($0.id) }
    }

    var bookmarkedOnlyExercises: [ExerciseTemplateModel] {
        bookmarkedExercises.filter { !favouriteExerciseIds.contains($0.id) && !myExerciseIds.contains($0.id) }
    }
    
    var officialExerciseIds: Set<String> {
        Set(officialExercises.map { $0.id })
    }

    var savedExerciseIds: Set<String> {
        favouriteExerciseIds.union(Set(bookmarkedOnlyExercises.map { $0.id }))
    }
    
    var officialExercisesVisible: [ExerciseTemplateModel] {
        officialExercises.filter { !favouriteExerciseIds.contains($0.id) && !myExerciseIds.contains($0.id) && !savedExerciseIds.contains($0.id) }
    }

    var trendingExercisesDeduped: [ExerciseTemplateModel] {
        exercises.filter { !myExerciseIds.contains($0.id) && !savedExerciseIds.contains($0.id) && !officialExerciseIds.contains($0.id) }
    }

    var visibleExerciseTemplates: [ExerciseTemplateModel] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? trendingExercisesDeduped : exercises
    }
    
    init(
        container: DependencyContainer,
        onExerciseSelectionChanged: ((ExerciseTemplateModel) -> Void)? = nil
    ) {
        self.userManager = container.resolve(UserManager.self)!
        self.exerciseTemplateManager = container.resolve(ExerciseTemplateManager.self)!
        self.logManager = container.resolve(LogManager.self)!
        self.onExerciseSelectionChanged = onExerciseSelectionChanged
    }
    
    func onAddExercisePressed() {
        logManager.trackEvent(event: ExercisesViewEvents.onAddExercisePressed)
        showCreateExercise = true
    }

    func onExercisePressed(exercise: ExerciseTemplateModel) {
        // Only increment click count for non-system exercises
        // System exercises (IDs starting with "system-") are read-only
        if !exercise.id.hasPrefix("system-") {
            Task {
                logManager.trackEvent(event: ExercisesViewEvents.incrementExerciseStart)
                do {
                    try await exerciseTemplateManager.incrementExerciseTemplateInteraction(id: exercise.id)
                    logManager.trackEvent(event: ExercisesViewEvents.incrementExerciseSuccess)
                } catch {
                    logManager.trackEvent(event: ExercisesViewEvents.incrementExerciseFail(error: error))
                }
            }
        }
        selectedWorkoutTemplate = nil
        selectedExerciseTemplate = exercise
        isShowingInspector = true
        onExerciseSelectionChanged?(exercise)
    }

    func onExercisePressedFromFavourites(exercise: ExerciseTemplateModel) {
        logManager.trackEvent(event: ExercisesViewEvents.onExercisePressedFromFavourites)
        onExercisePressed(exercise: exercise)
    }

    func onExercisePressedFromBookmarked(exercise: ExerciseTemplateModel) {
        logManager.trackEvent(event: ExercisesViewEvents.onExercisePressedFromBookmarked)
        onExercisePressed(exercise: exercise)
    }

    func onExercisePressedFromTrending(exercise: ExerciseTemplateModel) {
        logManager.trackEvent(event: ExercisesViewEvents.onExercisePressedFromTrending)
        onExercisePressed(exercise: exercise)
    }

    func onExercisePressedFromMyTemplates(exercise: ExerciseTemplateModel) {
        logManager.trackEvent(event: ExercisesViewEvents.onExercisePressedFromMyTemplates)
        onExercisePressed(exercise: exercise)
    }

    func performExerciseSearch(for query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)

        // Cancel any ongoing search
        searchExerciseTask?.cancel()

        guard !trimmed.isEmpty else {
            handleSearchCleared()
            return
        }

        startFreshSearch(for: trimmed)
    }

    func handleSearchCleared() {
        logManager.trackEvent(event: ExercisesViewEvents.searchCleared)
        Task { await loadTopExercisesIfNeeded() }
    }

    func startFreshSearch(for query: String) {
        isLoading = true
        logManager.trackEvent(event: ExercisesViewEvents.performExerciseSearchStart)

        searchExerciseTask = Task { [exerciseTemplateManager] in
            do {
                // Debounce the search
                try? await Task.sleep(for: .milliseconds(350))
                guard !Task.isCancelled else { return }

                // Perform the actual search
                let results = try await exerciseTemplateManager.getExerciseTemplatesByName(name: query)

                // Update UI on main thread
                await MainActor.run {
                    handleSearchResults(results, for: query)
                }

            } catch {
                await MainActor.run {
                    handleSearchError(error)
                }
            }
        }
    }

    func handleSearchResults(_ results: [ExerciseTemplateModel], for query: String) {
        exercises = results
        isLoading = false

        if results.isEmpty {
            logManager.trackEvent(event: ExercisesViewEvents.performExerciseSearchEmptyResults(query: query))
        } else {
            logManager.trackEvent(event: ExercisesViewEvents.performExerciseSearchSuccess(query: query, resultCount: results.count))
        }
    }

    func handleSearchError(_ error: Error) {
        logManager.trackEvent(event: ExercisesViewEvents.performExerciseSearchFail(error: error))
        isLoading = false
        exercises = []

        showAlert = AnyAppAlert(
            title: "No Exercises Found",
            subtitle: "We couldn't find any exercise templates matching your search. Please try a different name or check your connection."
        )
    }

    func loadMyExercisesIfNeeded() async {
        guard let userId = userManager.currentUser?.userId else { return }
        logManager.trackEvent(event: ExercisesViewEvents.loadMyExercisesStart)
        do {
            let mine = try await exerciseTemplateManager.getExerciseTemplatesForAuthor(authorId: userId)
            myExercises = mine
            logManager.trackEvent(event: ExercisesViewEvents.loadMyExercisesSuccess(count: mine.count))
        } catch {
            logManager.trackEvent(event: ExercisesViewEvents.loadMyExercisesFail(error: error))
            showAlert = AnyAppAlert(
                title: "Unable to Load Your Exercises",
                subtitle: "We couldn't retrieve your custom exercise templates. Please check your connection or try again later."
            )
        }
    }
    
    func loadOfficialExercises() async {
        logManager.trackEvent(event: ExercisesViewEvents.loadOfficialExercisesStart)
        do {
            let official = try exerciseTemplateManager.getSystemExerciseTemplates()
            officialExercises = official
            logManager.trackEvent(event: ExercisesViewEvents.loadOfficialExercisesSuccess(count: official.count))
        } catch {
            logManager.trackEvent(event: ExercisesViewEvents.loadOfficialExercisesFail(error: error))
            // Don't show alert for official exercises - it's not critical
        }
    }

    func loadTopExercisesIfNeeded() async {
        guard searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isLoading = true
        logManager.trackEvent(event: ExercisesViewEvents.loadTopExercisesStart)
        do {
            let top = try await exerciseTemplateManager.getTopExerciseTemplatesByClicks(limitTo: 10)
            exercises = top
            isLoading = false
            logManager.trackEvent(event: ExercisesViewEvents.loadTopExercisesSuccess(count: top.count))
        } catch {
            isLoading = false
            logManager.trackEvent(event: ExercisesViewEvents.loadTopExercisesFail(error: error))
            showAlert = AnyAppAlert(
                title: "Unable to Load Trending Templates",
                subtitle: "We couldn't load top exercise templates. Please try again later."
            )
        }
    }

    func syncSavedExercisesFromUser() async {
        logManager.trackEvent(event: ExercisesViewEvents.syncExercisesFromCurrentUserStart)
        guard let user = userManager.currentUser else {
            logManager.trackEvent(event: ExercisesViewEvents.syncExercisesFromCurrentUserNoUid)
            favouriteExercises = []
            bookmarkedExercises = []
            return
        }
        let bookmarkedIds = user.bookmarkedExerciseTemplateIds ?? []
        let favouritedIds = user.favouritedExerciseTemplateIds ?? []
        if bookmarkedIds.isEmpty && favouritedIds.isEmpty {
            favouriteExercises = []
            bookmarkedExercises = []
            return
        }
        do {
            var favs: [ExerciseTemplateModel] = []
            var bookmarks: [ExerciseTemplateModel] = []
            if !favouritedIds.isEmpty {
                favs = try await exerciseTemplateManager.getExerciseTemplates(ids: favouritedIds, limitTo: favouritedIds.count)
            }
            if !bookmarkedIds.isEmpty {
                bookmarks = try await exerciseTemplateManager.getExerciseTemplates(ids: bookmarkedIds, limitTo: bookmarkedIds.count)
            }
            favouriteExercises = favs
            bookmarkedExercises = bookmarks
            logManager.trackEvent(event: ExercisesViewEvents.syncExercisesFromCurrentUserSuccess(favouriteCount: favs.count, bookmarkedCount: bookmarks.count))
        } catch {
            logManager.trackEvent(event: ExercisesViewEvents.syncExercisesFromCurrentUserFail(error: error))
            showAlert = AnyAppAlert(
                title: "Unable to Load Saved Exercises",
                subtitle: "We couldn't retrieve your saved exercises. Please try again later."
            )
        }
    }
    
    func favouritesSectionViewed() {
        logManager.trackEvent(event: ExercisesViewEvents.favouritesSectionViewed(count: favouriteExercises.count))
    }
    
    func bookmarkedSectionViewed() {
        logManager.trackEvent(event: ExercisesViewEvents.bookmarkedSectionViewed(count: bookmarkedOnlyExercises.count))
    }
    
    func trendingSectionViewed() {
        logManager.trackEvent(event: ExercisesViewEvents.trendingSectionViewed(count: visibleExerciseTemplates.count))
    }
    
    func myTemplatesViewed() {
        logManager.trackEvent(event: ExercisesViewEvents.myTemplatesSectionViewed(count: myExercisesVisible.count))
    }
    
    func officialSectionViewed() {
        logManager.trackEvent(event: ExercisesViewEvents.officialSectionViewed(count: officialExercisesVisible.count))
    }
    
    func emptyStateShown() {
        logManager.trackEvent(event: ExercisesViewEvents.emptyStateShown)
    }
    
    enum ExercisesViewEvents: LoggableEvent {
        case performExerciseSearchStart
        case performExerciseSearchSuccess(query: String, resultCount: Int)
        case performExerciseSearchFail(error: Error)
        case performExerciseSearchEmptyResults(query: String)
        case searchCleared
        case loadMyExercisesStart
        case loadMyExercisesSuccess(count: Int)
        case loadMyExercisesFail(error: Error)
        case loadOfficialExercisesStart
        case loadOfficialExercisesSuccess(count: Int)
        case loadOfficialExercisesFail(error: Error)
        case loadTopExercisesStart
        case loadTopExercisesSuccess(count: Int)
        case loadTopExercisesFail(error: Error)
        case incrementExerciseStart
        case incrementExerciseSuccess
        case incrementExerciseFail(error: Error)
        case syncExercisesFromCurrentUserStart
        case syncExercisesFromCurrentUserNoUid
        case syncExercisesFromCurrentUserSuccess(favouriteCount: Int, bookmarkedCount: Int)
        case syncExercisesFromCurrentUserFail(error: Error)
        case onAddExercisePressed
        case favouritesSectionViewed(count: Int)
        case bookmarkedSectionViewed(count: Int)
        case officialSectionViewed(count: Int)
        case trendingSectionViewed(count: Int)
        case myTemplatesSectionViewed(count: Int)
        case emptyStateShown
        case onExercisePressedFromFavourites
        case onExercisePressedFromBookmarked
        case onExercisePressedFromTrending
        case onExercisePressedFromMyTemplates

        var eventName: String {
            switch self {
            case .performExerciseSearchStart:          return "ExercisesView_Search_Start"
            case .performExerciseSearchSuccess:        return "ExercisesView_Search_Success"
            case .performExerciseSearchFail:           return "ExercisesView_Search_Fail"
            case .performExerciseSearchEmptyResults:   return "ExercisesView_Search_EmptyResults"
            case .searchCleared:                         return "ExercisesView_Search_Cleared"
            case .loadMyExercisesStart:                return "ExercisesView_LoadMyExercises_Start"
            case .loadMyExercisesSuccess:              return "ExercisesView_LoadMyExercises_Success"
            case .loadMyExercisesFail:                 return "ExercisesView_LoadMyExercises_Fail"
            case .loadOfficialExercisesStart:          return "ExercisesView_LoadOfficialExercises_Start"
            case .loadOfficialExercisesSuccess:        return "ExercisesView_LoadOfficialExercises_Success"
            case .loadOfficialExercisesFail:           return "ExercisesView_LoadOfficialExercises_Fail"
            case .loadTopExercisesStart:               return "ExercisesView_LoadTopExercises_Start"
            case .loadTopExercisesSuccess:             return "ExercisesView_LoadTopExercises_Success"
            case .loadTopExercisesFail:                return "ExercisesView_LoadTopExercises_Fail"
            case .incrementExerciseStart:              return "ExercisesView_IncrementExercise_Start"
            case .incrementExerciseSuccess:            return "ExercisesView_IncrementExercise_Success"
            case .incrementExerciseFail:               return "ExercisesView_IncrementExercise_Fail"
            case .syncExercisesFromCurrentUserStart:   return "ExercisesView_UserSync_Start"
            case .syncExercisesFromCurrentUserNoUid:   return "ExercisesView_UserSync_NoUID"
            case .syncExercisesFromCurrentUserSuccess: return "ExercisesView_UserSync_Success"
            case .syncExercisesFromCurrentUserFail:    return "ExercisesView_UserSync_Fail"
            case .onAddExercisePressed:                return "ExercisesView_AddExercisePressed"
            case .favouritesSectionViewed:               return "ExercisesView_Favourites_SectionViewed"
            case .bookmarkedSectionViewed:               return "ExercisesView_Bookmarked_SectionViewed"
            case .officialSectionViewed:                 return "ExercisesView_Official_SectionViewed"
            case .trendingSectionViewed:                 return "ExercisesView_Trending_SectionViewed"
            case .myTemplatesSectionViewed:              return "ExercisesView_MyTemplates_SectionViewed"
            case .emptyStateShown:                       return "ExercisesView_EmptyState_Shown"
            case .onExercisePressedFromFavourites:     return "ExercisesView_ExercisePressed_Favourites"
            case .onExercisePressedFromBookmarked:     return "ExercisesView_ExercisePressed_Bookmarked"
            case .onExercisePressedFromTrending:       return "ExercisesView_ExercisePressed_Trending"
            case .onExercisePressedFromMyTemplates:    return "ExercisesView_ExercisePressed_MyTemplates"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .performExerciseSearchSuccess(query: let query, resultCount: let count):
                return ["query": query, "resultCount": count]
            case .performExerciseSearchEmptyResults(query: let query):
                return ["query": query]
            case .loadMyExercisesSuccess(count: let count):
                return ["count": count]
            case .loadOfficialExercisesSuccess(count: let count):
                return ["count": count]
            case .loadTopExercisesSuccess(count: let count):
                return ["count": count]
            case .syncExercisesFromCurrentUserSuccess(favouriteCount: let favCount, bookmarkedCount: let bookCount):
                return ["favouriteCount": favCount, "bookmarkedCount": bookCount]
            case .favouritesSectionViewed(count: let count):
                return ["count": count]
            case .bookmarkedSectionViewed(count: let count):
                return ["count": count]
            case .officialSectionViewed(count: let count):
                return ["count": count]
            case .trendingSectionViewed(count: let count):
                return ["count": count]
            case .myTemplatesSectionViewed(count: let count):
                return ["count": count]
            case .loadMyExercisesFail(error: let error), .loadOfficialExercisesFail(error: let error), .loadTopExercisesFail(error: let error), .performExerciseSearchFail(error: let error), .incrementExerciseFail(error: let error), .syncExercisesFromCurrentUserFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .loadMyExercisesFail, .loadOfficialExercisesFail, .loadTopExercisesFail, .performExerciseSearchFail, .incrementExerciseFail, .syncExercisesFromCurrentUserFail:
                return .severe
            case .syncExercisesFromCurrentUserNoUid:
                return .warning
            default:
                return .analytic

            }
        }
    }
}
