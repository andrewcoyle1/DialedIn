//
//  WorkoutListPresenterBuilder.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class WorkoutListPresenterBuilder {
    
    private let interactor: WorkoutListInteractorBuilder
    private let router: WorkoutListRouterBuilder

    private(set) var isLoading: Bool = false
    private(set) var searchText: String = ""
    private(set) var searchWorkoutTask: Task<Void, Never>?
    private(set) var myWorkouts: [WorkoutTemplateModel] = []
    private(set) var favouriteWorkouts: [WorkoutTemplateModel] = []
    private(set) var bookmarkedWorkouts: [WorkoutTemplateModel] = []
    private(set) var systemWorkouts: [WorkoutTemplateModel] = []
    private(set) var workouts: [WorkoutTemplateModel] = []
    
    var showCreateWorkout: Bool = false
    var selectedExerciseTemplate: ExerciseTemplateModel?
    var selectedWorkoutTemplate: WorkoutTemplateModel?
    
    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    var myWorkoutIds: Set<String> {
        Set(myWorkouts.map { $0.id })
    }

    var favouriteWorkoutIds: Set<String> {
        Set(favouriteWorkouts.map { $0.id })
    }

    var myWorkoutsVisible: [WorkoutTemplateModel] {
        myWorkouts.filter { !favouriteWorkoutIds.contains($0.id) }
    }

    var bookmarkedOnlyWorkouts: [WorkoutTemplateModel] {
        bookmarkedWorkouts.filter { !favouriteWorkoutIds.contains($0.id) && !myWorkoutIds.contains($0.id) }
    }

    var savedWorkoutIds: Set<String> {
        favouriteWorkoutIds.union(Set(bookmarkedOnlyWorkouts.map { $0.id }))
    }

    var trendingWorkoutsDeduped: [WorkoutTemplateModel] {
        workouts.filter { !myWorkoutIds.contains($0.id) && !savedWorkoutIds.contains($0.id) }
    }

    var visibleWorkoutTemplates: [WorkoutTemplateModel] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? trendingWorkoutsDeduped : workouts
    }
    
    init(
        interactor: WorkoutListInteractorBuilder,
        router: WorkoutListRouterBuilder
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func onAddWorkoutPressed() {
        interactor.trackEvent(event: Event.onAddWorkoutPressed)
        router.showCreateWorkoutView(delegate: CreateWorkoutDelegate(workoutTemplate: nil))
    }

    private func onWorkoutPressed(workout: WorkoutTemplateModel, onWorkoutPressed: ((WorkoutTemplateModel) -> Void)? = nil) {
        // Only increment click count for non-system workouts
        // System workouts (IDs starting with "system-") are read-only
        if !workout.id.hasPrefix("system-") {
            Task {
                interactor.trackEvent(event: Event.incrementWorkoutStart)
                do {
                    try await interactor.incrementWorkoutTemplateInteraction(id: workout.id)
                    interactor.trackEvent(event: Event.incrementWorkoutSuccess)
                } catch {
                    interactor.trackEvent(event: Event.incrementWorkoutFail(error: error))
                }
            }
        }
        onWorkoutPressed?(workout)
    }

    func onWorkoutPressedFromFavourites(workout: WorkoutTemplateModel, onWorkoutPressed: ((WorkoutTemplateModel) -> Void)? = nil) {
        interactor.trackEvent(event: Event.onWorkoutPressedFromFavourites)
        self.onWorkoutPressed(workout: workout, onWorkoutPressed: onWorkoutPressed)
    }

    func onWorkoutPressedFromBookmarked(workout: WorkoutTemplateModel, onWorkoutPressed: ((WorkoutTemplateModel) -> Void)? = nil) {
        interactor.trackEvent(event: Event.onWorkoutPressedFromBookmarked)
        self.onWorkoutPressed(workout: workout, onWorkoutPressed: onWorkoutPressed)
    }

    func onWorkoutPressedFromTrending(workout: WorkoutTemplateModel, onWorkoutPressed: ((WorkoutTemplateModel) -> Void)? = nil) {
        interactor.trackEvent(event: Event.onWorkoutPressedFromTrending)
        self.onWorkoutPressed(workout: workout, onWorkoutPressed: onWorkoutPressed)
    }

    func onWorkoutPressedFromMyTemplates(workout: WorkoutTemplateModel, onWorkoutPressed: ((WorkoutTemplateModel) -> Void)? = nil) {
        interactor.trackEvent(event: Event.onWorkoutPressedFromMyTemplates)
        self.onWorkoutPressed(workout: workout, onWorkoutPressed: onWorkoutPressed)
    }

    func onWorkoutPressedFromSystem(workout: WorkoutTemplateModel, onWorkoutPressed: ((WorkoutTemplateModel) -> Void)? = nil) {
        interactor.trackEvent(event: Event.onWorkoutPressedFromSystem)
        self.onWorkoutPressed(workout: workout, onWorkoutPressed: onWorkoutPressed)
    }

    func performWorkoutSearch(for query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)

        // Cancel any ongoing search
        searchWorkoutTask?.cancel()

        guard !trimmed.isEmpty else {
            handleSearchCleared()
            return
        }

        startFreshSearch(for: trimmed)
    }

    func handleSearchCleared() {
        interactor.trackEvent(event: Event.searchCleared)
        Task { await loadTopWorkoutsIfNeeded() }
    }

    func startFreshSearch(for query: String) {
        isLoading = true
        interactor.trackEvent(event: Event.performWorkoutSearchStart)

        searchWorkoutTask = Task {
            do {
                // Debounce the search
                try? await Task.sleep(for: .milliseconds(350))
                guard !Task.isCancelled else { return }

                // Perform the actual search
                let results = try await interactor.getWorkoutTemplatesByName(name: query)

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

    func handleSearchResults(_ results: [WorkoutTemplateModel], for query: String) {
        workouts = results
        isLoading = false

        if results.isEmpty {
            interactor.trackEvent(event: Event.performWorkoutSearchEmptyResults(query: query))
        } else {
            interactor.trackEvent(event: Event.performWorkoutSearchSuccess(query: query, resultCount: results.count))
        }
    }

    func handleSearchError(_ error: Error) {
        interactor.trackEvent(event: Event.performWorkoutSearchFail(error: error))
        isLoading = false
        workouts = []

        router.showSimpleAlert(
            title: "No Workouts Found",
            subtitle: "We couldn't find any workout templates matching your search. Please try a different name or check your connection."
        )
    }
    
    func loadAllWorkouts() async {
        await loadSystemWorkouts()
        await loadMyWorkoutsIfNeeded()
        await loadTopWorkoutsIfNeeded()
        await syncSavedWorkoutsFromUser()
    }

    func loadSystemWorkouts() async {
        // Load seeded system workouts from local storage
        do {
            let allLocal = try interactor.getAllLocalWorkoutTemplates()
            systemWorkouts = allLocal.filter { $0.isSystemWorkout }
            interactor.trackEvent(event: Event.loadSystemWorkoutsSuccess(count: systemWorkouts.count))
        } catch {
            interactor.trackEvent(event: Event.loadSystemWorkoutsFail(error: error))
            systemWorkouts = []
        }
    }
    
    func loadMyWorkoutsIfNeeded() async {
        guard let userId = interactor.currentUser?.userId else { return }
        interactor.trackEvent(event: Event.loadMyWorkoutsStart)
        do {
            let mine = try await interactor.getWorkoutTemplatesForAuthor(authorId: userId)
            myWorkouts = mine
            interactor.trackEvent(event: Event.loadMyWorkoutsSuccess(count: mine.count))
        } catch {
            interactor.trackEvent(event: Event.loadMyWorkoutsFail(error: error))
            router.showSimpleAlert(
                title: "Unable to Load Your Workouts",
                subtitle: "We couldn't retrieve your custom workout templates. Please check your connection or try again later."
            )
        }
    }

    func loadTopWorkoutsIfNeeded() async {
        guard searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isLoading = true
        interactor.trackEvent(event: Event.loadTopWorkoutsStart)
        do {
            let top = try await interactor.getTopWorkoutTemplatesByClicks(limitTo: 10)
            workouts = top
            isLoading = false
            interactor.trackEvent(event: Event.loadTopWorkoutsSuccess(count: top.count))
        } catch {
            isLoading = false
            interactor.trackEvent(event: Event.loadTopWorkoutsFail(error: error))
            router.showSimpleAlert(
                title: "Unable to Load Trending Templates",
                subtitle: "We couldn't load top workout templates. Please try again later."
            )
        }
    }

    func syncSavedWorkoutsFromUser() async {
        interactor.trackEvent(event: Event.syncWorkoutsFromCurrentUserStart)
        guard let user = interactor.currentUser else {
            interactor.trackEvent(event: Event.syncWorkoutsFromCurrentUserNoUid)
            favouriteWorkouts = []
            bookmarkedWorkouts = []
            return
        }
        let bookmarkedIds = user.bookmarkedWorkoutTemplateIds ?? []
        let favouritedIds = user.favouritedWorkoutTemplateIds ?? []
        if bookmarkedIds.isEmpty && favouritedIds.isEmpty {
            favouriteWorkouts = []
            bookmarkedWorkouts = []
            interactor.trackEvent(event: Event.syncWorkoutsFromCurrentUserSuccess(favouriteCount: 0, bookmarkedCount: 0))
            return
        }
        do {
            var favs: [WorkoutTemplateModel] = []
            var bookmarks: [WorkoutTemplateModel] = []
            if !favouritedIds.isEmpty {
                favs = try await interactor.getWorkoutTemplates(ids: favouritedIds, limitTo: favouritedIds.count)
            }
            if !bookmarkedIds.isEmpty {
                bookmarks = try await interactor.getWorkoutTemplates(ids: bookmarkedIds, limitTo: bookmarkedIds.count)
            }
            favouriteWorkouts = favs
            bookmarkedWorkouts = bookmarks
            interactor.trackEvent(event: Event.syncWorkoutsFromCurrentUserSuccess(favouriteCount: favs.count, bookmarkedCount: bookmarks.count))
        } catch {
            interactor.trackEvent(event: Event.syncWorkoutsFromCurrentUserFail(error: error))
            router.showSimpleAlert(
                title: "Unable to Load Saved Workouts",
                subtitle: "We couldn't retrieve your saved workouts. Please try again later."
            )
        }
    }
    
    func favouritesSectionViewed() {
        interactor.trackEvent(event: Event.favouritesSectionViewed(count: favouriteWorkouts.count))
    }
    
    func bookmarkedSectionViewed() {
        interactor.trackEvent(event: Event.bookmarkedSectionViewed(count: bookmarkedOnlyWorkouts.count))
    }
    
    func trendingSectionViewed() {
        interactor.trackEvent(event: Event.trendingSectionViewed(count: visibleWorkoutTemplates.count))
    }
    
    func emptyStateShown() {
        interactor.trackEvent(event: Event.emptyStateShown)
    }

    func myTemplatesSectionViewed() {
        interactor.trackEvent(event: Event.myTemplatesSectionViewed(count: myWorkoutsVisible.count))
    }
    
    func systemTemplatesSectionViewed() {
        interactor.trackEvent(event: Event.systemTemplatesSectionViewed(count: systemWorkouts.count))
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case performWorkoutSearchStart
        case performWorkoutSearchSuccess(query: String, resultCount: Int)
        case performWorkoutSearchFail(error: Error)
        case performWorkoutSearchEmptyResults(query: String)
        case searchCleared
        case loadSystemWorkoutsSuccess(count: Int)
        case loadSystemWorkoutsFail(error: Error)
        case loadMyWorkoutsStart
        case loadMyWorkoutsSuccess(count: Int)
        case loadMyWorkoutsFail(error: Error)
        case loadTopWorkoutsStart
        case loadTopWorkoutsSuccess(count: Int)
        case loadTopWorkoutsFail(error: Error)
        case incrementWorkoutStart
        case incrementWorkoutSuccess
        case incrementWorkoutFail(error: Error)
        case syncWorkoutsFromCurrentUserStart
        case syncWorkoutsFromCurrentUserNoUid
        case syncWorkoutsFromCurrentUserSuccess(favouriteCount: Int, bookmarkedCount: Int)
        case syncWorkoutsFromCurrentUserFail(error: Error)
        case onAddWorkoutPressed
        case favouritesSectionViewed(count: Int)
        case bookmarkedSectionViewed(count: Int)
        case systemTemplatesSectionViewed(count: Int)
        case trendingSectionViewed(count: Int)
        case myTemplatesSectionViewed(count: Int)
        case emptyStateShown
        case onWorkoutPressedFromFavourites
        case onWorkoutPressedFromBookmarked
        case onWorkoutPressedFromTrending
        case onWorkoutPressedFromMyTemplates
        case onWorkoutPressedFromSystem

        var eventName: String {
            switch self {
            case .performWorkoutSearchStart:          return "WorkoutsView_Search_Start"
            case .performWorkoutSearchSuccess:        return "WorkoutsView_Search_Success"
            case .performWorkoutSearchFail:           return "WorkoutsView_Search_Fail"
            case .performWorkoutSearchEmptyResults:   return "WorkoutsView_Search_EmptyResults"
            case .searchCleared:                      return "WorkoutsView_Search_Cleared"
            case .loadSystemWorkoutsSuccess:          return "WorkoutsView_LoadSystemWorkouts_Success"
            case .loadSystemWorkoutsFail:             return "WorkoutsView_LoadSystemWorkouts_Fail"
            case .loadMyWorkoutsStart:                return "WorkoutsView_LoadMyWorkouts_Start"
            case .loadMyWorkoutsSuccess:              return "WorkoutsView_LoadMyWorkouts_Success"
            case .loadMyWorkoutsFail:                 return "WorkoutsView_LoadMyWorkouts_Fail"
            case .loadTopWorkoutsStart:               return "WorkoutsView_LoadTopWorkouts_Start"
            case .loadTopWorkoutsSuccess:             return "WorkoutsView_LoadTopWorkouts_Success"
            case .loadTopWorkoutsFail:                return "WorkoutsView_LoadTopWorkouts_Fail"
            case .incrementWorkoutStart:              return "WorkoutsView_IncrementWorkout_Start"
            case .incrementWorkoutSuccess:            return "WorkoutsView_IncrementWorkout_Success"
            case .incrementWorkoutFail:               return "WorkoutsView_IncrementWorkout_Fail"
            case .syncWorkoutsFromCurrentUserStart:   return "WorkoutsView_UserSync_Start"
            case .syncWorkoutsFromCurrentUserNoUid:   return "WorkoutsView_UserSync_NoUID"
            case .syncWorkoutsFromCurrentUserSuccess: return "WorkoutsView_UserSync_Success"
            case .syncWorkoutsFromCurrentUserFail:    return "WorkoutsView_UserSync_Fail"
            case .onAddWorkoutPressed:                return "WorkoutsView_AddWorkoutPressed"
            case .favouritesSectionViewed:            return "WorkoutsView_Favourites_SectionViewed"
            case .bookmarkedSectionViewed:            return "WorkoutsView_Bookmarked_SectionViewed"
            case .systemTemplatesSectionViewed:       return "WorkoutsView_SystemTemplates_SectionViewed"
            case .trendingSectionViewed:              return "WorkoutsView_Trending_SectionViewed"
            case .myTemplatesSectionViewed:           return "WorkoutsView_MyTemplates_SectionViewed"
            case .emptyStateShown:                    return "WorkoutsView_EmptyState_Shown"
            case .onWorkoutPressedFromFavourites:     return "WorkoutsView_WorkoutPressed_Favourites"
            case .onWorkoutPressedFromBookmarked:     return "WorkoutsView_WorkoutPressed_Bookmarked"
            case .onWorkoutPressedFromTrending:       return "WorkoutsView_WorkoutPressed_Trending"
            case .onWorkoutPressedFromMyTemplates:    return "WorkoutsView_WorkoutPressed_MyTemplates"
            case .onWorkoutPressedFromSystem:         return "WorkoutsView_WorkoutPressed_System"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .performWorkoutSearchSuccess(query: let query, resultCount: let count):
                return ["query": query, "resultCount": count]
            case .performWorkoutSearchEmptyResults(query: let query):
                return ["query": query]
            case .loadSystemWorkoutsSuccess(count: let count):
                return ["count": count]
            case .loadMyWorkoutsSuccess(count: let count):
                return ["count": count]
            case .loadTopWorkoutsSuccess(count: let count):
                return ["count": count]
            case .syncWorkoutsFromCurrentUserSuccess(favouriteCount: let favCount, bookmarkedCount: let bookCount):
                return ["favouriteCount": favCount, "bookmarkedCount": bookCount]
            case .favouritesSectionViewed(count: let count):
                return ["count": count]
            case .bookmarkedSectionViewed(count: let count):
                return ["count": count]
            case .systemTemplatesSectionViewed(count: let count):
                return ["count": count]
            case .trendingSectionViewed(count: let count):
                return ["count": count]
            case .myTemplatesSectionViewed(count: let count):
                return ["count": count]
            case .loadSystemWorkoutsFail(error: let error), .loadMyWorkoutsFail(error: let error), .loadTopWorkoutsFail(error: let error), .performWorkoutSearchFail(error: let error), .incrementWorkoutFail(error: let error), .syncWorkoutsFromCurrentUserFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .loadSystemWorkoutsFail, .loadMyWorkoutsFail, .loadTopWorkoutsFail, .performWorkoutSearchFail, .incrementWorkoutFail, .syncWorkoutsFromCurrentUserFail:
                return .severe
            case .syncWorkoutsFromCurrentUserNoUid:
                return .warning
            default:
                return .analytic

            }
        }
    }
}
