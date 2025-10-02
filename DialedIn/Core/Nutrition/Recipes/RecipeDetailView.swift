//
//  RecipeDetailView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/09/2025.
//

import SwiftUI

struct RecipeDetailView: View {
    @Environment(UserManager.self) private var userManager
    @Environment(RecipeTemplateManager.self) private var recipeTemplateManager
    @Environment(\.dismiss) private var dismiss
    
    let recipeTemplate: RecipeTemplateModel
    @State private var showStartSessionSheet: Bool = false
    
    @State private var isBookmarked: Bool = false
    @State private var isFavourited: Bool = false
    
    @State private var showAlert: AnyAppAlert?
    
    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif
    
    var body: some View {
        List {
            if let url = recipeTemplate.imageURL {
                imageSection(url: url)
            }

            Section(header: Text("Ingredients")) {
                ForEach(recipeTemplate.ingredients) { wrapper in
                    ingredientSection(wrapper: wrapper)
                }
            }
        }
        .navigationTitle(recipeTemplate.name)
        .navigationSubtitle(recipeTemplate.description ?? "")
        .navigationBarTitleDisplayMode(.large)
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
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        await onFavoritePressed()
                    }
                } label: {
                    Image(systemName: isFavourited ? "heart.fill" : "heart")
                }
            }
            // Hide bookmark button when the current user is the author
            if userManager.currentUser?.userId != nil && userManager.currentUser?.userId != recipeTemplate.authorId {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await onBookmarkPressed()
                        }
                    } label: {
                        Image(systemName: isBookmarked ? "book.closed.fill" : "book.closed")
                    }
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showStartSessionSheet = true
                } label: {
                    Label("Start", systemImage: "play.fill")
                }
                .buttonStyle(.glassProminent)
            }
            
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $showDebugView) {
            DevSettingsView()
        }
        #endif
        .onAppear { loadInitialState()}
        .onChange(of: userManager.currentUser) {_, _ in
            let user = userManager.currentUser
            let isAuthor = user?.userId == recipeTemplate.authorId
            isBookmarked = isAuthor || (user?.bookmarkedRecipeTemplateIds?.contains(recipeTemplate.id) ?? false) || (user?.createdRecipeTemplateIds?.contains(recipeTemplate.id) ?? false)
            isFavourited = user?.favouritedRecipeTemplateIds?.contains(recipeTemplate.id) ?? false
        }
        .sheet(isPresented: $showStartSessionSheet) {
            RecipeStartView(recipe: recipeTemplate)
        }
    }
    
    private func loadInitialState() {
        let user = userManager.currentUser
        // Always treat authored templates as bookmarked
        let isAuthor = user?.userId == recipeTemplate.authorId
        isBookmarked = isAuthor || (user?.bookmarkedRecipeTemplateIds?.contains(recipeTemplate.id) ?? false) || (user?.createdRecipeTemplateIds?.contains(recipeTemplate.id) ?? false)
        isFavourited = user?.favouritedRecipeTemplateIds?.contains(recipeTemplate.id) ?? false
    }
    
    private func imageSection(url: String) -> some View {
        Section {
            ImageLoaderView(urlString: url, resizingMode: .fill)
                .frame(maxWidth: .infinity, minHeight: 180)
        }
        .removeListRowFormatting()
    }
    
    private func ingredientSection(wrapper: RecipeIngredientModel) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(wrapper.ingredient.name)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(Int(wrapper.amount)) \(displayUnit(wrapper.unit))")
                    .foregroundStyle(.secondary)
            }
            if let notes = wrapper.ingredient.description, !notes.isEmpty {
                Text(notes)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func displayUnit(_ unit: IngredientAmountUnit) -> String {
        switch unit {
        case .grams: return "g"
        case .milliliters: return "ml"
        case .units: return "units"
        }
    }
    
    private func onBookmarkPressed() async {
        let newState = !isBookmarked
        do {
            // If unbookmarking and currently favourited, unfavourite first to enforce rule
            if !newState && isFavourited {
                try await recipeTemplateManager.favouriteRecipeTemplate(id: recipeTemplate.id, isFavourited: false)
                isFavourited = false
                // Remove from user's favourited list
                try await userManager.removeFavouritedRecipeTemplate(recipeId: recipeTemplate.id)
            }
            try await recipeTemplateManager.bookmarkRecipeTemplate(id: recipeTemplate.id, isBookmarked: newState)
            if newState {
                try await userManager.addBookmarkedRecipeTemplate(recipeId: recipeTemplate.id)
            } else {
                try await userManager.removeBookmarkedRecipeTemplate(recipeId: recipeTemplate.id)
            }
            isBookmarked = newState
        } catch {
            showAlert = AnyAppAlert(title: "Failed to update bookmark status", subtitle: "Please try again later")
        }
    }
    
    private func onFavoritePressed() async {
        let newState = !isFavourited
        do {
            // If favouriting and not bookmarked, bookmark first to enforce rule
            if newState && !isBookmarked {
                try await recipeTemplateManager.bookmarkRecipeTemplate(id: recipeTemplate.id, isBookmarked: true)
                try await userManager.addBookmarkedRecipeTemplate(recipeId: recipeTemplate.id)
                isBookmarked = true
            }
            try await recipeTemplateManager.favouriteRecipeTemplate(id: recipeTemplate.id, isFavourited: newState)
            if newState {
                try await userManager.addFavouritedRecipeTemplate(recipeId: recipeTemplate.id)
            } else {
                try await userManager.removeFavouritedRecipeTemplate(recipeId: recipeTemplate.id)
            }
            isFavourited = newState
        } catch {
            showAlert = AnyAppAlert(title: "Failed to update favourite status", subtitle: "Please try again later")
        }
    }
}

#Preview {
    NavigationStack {
        RecipeDetailView(recipeTemplate: RecipeTemplateModel.mock)
    }
    .previewEnvironment()
}
