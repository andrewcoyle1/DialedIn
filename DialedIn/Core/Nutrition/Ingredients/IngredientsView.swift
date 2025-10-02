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

    @State private var isLoading: Bool = false
    @State private var searchText: String = ""
    @State private var showAlert: AnyAppAlert?

    @State private var searchIngredientTask: Task<Void, Never>?
    @State private var myIngredients: [IngredientTemplateModel] = []
    @State private var favouriteIngredients: [IngredientTemplateModel] = []
    @State private var bookmarkedIngredients: [IngredientTemplateModel] = []
    @State private var ingredients: [IngredientTemplateModel] = []
    @State private var showAddIngredientModal: Bool = false

    @Binding var isShowingInspector: Bool
    @Binding var selectedIngredientTemplate: IngredientTemplateModel?
    @Binding var selectedRecipeTemplate: RecipeTemplateModel?

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
        .sheet(isPresented: $showAddIngredientModal) {
            CreateIngredientView()
        }
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

    private var favouriteIngredientTemplatesSection: some View {
        Section {
            ForEach(favouriteIngredients) { ingredient in
                CustomListCellView(
                    imageName: ingredient.imageURL,
                    title: ingredient.name,
                    subtitle: ingredient.description
                )
                .anyButton(.highlight) {
                    onIngredientPressed(ingredient: ingredient)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Favourites")
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
                    onIngredientPressed(ingredient: ingredient)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Bookmarked")
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
                    onIngredientPressed(ingredient: ingredient)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text(searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Trending Templates" : "Search Results")
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
            } else {
                ForEach(myIngredientsVisible) { ingredient in
                    CustomListCellView(
                        imageName: ingredient.imageURL,
                        title: ingredient.name,
                        subtitle: ingredient.description
                    )
                    .anyButton(.highlight) {
                        onIngredientPressed(ingredient: ingredient)
                    }
                    .removeListRowFormatting()
                }
            }
        } header: {
            HStack {
                Text("My Templates")
                Spacer()
                Button {
                    showAddIngredientModal = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                }
            }
        }
    }

    private func onIngredientPressed(ingredient: IngredientTemplateModel) {
        Task {
            try? await ingredientTemplateManager.incrementIngredientTemplateInteraction(id: ingredient.id)
        }
        selectedRecipeTemplate = nil
        selectedIngredientTemplate = ingredient
        isShowingInspector = true
    }

    private func performIngredientSearch(for query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        searchIngredientTask?.cancel()
        guard !trimmed.isEmpty else {
            // When clearing search, show top templates
            Task { await loadTopIngredientsIfNeeded() }
            isLoading = false
            return
        }
        isLoading = true
        let currentQuery = trimmed
        searchIngredientTask = Task { [ingredientTemplateManager] in
            try? await Task.sleep(for: .milliseconds(350))
            guard !Task.isCancelled else { return }
            do {
                let results = try await ingredientTemplateManager.getIngredientTemplatesByName(name: currentQuery)
                await MainActor.run {
                    ingredients = results
                    isLoading = false
                }
            } catch {
                showAlert = AnyAppAlert(
                    title: "No Ingredients Found",
                    subtitle: "We couldn't find any ingredient templates matching your search. Please try a different name or check your connection."
                )
                await MainActor.run {
                    isLoading = false
                    ingredients = []
                }
            }
        }
    }

    private func onAddIngredientPressed() {
        showAddIngredientModal = true
    }

    private func loadMyIngredientsIfNeeded() async {
        guard let userId = userManager.currentUser?.userId else { return }
        do {
            let mine = try await ingredientTemplateManager.getIngredientTemplatesForAuthor(authorId: userId)
            myIngredients = mine
        } catch {
            // TODO: Route to log manager once available here
            showAlert = AnyAppAlert(
                title: "Unable to Load Your Ingredients",
                subtitle: "We couldn't retrieve your custom ingredient templates. Please check your connection or try again later."
            )
        }
    }

    private func loadTopIngredientsIfNeeded() async {
        guard searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isLoading = true
        do {
            let top = try await ingredientTemplateManager.getTopIngredientTemplatesByClicks(limitTo: 10)
            ingredients = top
            isLoading = false
        } catch {
            isLoading = false
            // TODO: Route to log manager once available here
            showAlert = AnyAppAlert(
                title: "Unable to Load Trending Templates",
                subtitle: "We couldn't load top ingredient templates. Please try again later."
            )
        }
    }

    private func syncSavedIngredientsFromUser() async {
        guard let user = userManager.currentUser else {
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
        } catch {
            showAlert = AnyAppAlert(
                title: "Unable to Load Saved Ingredients",
                subtitle: "We couldn't retrieve your saved ingredient templates. Please try again later."
            )
        }
    }

}
