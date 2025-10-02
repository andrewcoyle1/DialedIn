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
    }

    private func onRecipePressed(recipe: RecipeTemplateModel) {
        selectedIngredientTemplate = nil
        selectedRecipeTemplate = recipe
        isShowingInspector = true
    }

    private func performRecipeSearch(for query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        searchRecipeTask?.cancel()
        guard !trimmed.isEmpty else {
            // When clearing search, show top templates
            Task { await loadTopRecipesIfNeeded() }
            isLoading = false
            return
        }
        isLoading = true
        let currentQuery = trimmed
        searchRecipeTask = Task { [recipeTemplateManager] in
            try? await Task.sleep(for: .milliseconds(350))
            guard !Task.isCancelled else { return }
            do {
                let results = try await recipeTemplateManager.getRecipeTemplatesByName(name: currentQuery)
                await MainActor.run {
                    recipes = results
                    isLoading = false
                }
            } catch {
                showAlert = AnyAppAlert(
                    title: "No Recipes Found",
                    subtitle: "We couldn't find any recipe templates matching your search. Please try a different name or check your connection."
                )
                await MainActor.run {
                    isLoading = false
                    recipes = []
                }
            }
        }
    }

    private func loadMyRecipesIfNeeded() async {
        guard let userId = userManager.currentUser?.userId else { return }
        do {
            let mine = try await recipeTemplateManager.getRecipeTemplatesForAuthor(authorId: userId)
            myRecipes = mine
        } catch {
            // TODO: Route to log manager once available here
            showAlert = AnyAppAlert(
                title: "Unable to Load Your Recipes",
                subtitle: "We couldn't retrieve your custom recipe templates. Please check your connection or try again later."
            )
        }
    }

    private func loadTopRecipesIfNeeded() async {
        guard searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isLoading = true
        do {
            let top = try await recipeTemplateManager.getTopRecipeTemplatesByClicks(limitTo: 10)
            recipes = top
            isLoading = false
        } catch {
            isLoading = false
            // TODO: Route to log manager once available here
            showAlert = AnyAppAlert(
                title: "Unable to Load Trending Templates",
                subtitle: "We couldn't load top recipe templates. Please try again later."
            )
        }
    }

    private func syncSavedRecipesFromUser() async {
        guard let user = userManager.currentUser else {
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
        } catch {
            showAlert = AnyAppAlert(
                title: "Unable to Load Saved Recipes",
                subtitle: "We couldn't retrieve your saved recipe templates. Please try again later."
            )
        }
    }
}

#Preview {
    List {
        RecipesView(
            isShowingInspector: Binding.constant(false),
            selectedIngredientTemplate: Binding.constant(nil),
            selectedRecipeTemplate: Binding.constant(nil)
        )
    }
    .previewEnvironment()
}
