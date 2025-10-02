//
//  RecipesView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/10/2025.
//

import SwiftUI

struct RecipesView: View {
    @Environment(UserManager.self) private var userManager
    @Environment(IngredientTemplateManager.self) private var ingredientTemplateManager
    @Environment(RecipeTemplateManager.self) private var recipeTemplateManager
    @Environment(LogManager.self) private var logManager

    @State private var isLoading: Bool = false
    @State private var searchText: String = ""
    @State private var showAlert: AnyAppAlert?

    @State private var searchRecipeTask: Task<Void, Never>?
    @State private var myRecipes: [RecipeTemplateModel] = []
    @State private var favouriteRecipes: [RecipeTemplateModel] = []
    @State private var bookmarkedRecipes: [RecipeTemplateModel] = []
    @State private var recipes: [RecipeTemplateModel] = []
    @State private var showAddRecipeModal: Bool = false

    @Binding var isShowingInspector: Bool
    @Binding var selectedIngredientTemplate: IngredientTemplateModel?
    @Binding var selectedRecipeTemplate: RecipeTemplateModel?

    // MARK: Computed variables

    private var myRecipeIds: Set<String> {
        Set(myRecipes.map { $0.id })
    }

    private var favouriteRecipeIds: Set<String> {
        Set(favouriteRecipes.map { $0.id })
    }

    private var myRecipesVisible: [RecipeTemplateModel] {
        myRecipes.filter { !favouriteRecipeIds.contains($0.id) }
    }

    private var bookmarkedOnlyRecipes: [RecipeTemplateModel] {
        bookmarkedRecipes.filter { !favouriteRecipeIds.contains($0.id) && !myRecipeIds.contains($0.id) }
    }

    private var savedRecipeIds: Set<String> {
        favouriteRecipeIds.union(Set(bookmarkedOnlyRecipes.map { $0.id }))
    }

    private var trendingRecipesDeduped: [RecipeTemplateModel] {
        recipes.filter { !myRecipeIds.contains($0.id) && !savedRecipeIds.contains($0.id) }
    }

    private var visibleRecipeTemplates: [RecipeTemplateModel] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? trendingRecipesDeduped : recipes
    }

    var body: some View {
        Group {
            if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

                if !favouriteRecipes.isEmpty {
                    favouriteRecipeTemplatesSection
                }

                myRecipeSection

                if !bookmarkedOnlyRecipes.isEmpty {
                    bookmarkedRecipeTemplatesSection
                }

                if !trendingRecipesDeduped.isEmpty {
                    recipeTemplateSection
                }
            } else {
                // Show search results when there is a query
                recipeTemplateSection
            }
        }
        .screenAppearAnalytics(name: "RecipesView")
        .sheet(isPresented: $showAddRecipeModal) {
            CreateRecipeView()
        }
        .task {
            await loadMyRecipesIfNeeded()
            await loadTopRecipesIfNeeded()
            await syncSavedRecipesFromUser()
        }
        .onChange(of: userManager.currentUser) {
            Task {
                await syncSavedRecipesFromUser()
            }
        }
    }

    // MARK: UI Components
    private var favouriteRecipeTemplatesSection: some View {
        Section {
            ForEach(favouriteRecipes) { recipe in
                CustomListCellView(
                    imageName: recipe.imageURL,
                    title: recipe.name,
                    subtitle: recipe.description
                )
                .anyButton(.highlight) {
                    onRecipePressed(recipe: recipe)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Favourites")
        }
        .onAppear {
            logManager.trackEvent(event: Event.favouritesSectionViewed(count: favouriteRecipes.count))
        }
    }

    private var bookmarkedRecipeTemplatesSection: some View {
        Section {
            ForEach(bookmarkedOnlyRecipes) { recipe in
                CustomListCellView(
                    imageName: recipe.imageURL,
                    title: recipe.name,
                    subtitle: recipe.description
                )
                .anyButton(.highlight) {
                    onRecipePressed(recipe: recipe)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Bookmarked")
        }
        .onAppear {
            logManager.trackEvent(event: Event.bookmarkedSectionViewed(count: bookmarkedOnlyRecipes.count))
        }
    }

    private var recipeTemplateSection: some View {
        Section {
            if isLoading {
                HStack {
                    ProgressView()
                    Text("Loading...")
                }
                .foregroundStyle(Color.secondary)
                .removeListRowFormatting()
            }
            ForEach(visibleRecipeTemplates) { recipe in
                CustomListCellView(
                    imageName: recipe.imageURL,
                    title: recipe.name,
                    subtitle: recipe.description
                )
                .anyButton(.highlight) {
                    onRecipePressed(recipe: recipe)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text(searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Trending Templates" : "Search Results")
        }
        .onAppear {
            logManager.trackEvent(event: Event.trendingSectionViewed(count: visibleRecipeTemplates.count))
        }
    }

    private var myRecipeSection: some View {
        Section {
            if myRecipesVisible.isEmpty {
                HStack {
                    Image(systemName: "tray")
                        .foregroundColor(.secondary)
                    Text("No recipe templates yet. Tap + to create your first one!")
                        .foregroundColor(.secondary)
                        .font(.callout)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 12)
                .removeListRowFormatting()
                .onAppear {
                    logManager.trackEvent(event: Event.emptyStateShown)
                }
            } else {
                ForEach(myRecipesVisible) { recipe in
                    CustomListCellView(
                        imageName: recipe.imageURL,
                        title: recipe.name,
                        subtitle: recipe.description
                    )
                    .anyButton(.highlight) {
                        onRecipePressed(recipe: recipe)
                    }
                    .removeListRowFormatting()
                }
            }
        } header: {
            HStack {
                Text("My Templates")
                Spacer()
                Button {
                    showAddRecipeModal = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                }
            }
        }
        .onAppear {
            logManager.trackEvent(event: Event.myTemplatesSectionViewed(count: myRecipesVisible.count))
        }
    }

    // MARK: Business Logic

    private func onAddRecipePressed() {
        logManager.trackEvent(event: Event.onAddRecipePressed)
        showAddRecipeModal = true
    }

    private func onRecipePressed(recipe: RecipeTemplateModel) {
        Task {
            logManager.trackEvent(event: Event.incrementRecipeStart)
            do {
                try await recipeTemplateManager.incrementRecipeTemplateInteraction(id: recipe.id)
                logManager.trackEvent(event: Event.incrementRecipeSuccess)
            } catch {
                logManager.trackEvent(event: Event.incrementRecipeFail(error: error))
            }
        }
        selectedIngredientTemplate = nil
        selectedRecipeTemplate = recipe
        isShowingInspector = true
    }

    private func onRecipePressedFromFavourites(recipe: RecipeTemplateModel) {
        logManager.trackEvent(event: Event.onRecipePressedFromFavourites)
        onRecipePressed(recipe: recipe)
    }

    private func onRecipePressedFromBookmarked(recipe: RecipeTemplateModel) {
        logManager.trackEvent(event: Event.onRecipePressedFromBookmarked)
        onRecipePressed(recipe: recipe)
    }

    private func onRecipePressedFromTrending(recipe: RecipeTemplateModel) {
        logManager.trackEvent(event: Event.onRecipePressedFromTrending)
        onRecipePressed(recipe: recipe)
    }

    private func onRecipePressedFromMyTemplates(recipe: RecipeTemplateModel) {
        logManager.trackEvent(event: Event.onRecipePressedFromMyTemplates)
        onRecipePressed(recipe: recipe)
    }

    private func performRecipeSearch(for query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)

        // Cancel any ongoing search
        searchRecipeTask?.cancel()

        guard !trimmed.isEmpty else {
            handleSearchCleared()
            return
        }

        startFreshSearch(for: trimmed)
    }

    private func handleSearchCleared() {
        logManager.trackEvent(event: Event.searchCleared)
        Task { await loadTopRecipesIfNeeded() }
    }

    private func startFreshSearch(for query: String) {
        isLoading = true
        logManager.trackEvent(event: Event.performRecipeSearchStart)

        searchRecipeTask = Task { [recipeTemplateManager] in
            do {
                // Debounce the search
                try? await Task.sleep(for: .milliseconds(350))
                guard !Task.isCancelled else { return }

                // Perform the actual search
                let results = try await recipeTemplateManager.getRecipeTemplatesByName(name: query)

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

    private func handleSearchResults(_ results: [RecipeTemplateModel], for query: String) {
        recipes = results
        isLoading = false

        if results.isEmpty {
            logManager.trackEvent(event: Event.performRecipeSearchEmptyResults(query: query))
        } else {
            logManager.trackEvent(event: Event.performRecipeSearchSuccess(query: query, resultCount: results.count))
        }
    }

    private func handleSearchError(_ error: Error) {
        logManager.trackEvent(event: Event.performRecipeSearchFail(error: error))
        isLoading = false
        recipes = []

        showAlert = AnyAppAlert(
            title: "No Recipes Found",
            subtitle: "We couldn't find any recipe templates matching your search. Please try a different name or check your connection."
        )
    }

    private func loadMyRecipesIfNeeded() async {
        guard let userId = userManager.currentUser?.userId else { return }
        logManager.trackEvent(event: Event.loadMyRecipesStart)
        do {
            let mine = try await recipeTemplateManager.getRecipeTemplatesForAuthor(authorId: userId)
            myRecipes = mine
            logManager.trackEvent(event: Event.loadMyRecipesSuccess(count: mine.count))
        } catch {
            logManager.trackEvent(event: Event.loadMyRecipesFail(error: error))
            showAlert = AnyAppAlert(
                title: "Unable to Load Your Recipes",
                subtitle: "We couldn't retrieve your custom recipe templates. Please check your connection or try again later."
            )
        }
    }

    private func loadTopRecipesIfNeeded() async {
        guard searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isLoading = true
        logManager.trackEvent(event: Event.loadTopRecipesStart)
        do {
            let top = try await recipeTemplateManager.getTopRecipeTemplatesByClicks(limitTo: 10)
            recipes = top
            isLoading = false
            logManager.trackEvent(event: Event.loadTopRecipesSuccess(count: top.count))
        } catch {
            isLoading = false
            logManager.trackEvent(event: Event.loadTopRecipesFail(error: error))
            showAlert = AnyAppAlert(
                title: "Unable to Load Trending Templates",
                subtitle: "We couldn't load top recipe templates. Please try again later."
            )
        }
    }

    private func syncSavedRecipesFromUser() async {
        logManager.trackEvent(event: Event.syncRecipesFromCurrentUserStart)
        guard let user = userManager.currentUser else {
            logManager.trackEvent(event: Event.syncRecipesFromCurrentUserNoUid)
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
                favs = try await recipeTemplateManager.getRecipeTemplates(ids: favouritedIds, limitTo: favouritedIds.count)
            }
            if !bookmarkedIds.isEmpty {
                bookmarks = try await recipeTemplateManager.getRecipeTemplates(ids: bookmarkedIds, limitTo: bookmarkedIds.count)
            }
            favouriteRecipes = favs
            bookmarkedRecipes = bookmarks
            logManager.trackEvent(event: Event.syncRecipesFromCurrentUserSuccess(favouriteCount: favs.count, bookmarkedCount: bookmarks.count))
        } catch {
            logManager.trackEvent(event: Event.syncRecipesFromCurrentUserFail(error: error))
            showAlert = AnyAppAlert(
                title: "Unable to Load Saved Recipes",
                subtitle: "We couldn't retrieve your saved recipes. Please try again later."
            )
        }
    }

    // MARK: Analytics Events

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

#Preview("Recipes View") {
    List {
        RecipesView(
            isShowingInspector: Binding.constant(false),
            selectedIngredientTemplate: Binding.constant(nil),
            selectedRecipeTemplate: Binding.constant(nil)
        )
    }
    .previewEnvironment()
}
