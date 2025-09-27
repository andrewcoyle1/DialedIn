//
//  IngredientDetailView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI

struct IngredientDetailView: View {
    
    @Environment(IngredientTemplateManager.self) private var ingredientTemplateManager
    @Environment(UserManager.self) private var userManager
    
    var ingredientTemplate: IngredientTemplateModel
    @State private var isBookmarked: Bool = false
    @State private var isFavourited: Bool = false
    
    @State private var showAlert: AnyAppAlert?
    
#if DEBUG || MOCK
    @State private var showDebugView: Bool = false
#endif
    
    var body: some View {
        List {
            aboutSection
        }
        .navigationTitle(ingredientTemplate.name)
        .navigationSubtitle(ingredientTemplate.description ?? "")
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
            if userManager.currentUser?.userId != nil && userManager.currentUser?.userId != ingredientTemplate.authorId {
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
        }
        .task { await loadInitialState() }
        .onChange(of: userManager.currentUser) { _, _ in
            let user = userManager.currentUser
            let isAuthor = user?.userId == ingredientTemplate.authorId
            isBookmarked = isAuthor || (user?.bookmarkedIngredientTemplateIds?.contains(ingredientTemplate.id) ?? false) || (user?.createdIngredientTemplateIds?.contains(ingredientTemplate.id) ?? false)
            isFavourited = user?.favouritedIngredientTemplateIds?.contains(ingredientTemplate.id) ?? false
        }
#if DEBUG || MOCK
        .sheet(isPresented: $showDebugView) {
            DevSettingsView()
        }
#endif
    }

    private func loadInitialState() async {
        let user = userManager.currentUser
        // Always treat authored templates as bookmarked
        let isAuthor = user?.userId == ingredientTemplate.authorId
        isBookmarked = isAuthor || (user?.bookmarkedIngredientTemplateIds?.contains(ingredientTemplate.id) ?? false) || (user?.createdIngredientTemplateIds?.contains(ingredientTemplate.id) ?? false)
        isFavourited = user?.favouritedIngredientTemplateIds?.contains(ingredientTemplate.id) ?? false
    }
    
    private func authorSection(id: String) -> some View {
        Section(header: Text("Author ID")) {
            Text(id)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
    
    private func onBookmarkPressed() async {
        let newState = !isBookmarked
        do {
            // If unbookmarking and currently favourited, unfavourite first to enforce rule
            if !newState && isFavourited {
                try await ingredientTemplateManager.favouriteIngredientTemplate(id: ingredientTemplate.id, isFavourited: false)
                isFavourited = false
                // Remove from user's favourited list
                try await userManager.removeFavouritedIngredientTemplate(ingredientId: ingredientTemplate.id)
            }
            try await ingredientTemplateManager.bookmarkIngredientTemplate(id: ingredientTemplate.id, isBookmarked: newState)
            if newState {
                try await userManager.addBookmarkedIngredientTemplate(ingredientId: ingredientTemplate.id)
            } else {
                try await userManager.removeBookmarkedIngredientTemplate(ingredientId: ingredientTemplate.id)
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
                try await ingredientTemplateManager.bookmarkIngredientTemplate(id: ingredientTemplate.id, isBookmarked: true)
                try await userManager.addBookmarkedIngredientTemplate(ingredientId: ingredientTemplate.id)
                isBookmarked = true
            }
            try await ingredientTemplateManager.favouriteIngredientTemplate(id: ingredientTemplate.id, isFavourited: newState)
            if newState {
                try await userManager.addFavouritedIngredientTemplate(ingredientId: ingredientTemplate.id)
            } else {
                try await userManager.removeFavouritedIngredientTemplate(ingredientId: ingredientTemplate.id)
            }
            isFavourited = newState
        } catch {
            showAlert = AnyAppAlert(title: "Failed to update favourite status", subtitle: "Please try again later")
        }
    }
}

#Preview {
    NavigationStack {
        IngredientDetailView(ingredientTemplate: IngredientTemplateModel.mocks[0])
    }
    .previewEnvironment()
}

extension IngredientDetailView {
    
    private var aboutSection: some View {
        Group {
            if let url = ingredientTemplate.imageURL {
                imageSection(url: url)
            }
            
            macroNutrientSection
            microNutrientSection
            
            dateCreatedSection
            if let authorId = ingredientTemplate.authorId {
                authorSection(id: authorId)
            }
        }
    }
         
    private func imageSection(url: String) -> some View {
        Section {
            ImageLoaderView(urlString: url, resizingMode: .fill)
                .frame(maxWidth: .infinity, minHeight: 180)
        }
        .removeListRowFormatting()
    }
    
    private func descriptionSection(description: String) -> some View {
        Section(header: Text("Description")) {
            Text(description)
                .font(.body)
        }
    }
    
    private var macroNutrientSection: some View {
        Section {
            HStack {
                Text("Calories")
                Spacer()
                Text(ingredientTemplate.calories?.formatted() ?? "-")
            }
            HStack {
                Text("Protein (g)")
                Spacer()
                Text(ingredientTemplate.protein?.formatted() ?? "-")
            }
            HStack {
                Text("Carbs (g)")
                Spacer()
                Text(ingredientTemplate.carbs?.formatted() ?? "-")
            }
            HStack {
                Text("Fat (g)")
                Spacer()
                Text(ingredientTemplate.fat?.formatted() ?? "-")
            }
            HStack {
                Text("Fiber (g)")
                Spacer()
                Text(ingredientTemplate.fiber?.formatted() ?? "-")
            }
            HStack {
                Text("Sugar (g)")
                Spacer()
                Text(ingredientTemplate.sugar?.formatted() ?? "-")
            }
        } header: {
            Text("Macronutrients")
        }
    }
    
    private var microNutrientSection: some View {
        Section {
            HStack {
                Text("Sodium (mg)")
                Spacer()
                Text(ingredientTemplate.sodiumMg?.formatted() ?? "-")
            }
            HStack {
                Text("Potassium (mg)")
                Spacer()
                Text(ingredientTemplate.potassiumMg?.formatted() ?? "-")
            }
        } header: {
            Text("Micronutrients")
        }
    }
    
    private var dateCreatedSection: some View {
        Section(header: Text("Date Created")) {
            Text(ingredientTemplate.dateCreated.formatted(date: .abbreviated, time: .omitted))
        }
    }
}
