//
//  IngredientsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/10/2025.
//

import SwiftUI

struct IngredientsView: View {

    @Environment(UserManager.self) private var userManager
    @Environment(IngredientTemplateManager.self) private var ingredientTemplateManager
    @Environment(RecipeTemplateManager.self) private var recipeTemplateManager
    @Environment(LogManager.self) private var logManager

    @State private var isLoading: Bool = false
    @State private var searchText: String = ""
    @State private var showAlert: AnyAppAlert?

    @State private var searchIngredientTask: Task<Void, Never>?
    @State private var myIngredients: [IngredientTemplateModel] = []
    @State private var favouriteIngredients: [IngredientTemplateModel] = []
    @State private var bookmarkedIngredients: [IngredientTemplateModel] = []
    @State private var ingredients: [IngredientTemplateModel] = []

    @Binding var isShowingInspector: Bool
    @Binding var selectedIngredientTemplate: IngredientTemplateModel?
    @Binding var selectedRecipeTemplate: RecipeTemplateModel?
    @Binding var showCreateIngredient: Bool

    // MARK: Computed variables
    private var myIngredientIds: Set<String> {
        Set(myIngredients.map { $0.id })
    }

    private var favouriteIngredientIds: Set<String> {
        Set(favouriteIngredients.map { $0.id })
    }

    private var myIngredientsVisible: [IngredientTemplateModel] {
        myIngredients.filter { !favouriteIngredientIds.contains($0.id) }
    }

    private var bookmarkedOnlyIngredients: [IngredientTemplateModel] {
        bookmarkedIngredients.filter { !favouriteIngredientIds.contains($0.id) && !myIngredientIds.contains($0.id) }
    }

    private var savedIngredientIds: Set<String> {
        favouriteIngredientIds.union(Set(bookmarkedOnlyIngredients.map { $0.id }))
    }

    private var trendingIngredientsDeduped: [IngredientTemplateModel] {
        ingredients.filter { !myIngredientIds.contains($0.id) && !savedIngredientIds.contains($0.id) }
    }

    private var visibleIngredientTemplates: [IngredientTemplateModel] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? trendingIngredientsDeduped : ingredients
    }

    var body: some View {
        Group {
            if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

                if !favouriteIngredients.isEmpty {
                    favouriteIngredientTemplatesSection
                }

                myIngredientSection

                if !bookmarkedOnlyIngredients.isEmpty {
                    bookmarkedIngredientTemplatesSection
                }

                if !trendingIngredientsDeduped.isEmpty {
                    ingredientTemplateSection
                }
            } else {
                // Show search results when there is a query
                ingredientTemplateSection
            }
        }
        .screenAppearAnalytics(name: "IngredientsView")
        .task {
            await loadMyIngredientsIfNeeded()
            await loadTopIngredientsIfNeeded()
            await syncSavedIngredientsFromUser()
        }
        .onChange(of: userManager.currentUser) {
            Task {
                await syncSavedIngredientsFromUser()
            }
        }
    }

    // MARK: UI Components
    private var favouriteIngredientTemplatesSection: some View {
        Section {
            ForEach(favouriteIngredients) { ingredient in
                CustomListCellView(
                    imageName: ingredient.imageURL,
                    title: ingredient.name,
                    subtitle: ingredient.description
                )
                .anyButton(.highlight) {
                    onIngredientPressedFromFavourites(ingredient: ingredient)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Favourites")
        }
        .onAppear {
            logManager.trackEvent(event: Event.favouritesSectionViewed(count: favouriteIngredients.count))
        }
    }

    private var bookmarkedIngredientTemplatesSection: some View {
        Section {
            ForEach(bookmarkedOnlyIngredients) { ingredient in
                CustomListCellView(
                    imageName: ingredient.imageURL,
                    title: ingredient.name,
                    subtitle: ingredient.description
                )
                .anyButton(.highlight) {
                    onIngredientPressedFromBookmarked(ingredient: ingredient)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Bookmarked")
        }
        .onAppear {
            logManager.trackEvent(event: Event.bookmarkedSectionViewed(count: bookmarkedOnlyIngredients.count))
        }
    }

    private var ingredientTemplateSection: some View {
        Section {
            if isLoading {
                HStack {
                    ProgressView()
                    Text("Loading...")
                }
                .foregroundStyle(Color.secondary)
                .removeListRowFormatting()
            }
            ForEach(visibleIngredientTemplates) { ingredient in
                CustomListCellView(
                    imageName: ingredient.imageURL,
                    title: ingredient.name,
                    subtitle: ingredient.description
                )
                .anyButton(.highlight) {
                    onIngredientPressedFromTrending(ingredient: ingredient)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text(searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Trending Templates" : "Search Results")
        }
        .onAppear {
            logManager.trackEvent(event: Event.trendingSectionViewed(count: visibleIngredientTemplates.count))
        }
    }

    private var myIngredientSection: some View {
        Section {
            if myIngredientsVisible.isEmpty {
                HStack {
                    Image(systemName: "tray")
                        .foregroundColor(.secondary)
                    Text("No ingredient templates yet. Tap + to create your first one!")
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
                ForEach(myIngredientsVisible) { ingredient in
                    CustomListCellView(
                        imageName: ingredient.imageURL,
                        title: ingredient.name,
                        subtitle: ingredient.description
                    )
                    .anyButton(.highlight) {
                        onIngredientPressedFromMyTemplates(ingredient: ingredient)
                    }
                    .removeListRowFormatting()
                }
            }
        } header: {
            HStack {
                Text("My Templates")
                Spacer()
                Button {
                    onAddIngredientPressed()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                }
            }
        }
        .onAppear {
            logManager.trackEvent(event: Event.myTemplatesSectionViewed(count: myIngredientsVisible.count))
        }
    }

    // MARK: Business logic

    private func onAddIngredientPressed() {
        logManager.trackEvent(event: Event.onAddIngredientPressed)
        showCreateIngredient = true
    }

    private func onIngredientPressed(ingredient: IngredientTemplateModel) {
        Task {
            logManager.trackEvent(event: Event.incrementIngredientStart)
            do {
                try await ingredientTemplateManager.incrementIngredientTemplateInteraction(id: ingredient.id)
                logManager.trackEvent(event: Event.incrementIngredientSuccess)
            } catch {
                logManager.trackEvent(event: Event.incrementIngredientFail(error: error))
            }
        }
        selectedRecipeTemplate = nil
        selectedIngredientTemplate = ingredient
        isShowingInspector = true
    }
    
    private func onIngredientPressedFromFavourites(ingredient: IngredientTemplateModel) {
        logManager.trackEvent(event: Event.onIngredientPressedFromFavourites)
        onIngredientPressed(ingredient: ingredient)
    }
    
    private func onIngredientPressedFromBookmarked(ingredient: IngredientTemplateModel) {
        logManager.trackEvent(event: Event.onIngredientPressedFromBookmarked)
        onIngredientPressed(ingredient: ingredient)
    }
    
    private func onIngredientPressedFromTrending(ingredient: IngredientTemplateModel) {
        logManager.trackEvent(event: Event.onIngredientPressedFromTrending)
        onIngredientPressed(ingredient: ingredient)
    }
    
    private func onIngredientPressedFromMyTemplates(ingredient: IngredientTemplateModel) {
        logManager.trackEvent(event: Event.onIngredientPressedFromMyTemplates)
        onIngredientPressed(ingredient: ingredient)
    }

    private func performIngredientSearch(for query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Cancel any ongoing search
        searchIngredientTask?.cancel()
        
        guard !trimmed.isEmpty else {
            handleSearchCleared()
            return
        }
        
        startFreshSearch(for: trimmed)
    }
    
    private func handleSearchCleared() {
        logManager.trackEvent(event: Event.searchCleared)
        Task { await loadTopIngredientsIfNeeded() }
    }
    
    private func startFreshSearch(for query: String) {
        isLoading = true
        logManager.trackEvent(event: Event.performIngredientSearchStart)
        
        searchIngredientTask = Task { [ingredientTemplateManager] in
            do {
                // Debounce the search
                try await Task.sleep(for: .milliseconds(350))
                guard !Task.isCancelled else { return }
                
                // Perform the actual search
                let results = try await ingredientTemplateManager.getIngredientTemplatesByName(name: query)
                
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
    
    private func handleSearchResults(_ results: [IngredientTemplateModel], for query: String) {
        ingredients = results
        isLoading = false
        
        if results.isEmpty {
            logManager.trackEvent(event: Event.performIngredientSearchEmptyResults(query: query))
        } else {
            logManager.trackEvent(event: Event.performIngredientSearchSuccess(query: query, resultCount: results.count))
        }
    }
    
    private func handleSearchError(_ error: Error) {
        logManager.trackEvent(event: Event.performIngredientSearchFail(error: error))
        isLoading = false
        ingredients = []
        
        showAlert = AnyAppAlert(
            title: "No Ingredients Found",
            subtitle: "We couldn't find any ingredient templates matching your search. Please try a different name or check your connection."
        )
    }

    private func loadMyIngredientsIfNeeded() async {
        guard let userId = userManager.currentUser?.userId else { return }
        logManager.trackEvent(event: Event.loadMyIngredientsStart)
        do {
            let mine = try await ingredientTemplateManager.getIngredientTemplatesForAuthor(authorId: userId)
            myIngredients = mine
            logManager.trackEvent(event: Event.loadMyIngredientsSuccess(count: mine.count))
        } catch {
            logManager.trackEvent(event: Event.loadMyIngredientsFail(error: error))
            showAlert = AnyAppAlert(
                title: "Unable to Load Your Ingredients",
                subtitle: "We couldn't retrieve your custom ingredient templates. Please check your connection or try again later."
            )
        }
    }

    private func loadTopIngredientsIfNeeded() async {
        guard searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isLoading = true
        logManager.trackEvent(event: Event.loadTopIngredientsStart)
        do {
            let top = try await ingredientTemplateManager.getTopIngredientTemplatesByClicks(limitTo: 10)
            ingredients = top
            isLoading = false
            logManager.trackEvent(event: Event.loadTopIngredientsSuccess(count: top.count))
        } catch {
            isLoading = false
            logManager.trackEvent(event: Event.loadTopIngredientsFail(error: error))
            showAlert = AnyAppAlert(
                title: "Unable to Load Trending Ingredients",
                subtitle: "We couldn't load top ingredients. Please try again later."
            )
        }
    }

    private func syncSavedIngredientsFromUser() async {
        logManager.trackEvent(event: Event.syncIngredientsFromCurrentUserStart)
        guard let user = userManager.currentUser else {
            logManager.trackEvent(event: Event.syncIngredientsFromCurrentUserNoUid)
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
                favs = try await ingredientTemplateManager.getIngredientTemplates(ids: favouritedIds, limitTo: favouritedIds.count)
            }
            if !bookmarkedIds.isEmpty {
                bookmarks = try await ingredientTemplateManager.getIngredientTemplates(ids: bookmarkedIds, limitTo: bookmarkedIds.count)
            }
            favouriteIngredients = favs
            bookmarkedIngredients = bookmarks
            logManager.trackEvent(event: Event.syncIngredientsFromCurrentUserSuccess(favouriteCount: favs.count, bookmarkedCount: bookmarks.count))
        } catch {
            logManager.trackEvent(event: Event.syncIngredientsFromCurrentUserFail(error: error))
            showAlert = AnyAppAlert(
                title: "Unable to Load Saved Ingredients",
                subtitle: "We couldn't retrieve your saved ingredient templates. Please try again later."
            )
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

#Preview("Ingredients View") {
    List {
        IngredientsView(
            isShowingInspector: Binding.constant(false),
            selectedIngredientTemplate: Binding.constant(nil),
            selectedRecipeTemplate: Binding.constant(nil),
            showCreateIngredient: Binding.constant(false)
        )
    }
    .previewEnvironment()
}
