//
//  NutritionView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 25/09/2025.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

struct NutritionView: View {
    
    @Environment(UserManager.self) private var userManager
    @Environment(IngredientTemplateManager.self) private var ingredientTemplateManager
    @Environment(RecipeTemplateManager.self) private var recipeTemplateManager

    @State private var presentationMode: NutritionPresentationMode = .recipes

    @State private var isLoading: Bool = false
    @State private var searchText: String = ""
    @State private var showAlert: AnyAppAlert?
    @State private var isShowingInspector: Bool = false
    
    @State private var searchIngredientTask: Task<Void, Never>?
    @State private var myIngredients: [IngredientTemplateModel] = []
    @State private var favouriteIngredients: [IngredientTemplateModel] = []
    @State private var bookmarkedIngredients: [IngredientTemplateModel] = []
    @State private var ingredients: [IngredientTemplateModel] = []
    @State private var showAddIngredientModal: Bool = false
    @State private var selectedIngredientTemplate: IngredientTemplateModel?

    @State private var searchRecipeTask: Task<Void, Never>?
    @State private var myRecipes: [RecipeTemplateModel] = []
    @State private var favouriteRecipes: [RecipeTemplateModel] = []
    @State private var bookmarkedRecipes: [RecipeTemplateModel] = []
    @State private var recipes: [RecipeTemplateModel] = []
    @State private var showAddRecipeModal: Bool = false
    @State private var selectedRecipeTemplate: RecipeTemplateModel?

    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif
    
    enum NutritionPresentationMode {
        case recipes
        case ingredients
    }
    
    var body: some View {
        NavigationStack {
            List {
                pickerSection
                switch presentationMode {
                case .recipes:
                    recipesSection
                case .ingredients:
                    ingredientsSection
                }
            }
            .navigationTitle("Nutrition")
            .navigationSubtitle(Date.now.formatted(date: .abbreviated, time: .omitted))
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .scrollIndicators(.hidden)
            .showCustomAlert(alert: $showAlert)
            .toolbar {
                #if DEBUG || MOCK
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showDebugView = true
                    } label: {
                        Image(systemName: "info")
                    }
                }
                #endif
                
                #if os(iOS)
                if UIDevice.current.userInterfaceIdiom != .phone {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isShowingInspector.toggle()
                        } label: {
                            Image(systemName: "info")
                        }
                    }
                }
                #else
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingInspector.toggle()
                    } label: {
                        Image(systemName: "info")
                    }
                }
                #endif
            }
            #if DEBUG || MOCK
            .sheet(isPresented: $showDebugView) {
                DevSettingsView()
            }
            #endif
            .sheet(isPresented: $showAddRecipeModal) {
                CreateRecipeView()
            }
            .sheet(isPresented: $showAddIngredientModal) {
                CreateIngredientView()
            }
            .task {
                await loadMyIngredientsIfNeeded()
                await loadTopIngredientsIfNeeded()
                await syncSavedIngredientsFromUser()
                
                await loadMyRecipesIfNeeded()
                await loadTopRecipesIfNeeded()
                await syncSavedRecipesFromUser()
            }
            .onChange(of: userManager.currentUser) {
                Task {
                    await syncSavedIngredientsFromUser()
                    await syncSavedRecipesFromUser()
                }
            }
        }
        .inspector(isPresented: $isShowingInspector) {
            Group {
                if let ingredient = selectedIngredientTemplate {
                    NavigationStack {
                        IngredientDetailView(ingredientTemplate: ingredient)
                    }
                } else if let recipe = selectedRecipeTemplate {
                    NavigationStack {
                        RecipeDetailView(recipeTemplate: recipe)
                    }
                } else {
                    Text("Select an item")
                        .foregroundStyle(.secondary)
                        .padding()
                }
            }
            .inspectorColumnWidth(min: 300, ideal: 400, max: 600)
        }
    }
}

#Preview {
    NutritionView()
        .previewEnvironment()
}

extension NutritionView {
    private var pickerSection: some View {
        Section {
            Picker("Section", selection: $presentationMode) {
                Text("Recipes").tag(NutritionPresentationMode.recipes)
                Text("Ingredients").tag(NutritionPresentationMode.ingredients)
            }
            .pickerStyle(.segmented)
        }
        .listSectionSpacing(0)
        .removeListRowFormatting()
    }
    
    private var recipesSection: some View {
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

extension NutritionView {
    
    private var ingredientsSection: some View {
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
