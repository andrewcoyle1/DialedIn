//
//  ExercisesPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class ExercisesPresenter {
    private let interactor: ExercisesInteractor
    private let router: ExercisesRouter

    private(set) var isLoading: Bool = false
    private(set) var searchText: String = ""
    private(set) var searchExerciseTask: Task<Void, Never>?
    private(set) var myExercises: [ExerciseTemplateModel] = []
    private(set) var favouriteExercises: [ExerciseTemplateModel] = []
    private(set) var bookmarkedExercises: [ExerciseTemplateModel] = []
    private(set) var officialExercises: [ExerciseTemplateModel] = []
    private(set) var exercises: [ExerciseTemplateModel] = []

    var selectedWorkoutTemplate: WorkoutTemplateModel?
    var selectedExerciseTemplate: ExerciseTemplateModel?

    var currentUser: UserModel? {
        interactor.currentUser
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
        interactor: ExercisesInteractor,
        router: ExercisesRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func onAddExercisePressed() {
        interactor.trackEvent(event: ExercisesViewEvents.onAddExercisePressed)
        router.showCreateExerciseView()
    }

    func onExercisePressed(exercise: ExerciseTemplateModel) {
        // Only increment click count for non-system exercises
        // System exercises (IDs starting with "system-") are read-only
        if !exercise.id.hasPrefix("system-") {
            Task {
                interactor.trackEvent(event: ExercisesViewEvents.incrementExerciseStart)
                do {
                    try await interactor.incrementExerciseTemplateInteraction(id: exercise.id)
                    interactor.trackEvent(event: ExercisesViewEvents.incrementExerciseSuccess)
                } catch {
                    interactor.trackEvent(event: ExercisesViewEvents.incrementExerciseFail(error: error))
                }
            }
        }

        router.showExerciseTemplateDetailView(delegate: ExerciseTemplateDetailDelegate(exerciseTemplate: exercise))
    }

    func onExercisePressedFromFavourites(exercise: ExerciseTemplateModel) {
        interactor.trackEvent(event: ExercisesViewEvents.onExercisePressedFromFavourites)
        onExercisePressed(exercise: exercise)
    }

    func onExercisePressedFromBookmarked(exercise: ExerciseTemplateModel) {
        interactor.trackEvent(event: ExercisesViewEvents.onExercisePressedFromBookmarked)
        onExercisePressed(exercise: exercise)
    }

    func onExercisePressedFromTrending(exercise: ExerciseTemplateModel) {
        interactor.trackEvent(event: ExercisesViewEvents.onExercisePressedFromTrending)
        onExercisePressed(exercise: exercise)
    }

    func onExercisePressedFromMyTemplates(exercise: ExerciseTemplateModel) {
        interactor.trackEvent(event: ExercisesViewEvents.onExercisePressedFromMyTemplates)
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
        interactor.trackEvent(event: ExercisesViewEvents.searchCleared)
        Task { await loadTopExercisesIfNeeded() }
    }

    func startFreshSearch(for query: String) {
        isLoading = true
        interactor.trackEvent(event: ExercisesViewEvents.performExerciseSearchStart)

        searchExerciseTask = Task {
            do {
                // Debounce the search
                try? await Task.sleep(for: .milliseconds(350))
                guard !Task.isCancelled else { return }

                // Perform the actual search
                let results = try await interactor.getExerciseTemplatesByName(name: query)

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
            interactor.trackEvent(event: ExercisesViewEvents.performExerciseSearchEmptyResults(query: query))
        } else {
            interactor.trackEvent(event: ExercisesViewEvents.performExerciseSearchSuccess(query: query, resultCount: results.count))
        }
    }

    func handleSearchError(_ error: Error) {
        interactor.trackEvent(event: ExercisesViewEvents.performExerciseSearchFail(error: error))
        isLoading = false
        exercises = []

        router.showSimpleAlert(
            title: "No Exercises Found",
            subtitle: "We couldn't find any exercise templates matching your search. Please try a different name or check your connection."
        )
    }

    func loadMyExercisesIfNeeded() async {
        guard let userId = interactor.currentUser?.userId else { return }
        interactor.trackEvent(event: ExercisesViewEvents.loadMyExercisesStart)
        do {
            let mine = try await interactor.getExerciseTemplatesForAuthor(authorId: userId)
            myExercises = mine
            interactor.trackEvent(event: ExercisesViewEvents.loadMyExercisesSuccess(count: mine.count))
        } catch {
            interactor.trackEvent(event: ExercisesViewEvents.loadMyExercisesFail(error: error))
            router.showSimpleAlert(
                title: "Unable to Load Your Exercises",
                subtitle: "We couldn't retrieve your custom exercise templates. Please check your connection or try again later."
            )
        }
    }
    
    func loadOfficialExercises() async {
        interactor.trackEvent(event: ExercisesViewEvents.loadOfficialExercisesStart)
        do {
            let official = try interactor.getSystemExerciseTemplates()
            officialExercises = official
            interactor.trackEvent(event: ExercisesViewEvents.loadOfficialExercisesSuccess(count: official.count))
        } catch {
            interactor.trackEvent(event: ExercisesViewEvents.loadOfficialExercisesFail(error: error))
            // Don't show alert for official exercises - it's not critical
        }
    }

    func loadTopExercisesIfNeeded() async {
        guard searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isLoading = true
        interactor.trackEvent(event: ExercisesViewEvents.loadTopExercisesStart)
        do {
            let top = try await interactor.getTopExerciseTemplatesByClicks(limitTo: 10)
            exercises = top
            isLoading = false
            interactor.trackEvent(event: ExercisesViewEvents.loadTopExercisesSuccess(count: top.count))
        } catch {
            isLoading = false
            interactor.trackEvent(event: ExercisesViewEvents.loadTopExercisesFail(error: error))
            router.showSimpleAlert(
                title: "Unable to Load Trending Templates",
                subtitle: "We couldn't load top exercise templates. Please try again later."
            )
        }
    }

    func syncSavedExercisesFromUser() async {
        interactor.trackEvent(event: ExercisesViewEvents.syncExercisesFromCurrentUserStart)
        guard let user = interactor.currentUser else {
            interactor.trackEvent(event: ExercisesViewEvents.syncExercisesFromCurrentUserNoUid)
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
                favs = try await interactor.getExerciseTemplates(ids: favouritedIds, limitTo: favouritedIds.count)
            }
            if !bookmarkedIds.isEmpty {
                bookmarks = try await interactor.getExerciseTemplates(ids: bookmarkedIds, limitTo: bookmarkedIds.count)
            }
            favouriteExercises = favs
            bookmarkedExercises = bookmarks
            interactor.trackEvent(event: ExercisesViewEvents.syncExercisesFromCurrentUserSuccess(favouriteCount: favs.count, bookmarkedCount: bookmarks.count))
        } catch {
            interactor.trackEvent(event: ExercisesViewEvents.syncExercisesFromCurrentUserFail(error: error))
            router.showSimpleAlert(
                title: "Unable to Load Saved Exercises",
                subtitle: "We couldn't retrieve your saved exercises. Please try again later."
            )
        }
    }
    
    func favouritesSectionViewed() {
        interactor.trackEvent(event: ExercisesViewEvents.favouritesSectionViewed(count: favouriteExercises.count))
    }
    
    func bookmarkedSectionViewed() {
        interactor.trackEvent(event: ExercisesViewEvents.bookmarkedSectionViewed(count: bookmarkedOnlyExercises.count))
    }
    
    func trendingSectionViewed() {
        interactor.trackEvent(event: ExercisesViewEvents.trendingSectionViewed(count: visibleExerciseTemplates.count))
    }
    
    func myTemplatesViewed() {
        interactor.trackEvent(event: ExercisesViewEvents.myTemplatesSectionViewed(count: myExercisesVisible.count))
    }
    
    func officialSectionViewed() {
        interactor.trackEvent(event: ExercisesViewEvents.officialSectionViewed(count: officialExercisesVisible.count))
    }
    
    func emptyStateShown() {
        interactor.trackEvent(event: ExercisesViewEvents.emptyStateShown)
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
