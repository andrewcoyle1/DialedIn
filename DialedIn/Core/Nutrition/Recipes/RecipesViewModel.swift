//
//  RecipesViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import SwiftUI

protocol RecipesInteractor {
    var currentUser: UserModel? { get }
    func getRecipeTemplates(ids: [String], limitTo: Int) async throws -> [RecipeTemplateModel]
    func getRecipeTemplatesByName(name: String) async throws -> [RecipeTemplateModel]
    func getRecipeTemplatesForAuthor(authorId: String) async throws -> [RecipeTemplateModel]
    func incrementRecipeTemplateInteraction(id: String) async throws
    func getTopRecipeTemplatesByClicks(limitTo: Int) async throws -> [RecipeTemplateModel]
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: RecipesInteractor { }

@MainActor
protocol RecipesRouter {
    func showRecipeDetailView(delegate: RecipeDetailViewDelegate)
}

extension CoreRouter: RecipesRouter { }

@Observable
@MainActor
class RecipesViewModel {
    private let interactor: RecipesInteractor
    private let router: RecipesRouter

    private(set) var isLoading: Bool = false
    private(set) var searchText: String = ""
    private(set) var searchRecipeTask: Task<Void, Never>?
    private(set) var myRecipes: [RecipeTemplateModel] = []
    private(set) var favouriteRecipes: [RecipeTemplateModel] = []
    private(set) var bookmarkedRecipes: [RecipeTemplateModel] = []
    private(set) var recipes: [RecipeTemplateModel] = []

    var showAlert: AnyAppAlert?

    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    var myRecipeIds: Set<String> {
        Set(myRecipes.map { $0.id })
    }

    var favouriteRecipeIds: Set<String> {
        Set(favouriteRecipes.map { $0.id })
    }

    var myRecipesVisible: [RecipeTemplateModel] {
        myRecipes.filter { !favouriteRecipeIds.contains($0.id) }
    }

    var bookmarkedOnlyRecipes: [RecipeTemplateModel] {
        bookmarkedRecipes.filter { !favouriteRecipeIds.contains($0.id) && !myRecipeIds.contains($0.id) }
    }

    var savedRecipeIds: Set<String> {
        favouriteRecipeIds.union(Set(bookmarkedOnlyRecipes.map { $0.id }))
    }

    var trendingRecipesDeduped: [RecipeTemplateModel] {
        recipes.filter { !myRecipeIds.contains($0.id) && !savedRecipeIds.contains($0.id) }
    }

    var visibleRecipeTemplates: [RecipeTemplateModel] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? trendingRecipesDeduped : recipes
    }
    
    init(interactor: RecipesInteractor,
         router: RecipesRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func favouritesSectionViewed() {
        interactor.trackEvent(event: Event.favouritesSectionViewed(count: favouriteRecipes.count))
    }
    
    func bookmarksSectionViewed() {
        interactor.trackEvent(event: Event.bookmarkedSectionViewed(count: bookmarkedOnlyRecipes.count))
    }
    
    func myTemplatesSectionViewed() {
        interactor.trackEvent(event: Event.myTemplatesSectionViewed(count: myRecipesVisible.count))
    }
    
    func emptyStateShown() {
        interactor.trackEvent(event: Event.emptyStateShown)
    }
    
    func trendingSectionViewed() {
        interactor.trackEvent(event: Event.trendingSectionViewed(count: visibleRecipeTemplates.count))
    }
    
    func onAddRecipePressed(showCreateRecipe: Binding<Bool>) {
        interactor.trackEvent(event: Event.onAddRecipePressed)
        showCreateRecipe.wrappedValue = true
    }

    func onRecipePressed(recipe: RecipeTemplateModel) {
        Task {
            interactor.trackEvent(event: Event.incrementRecipeStart)
            do {
                try await interactor.incrementRecipeTemplateInteraction(id: recipe.id)
                interactor.trackEvent(event: Event.incrementRecipeSuccess)
            } catch {
                interactor.trackEvent(event: Event.incrementRecipeFail(error: error))
            }
        }
        router.showRecipeDetailView(delegate: RecipeDetailViewDelegate(recipeTemplate: recipe))
    }

    func onRecipePressedFromFavourites(recipe: RecipeTemplateModel, delegate: RecipesViewDelegate) {
        interactor.trackEvent(event: Event.onRecipePressedFromFavourites)
        onRecipePressed(recipe: recipe)
    }

    func onRecipePressedFromBookmarked(recipe: RecipeTemplateModel, delegate: RecipesViewDelegate) {
        interactor.trackEvent(event: Event.onRecipePressedFromBookmarked)
        onRecipePressed(recipe: recipe)
    }

    func onRecipePressedFromTrending(recipe: RecipeTemplateModel, delegate: RecipesViewDelegate) {
        interactor.trackEvent(event: Event.onRecipePressedFromTrending)
        onRecipePressed(recipe: recipe)
    }

    func onRecipePressedFromMyTemplates(recipe: RecipeTemplateModel, delegate: RecipesViewDelegate) {
        interactor.trackEvent(event: Event.onRecipePressedFromMyTemplates)
        onRecipePressed(recipe: recipe)
    }

    func performRecipeSearch(for query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)

        // Cancel any ongoing search
        searchRecipeTask?.cancel()

        guard !trimmed.isEmpty else {
            handleSearchCleared()
            return
        }

        startFreshSearch(for: trimmed)
    }

    func handleSearchCleared() {
        interactor.trackEvent(event: Event.searchCleared)
        Task { await loadTopRecipesIfNeeded() }
    }

    func startFreshSearch(for query: String) {
        isLoading = true
        interactor.trackEvent(event: Event.performRecipeSearchStart)

        searchRecipeTask = Task {
            do {
                // Debounce the search
                try? await Task.sleep(for: .milliseconds(350))
                guard !Task.isCancelled else { return }

                // Perform the actual search
                let results = try await interactor.getRecipeTemplatesByName(name: query)

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

    func handleSearchResults(_ results: [RecipeTemplateModel], for query: String) {
        recipes = results
        isLoading = false

        if results.isEmpty {
            interactor.trackEvent(event: Event.performRecipeSearchEmptyResults(query: query))
        } else {
            interactor.trackEvent(event: Event.performRecipeSearchSuccess(query: query, resultCount: results.count))
        }
    }

    func handleSearchError(_ error: Error) {
        interactor.trackEvent(event: Event.performRecipeSearchFail(error: error))
        isLoading = false
        recipes = []

        showAlert = AnyAppAlert(
            title: "No Recipes Found",
            subtitle: "We couldn't find any recipe templates matching your search. Please try a different name or check your connection."
        )
    }

    func loadMyRecipesIfNeeded() async {
        guard let userId = interactor.currentUser?.userId else { return }
        interactor.trackEvent(event: Event.loadMyRecipesStart)
        do {
            let mine = try await interactor.getRecipeTemplatesForAuthor(authorId: userId)
            myRecipes = mine
            interactor.trackEvent(event: Event.loadMyRecipesSuccess(count: mine.count))
        } catch {
            interactor.trackEvent(event: Event.loadMyRecipesFail(error: error))
            showAlert = AnyAppAlert(
                title: "Unable to Load Your Recipes",
                subtitle: "We couldn't retrieve your custom recipe templates. Please check your connection or try again later."
            )
        }
    }

    func loadTopRecipesIfNeeded() async {
        guard searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isLoading = true
        interactor.trackEvent(event: Event.loadTopRecipesStart)
        do {
            let top = try await interactor.getTopRecipeTemplatesByClicks(limitTo: 10)
            recipes = top
            isLoading = false
            interactor.trackEvent(event: Event.loadTopRecipesSuccess(count: top.count))
        } catch {
            isLoading = false
            interactor.trackEvent(event: Event.loadTopRecipesFail(error: error))
            showAlert = AnyAppAlert(
                title: "Unable to Load Trending Templates",
                subtitle: "We couldn't load top recipe templates. Please try again later."
            )
        }
    }

    func syncSavedRecipesFromUser() async {
        interactor.trackEvent(event: Event.syncRecipesFromCurrentUserStart)
        guard let user = interactor.currentUser else {
            interactor.trackEvent(event: Event.syncRecipesFromCurrentUserNoUid)
            favouriteRecipes = []
            bookmarkedRecipes = []
            return
        }
        let bookmarkedIds = user.bookmarkedRecipeTemplateIds ?? []
        let favouritedIds = user.favouritedRecipeTemplateIds ?? []
        if bookmarkedIds.isEmpty && favouritedIds.isEmpty {
            favouriteRecipes = []
            bookmarkedRecipes = []
            return
        }
        do {
            var favs: [RecipeTemplateModel] = []
            var bookmarks: [RecipeTemplateModel] = []
            if !favouritedIds.isEmpty {
                favs = try await interactor.getRecipeTemplates(ids: favouritedIds, limitTo: favouritedIds.count)
            }
            if !bookmarkedIds.isEmpty {
                bookmarks = try await interactor.getRecipeTemplates(ids: bookmarkedIds, limitTo: bookmarkedIds.count)
            }
            favouriteRecipes = favs
            bookmarkedRecipes = bookmarks
            interactor.trackEvent(event: Event.syncRecipesFromCurrentUserSuccess(favouriteCount: favs.count, bookmarkedCount: bookmarks.count))
        } catch {
            interactor.trackEvent(event: Event.syncRecipesFromCurrentUserFail(error: error))
            showAlert = AnyAppAlert(
                title: "Unable to Load Saved Recipes",
                subtitle: "We couldn't retrieve your saved recipes. Please try again later."
            )
        }
    }

    enum Event: LoggableEvent {
        case performRecipeSearchStart
        case performRecipeSearchSuccess(query: String, resultCount: Int)
        case performRecipeSearchFail(error: Error)
        case performRecipeSearchEmptyResults(query: String)
        case searchCleared
        case loadMyRecipesStart
        case loadMyRecipesSuccess(count: Int)
        case loadMyRecipesFail(error: Error)
        case loadTopRecipesStart
        case loadTopRecipesSuccess(count: Int)
        case loadTopRecipesFail(error: Error)
        case incrementRecipeStart
        case incrementRecipeSuccess
        case incrementRecipeFail(error: Error)
        case syncRecipesFromCurrentUserStart
        case syncRecipesFromCurrentUserNoUid
        case syncRecipesFromCurrentUserSuccess(favouriteCount: Int, bookmarkedCount: Int)
        case syncRecipesFromCurrentUserFail(error: Error)
        case onAddRecipePressed
        case favouritesSectionViewed(count: Int)
        case bookmarkedSectionViewed(count: Int)
        case trendingSectionViewed(count: Int)
        case myTemplatesSectionViewed(count: Int)
        case emptyStateShown
        case onRecipePressedFromFavourites
        case onRecipePressedFromBookmarked
        case onRecipePressedFromTrending
        case onRecipePressedFromMyTemplates

        var eventName: String {
            switch self {
            case .performRecipeSearchStart:          return "RecipesView_Search_Start"
            case .performRecipeSearchSuccess:        return "RecipesView_Search_Success"
            case .performRecipeSearchFail:           return "RecipesView_Search_Fail"
            case .performRecipeSearchEmptyResults:   return "RecipesView_Search_EmptyResults"
            case .searchCleared:                         return "RecipesView_Search_Cleared"
            case .loadMyRecipesStart:                return "RecipesView_LoadMyRecipes_Start"
            case .loadMyRecipesSuccess:              return "RecipesView_LoadMyRecipes_Success"
            case .loadMyRecipesFail:                 return "RecipesView_LoadMyRecipes_Fail"
            case .loadTopRecipesStart:               return "RecipesView_LoadTopRecipes_Start"
            case .loadTopRecipesSuccess:             return "RecipesView_LoadTopRecipes_Success"
            case .loadTopRecipesFail:                return "RecipesView_LoadTopRecipes_Fail"
            case .incrementRecipeStart:              return "RecipesView_IncrementRecipe_Start"
            case .incrementRecipeSuccess:            return "RecipesView_IncrementRecipe_Success"
            case .incrementRecipeFail:               return "RecipesView_IncrementRecipe_Fail"
            case .syncRecipesFromCurrentUserStart:   return "RecipesView_UserSync_Start"
            case .syncRecipesFromCurrentUserNoUid:   return "RecipesView_UserSync_NoUID"
            case .syncRecipesFromCurrentUserSuccess: return "RecipesView_UserSync_Success"
            case .syncRecipesFromCurrentUserFail:    return "RecipesView_UserSync_Fail"
            case .onAddRecipePressed:                return "RecipesView_AddRecipePressed"
            case .favouritesSectionViewed:               return "RecipesView_Favourites_SectionViewed"
            case .bookmarkedSectionViewed:               return "RecipesView_Bookmarked_SectionViewed"
            case .trendingSectionViewed:                 return "RecipesView_Trending_SectionViewed"
            case .myTemplatesSectionViewed:              return "RecipesView_MyTemplates_SectionViewed"
            case .emptyStateShown:                       return "RecipesView_EmptyState_Shown"
            case .onRecipePressedFromFavourites:     return "RecipesView_RecipePressed_Favourites"
            case .onRecipePressedFromBookmarked:     return "RecipesView_RecipePressed_Bookmarked"
            case .onRecipePressedFromTrending:       return "RecipesView_RecipePressed_Trending"
            case .onRecipePressedFromMyTemplates:    return "RecipesView_RecipePressed_MyTemplates"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .performRecipeSearchSuccess(query: let query, resultCount: let count):
                return ["query": query, "resultCount": count]
            case .performRecipeSearchEmptyResults(query: let query):
                return ["query": query]
            case .loadMyRecipesSuccess(count: let count):
                return ["count": count]
            case .loadTopRecipesSuccess(count: let count):
                return ["count": count]
            case .syncRecipesFromCurrentUserSuccess(favouriteCount: let favCount, bookmarkedCount: let bookCount):
                return ["favouriteCount": favCount, "bookmarkedCount": bookCount]
            case .favouritesSectionViewed(count: let count):
                return ["count": count]
            case .bookmarkedSectionViewed(count: let count):
                return ["count": count]
            case .trendingSectionViewed(count: let count):
                return ["count": count]
            case .myTemplatesSectionViewed(count: let count):
                return ["count": count]
            case .loadMyRecipesFail(error: let error), .loadTopRecipesFail(error: let error), .performRecipeSearchFail(error: let error), .incrementRecipeFail(error: let error), .syncRecipesFromCurrentUserFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .loadMyRecipesFail, .loadTopRecipesFail, .performRecipeSearchFail, .incrementRecipeFail, .syncRecipesFromCurrentUserFail:
                return .severe
            case .syncRecipesFromCurrentUserNoUid:
                return .warning
            default:
                return .analytic

            }
        }
    }
}
