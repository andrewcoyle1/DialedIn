//
//  IngredientsPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import Foundation

protocol IngredientsInteractor {
    var currentUser: UserModel? { get }
    func incrementIngredientTemplateInteraction(id: String) async throws
    func getIngredientTemplatesByName(name: String) async throws -> [IngredientTemplateModel]
    func getIngredientTemplatesForAuthor(authorId: String) async throws -> [IngredientTemplateModel]
    func getTopIngredientTemplatesByClicks(limitTo: Int) async throws -> [IngredientTemplateModel]
    func getIngredientTemplates(ids: [String], limitTo: Int) async throws -> [IngredientTemplateModel]
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: IngredientsInteractor { }

@MainActor
protocol IngredientsRouter {
    func showIngredientDetailView(delegate: IngredientDetailDelegate)
    func showSimpleAlert(title: String, subtitle: String?)
}

extension CoreRouter: IngredientsRouter {

}

@Observable
@MainActor
class IngredientsPresenter {
    private let interactor: IngredientsInteractor
    private let router: IngredientsRouter

    var isLoading: Bool = false
    var searchText: String = ""
    var searchIngredientTask: Task<Void, Never>?
    var myIngredients: [IngredientTemplateModel] = []
    var favouriteIngredients: [IngredientTemplateModel] = []
    var bookmarkedIngredients: [IngredientTemplateModel] = []
    var ingredients: [IngredientTemplateModel] = []

    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    // MARK: Computed variables
    var myIngredientIds: Set<String> {
        Set(myIngredients.map { $0.id })
    }

    var favouriteIngredientIds: Set<String> {
        Set(favouriteIngredients.map { $0.id })
    }

    var myIngredientsVisible: [IngredientTemplateModel] {
        myIngredients.filter { !favouriteIngredientIds.contains($0.id) }
    }

    var bookmarkedOnlyIngredients: [IngredientTemplateModel] {
        bookmarkedIngredients.filter { !favouriteIngredientIds.contains($0.id) && !myIngredientIds.contains($0.id) }
    }

    var savedIngredientIds: Set<String> {
        favouriteIngredientIds.union(Set(bookmarkedOnlyIngredients.map { $0.id }))
    }

    var trendingIngredientsDeduped: [IngredientTemplateModel] {
        ingredients.filter { !myIngredientIds.contains($0.id) && !savedIngredientIds.contains($0.id) }
    }

    var visibleIngredientTemplates: [IngredientTemplateModel] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? trendingIngredientsDeduped : ingredients
    }
    
    init(
        interactor: IngredientsInteractor,
        router: IngredientsRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func onMyTemplatesShown() {
        interactor.trackEvent(event: Event.myTemplatesSectionViewed(count: myIngredientsVisible.count))
    }
    
    func favouriteIngredientsShown() {
        interactor.trackEvent(event: Event.favouritesSectionViewed(count: favouriteIngredients.count))
    }
    
    func bookmarkedIngredientsShown() {
        interactor.trackEvent(event: Event.bookmarkedSectionViewed(count: bookmarkedOnlyIngredients.count))
    }
    
    func trendingSectionShown() {
        interactor.trackEvent(event: Event.trendingSectionViewed(count: visibleIngredientTemplates.count))
    }
    
    func emptyStateShown() {
        interactor.trackEvent(event: Event.emptyStateShown)
    }
    
    func onAddIngredientPressed() {
        interactor.trackEvent(event: Event.onAddIngredientPressed)
    }

    func onIngredientPressed(ingredient: IngredientTemplateModel) {
        Task {
            interactor.trackEvent(event: Event.incrementIngredientStart)
            do {
                try await interactor.incrementIngredientTemplateInteraction(id: ingredient.id)
                interactor.trackEvent(event: Event.incrementIngredientSuccess)
            } catch {
                interactor.trackEvent(event: Event.incrementIngredientFail(error: error))
            }
        }
        router.showIngredientDetailView(delegate: IngredientDetailDelegate(ingredientTemplate: ingredient))
    }
    
    func onIngredientPressedFromFavourites(ingredient: IngredientTemplateModel) {
        interactor.trackEvent(event: Event.onIngredientPressedFromFavourites)
        onIngredientPressed(ingredient: ingredient)
    }
    
    func onIngredientPressedFromBookmarked(ingredient: IngredientTemplateModel) {
        interactor.trackEvent(event: Event.onIngredientPressedFromBookmarked)
        onIngredientPressed(ingredient: ingredient)
    }
    
    func onIngredientPressedFromTrending(ingredient: IngredientTemplateModel) {
        interactor.trackEvent(event: Event.onIngredientPressedFromTrending)
        onIngredientPressed(ingredient: ingredient)
    }
    
    func onIngredientPressedFromMyTemplates(ingredient: IngredientTemplateModel) {
        interactor.trackEvent(event: Event.onIngredientPressedFromMyTemplates)
        onIngredientPressed(ingredient: ingredient)
    }

    func performIngredientSearch(for query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Cancel any ongoing search
        searchIngredientTask?.cancel()
        
        guard !trimmed.isEmpty else {
            handleSearchCleared()
            return
        }
        
        startFreshSearch(for: trimmed)
    }
    
    func handleSearchCleared() {
        interactor.trackEvent(event: Event.searchCleared)
        Task { await loadTopIngredientsIfNeeded() }
    }
    
    func startFreshSearch(for query: String) {
        isLoading = true
        interactor.trackEvent(event: Event.performIngredientSearchStart)
        
        searchIngredientTask = Task {
            do {
                // Debounce the search
                try await Task.sleep(for: .milliseconds(350))
                guard !Task.isCancelled else { return }
                
                // Perform the actual search
                let results = try await interactor.getIngredientTemplatesByName(name: query)
                
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
    
    func handleSearchResults(_ results: [IngredientTemplateModel], for query: String) {
        ingredients = results
        isLoading = false
        
        if results.isEmpty {
            interactor.trackEvent(event: Event.performIngredientSearchEmptyResults(query: query))
        } else {
            interactor.trackEvent(event: Event.performIngredientSearchSuccess(query: query, resultCount: results.count))
        }
    }
    
    func handleSearchError(_ error: Error) {
        interactor.trackEvent(event: Event.performIngredientSearchFail(error: error))
        isLoading = false
        ingredients = []
        router.showSimpleAlert(title: "No Ingredients Found", subtitle: "We couldn't find any ingredient templates matching your search. Please try a different name or check your connection.")
    }

    func loadMyIngredientsIfNeeded() async {
        guard let userId = currentUser?.userId else { return }
        interactor.trackEvent(event: Event.loadMyIngredientsStart)
        do {
            let mine = try await interactor.getIngredientTemplatesForAuthor(authorId: userId)
            myIngredients = mine
            interactor.trackEvent(event: Event.loadMyIngredientsSuccess(count: mine.count))
        } catch {
            interactor.trackEvent(event: Event.loadMyIngredientsFail(error: error))
            router.showSimpleAlert(title: "Unable to Load Your Ingredients", subtitle: "We couldn't retrieve your custom ingredient templates. Please check your connection or try again later.")
        }
    }

    func loadTopIngredientsIfNeeded() async {
        guard searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isLoading = true
        interactor.trackEvent(event: Event.loadTopIngredientsStart)
        do {
            let top = try await interactor.getTopIngredientTemplatesByClicks(limitTo: 10)
            ingredients = top
            isLoading = false
            interactor.trackEvent(event: Event.loadTopIngredientsSuccess(count: top.count))
        } catch {
            isLoading = false
            interactor.trackEvent(event: Event.loadTopIngredientsFail(error: error))
            router.showSimpleAlert(title: "Unable to Load Trending Ingredients", subtitle: "We couldn't load top ingredients. Please try again later.")
        }
    }

    func syncSavedIngredientsFromUser() async {
        interactor.trackEvent(event: Event.syncIngredientsFromCurrentUserStart)
        guard let user = currentUser else {
            interactor.trackEvent(event: Event.syncIngredientsFromCurrentUserNoUid)
            favouriteIngredients = []
            bookmarkedIngredients = []
            return
        }
        let bookmarkedIds = user.bookmarkedIngredientTemplateIds ?? []
        let favouritedIds = user.favouritedIngredientTemplateIds ?? []
        if bookmarkedIds.isEmpty && favouritedIds.isEmpty {
            favouriteIngredients = []
            bookmarkedIngredients = []
            return
        }
        do {
            var favs: [IngredientTemplateModel] = []
            var bookmarks: [IngredientTemplateModel] = []
            if !favouritedIds.isEmpty {
                favs = try await interactor.getIngredientTemplates(ids: favouritedIds, limitTo: favouritedIds.count)
            }
            if !bookmarkedIds.isEmpty {
                bookmarks = try await interactor.getIngredientTemplates(ids: bookmarkedIds, limitTo: bookmarkedIds.count)
            }
            favouriteIngredients = favs
            bookmarkedIngredients = bookmarks
            interactor.trackEvent(event: Event.syncIngredientsFromCurrentUserSuccess(favouriteCount: favs.count, bookmarkedCount: bookmarks.count))
        } catch {
            interactor.trackEvent(event: Event.syncIngredientsFromCurrentUserFail(error: error))
            router.showSimpleAlert(title: "Unable to Load Saved Ingredients", subtitle: "We couldn't retrieve your saved ingredient templates. Please try again later.")
        }
    }

    // MARK: Analytics Events
    
    enum Event: LoggableEvent {
        case performIngredientSearchStart
        case performIngredientSearchSuccess(query: String, resultCount: Int)
        case performIngredientSearchFail(error: Error)
        case performIngredientSearchEmptyResults(query: String)
        case searchCleared
        case loadMyIngredientsStart
        case loadMyIngredientsSuccess(count: Int)
        case loadMyIngredientsFail(error: Error)
        case loadTopIngredientsStart
        case loadTopIngredientsSuccess(count: Int)
        case loadTopIngredientsFail(error: Error)
        case incrementIngredientStart
        case incrementIngredientSuccess
        case incrementIngredientFail(error: Error)
        case syncIngredientsFromCurrentUserStart
        case syncIngredientsFromCurrentUserNoUid
        case syncIngredientsFromCurrentUserSuccess(favouriteCount: Int, bookmarkedCount: Int)
        case syncIngredientsFromCurrentUserFail(error: Error)
        case onAddIngredientPressed
        case favouritesSectionViewed(count: Int)
        case bookmarkedSectionViewed(count: Int)
        case trendingSectionViewed(count: Int)
        case myTemplatesSectionViewed(count: Int)
        case emptyStateShown
        case onIngredientPressedFromFavourites
        case onIngredientPressedFromBookmarked
        case onIngredientPressedFromTrending
        case onIngredientPressedFromMyTemplates

        var eventName: String {
            switch self {
            case .performIngredientSearchStart:          return "IngredientsView_Search_Start"
            case .performIngredientSearchSuccess:        return "IngredientsView_Search_Success"
            case .performIngredientSearchFail:           return "IngredientsView_Search_Fail"
            case .performIngredientSearchEmptyResults:   return "IngredientsView_Search_EmptyResults"
            case .searchCleared:                         return "IngredientsView_Search_Cleared"
            case .loadMyIngredientsStart:                return "IngredientsView_LoadMyIngredients_Start"
            case .loadMyIngredientsSuccess:              return "IngredientsView_LoadMyIngredients_Success"
            case .loadMyIngredientsFail:                 return "IngredientsView_LoadMyIngredients_Fail"
            case .loadTopIngredientsStart:               return "IngredientsView_LoadTopIngredients_Start"
            case .loadTopIngredientsSuccess:             return "IngredientsView_LoadTopIngredients_Success"
            case .loadTopIngredientsFail:                return "IngredientsView_LoadTopIngredients_Fail"
            case .incrementIngredientStart:              return "IngredientsView_IncrementIngredient_Start"
            case .incrementIngredientSuccess:            return "IngredientsView_IncrementIngredient_Success"
            case .incrementIngredientFail:               return "IngredientsView_IncrementIngredient_Fail"
            case .syncIngredientsFromCurrentUserStart:   return "IngredientsView_UserSync_Start"
            case .syncIngredientsFromCurrentUserNoUid:   return "IngredientsView_UserSync_NoUID"
            case .syncIngredientsFromCurrentUserSuccess: return "IngredientsView_UserSync_Success"
            case .syncIngredientsFromCurrentUserFail:    return "IngredientsView_UserSync_Fail"
            case .onAddIngredientPressed:                return "IngredientsView_AddIngredientPressed"
            case .favouritesSectionViewed:               return "IngredientsView_Favourites_SectionViewed"
            case .bookmarkedSectionViewed:               return "IngredientsView_Bookmarked_SectionViewed"
            case .trendingSectionViewed:                 return "IngredientsView_Trending_SectionViewed"
            case .myTemplatesSectionViewed:              return "IngredientsView_MyTemplates_SectionViewed"
            case .emptyStateShown:                       return "IngredientsView_EmptyState_Shown"
            case .onIngredientPressedFromFavourites:     return "IngredientsView_IngredientPressed_Favourites"
            case .onIngredientPressedFromBookmarked:     return "IngredientsView_IngredientPressed_Bookmarked"
            case .onIngredientPressedFromTrending:       return "IngredientsView_IngredientPressed_Trending"
            case .onIngredientPressedFromMyTemplates:    return "IngredientsView_IngredientPressed_MyTemplates"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .performIngredientSearchSuccess(query: let query, resultCount: let count):
                return ["query": query, "resultCount": count]
            case .performIngredientSearchEmptyResults(query: let query):
                return ["query": query]
            case .loadMyIngredientsSuccess(count: let count):
                return ["count": count]
            case .loadTopIngredientsSuccess(count: let count):
                return ["count": count]
            case .syncIngredientsFromCurrentUserSuccess(favouriteCount: let favCount, bookmarkedCount: let bookCount):
                return ["favouriteCount": favCount, "bookmarkedCount": bookCount]
            case .favouritesSectionViewed(count: let count):
                return ["count": count]
            case .bookmarkedSectionViewed(count: let count):
                return ["count": count]
            case .trendingSectionViewed(count: let count):
                return ["count": count]
            case .myTemplatesSectionViewed(count: let count):
                return ["count": count]
            case .loadMyIngredientsFail(error: let error), .loadTopIngredientsFail(error: let error), .performIngredientSearchFail(error: let error), .incrementIngredientFail(error: let error), .syncIngredientsFromCurrentUserFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .loadMyIngredientsFail, .loadTopIngredientsFail, .performIngredientSearchFail, .incrementIngredientFail, .syncIngredientsFromCurrentUserFail:
                return .severe
            case .syncIngredientsFromCurrentUserNoUid:
                return .warning
            default:
                return .analytic

            }
        }
    }
}
