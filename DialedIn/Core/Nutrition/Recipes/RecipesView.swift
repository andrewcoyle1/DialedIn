//
//  RecipesView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/10/2025.
//

import SwiftUI

struct RecipesView: View {
    @State var viewModel: RecipesViewModel

    var body: some View {
        Group {
            if viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

                if !viewModel.favouriteRecipes.isEmpty {
                    favouriteRecipeTemplatesSection
                }

                myRecipeSection

                if !viewModel.bookmarkedOnlyRecipes.isEmpty {
                    bookmarkedRecipeTemplatesSection
                }

                if !viewModel.trendingRecipesDeduped.isEmpty {
                    recipeTemplateSection
                }
            } else {
                // Show search results when there is a query
                recipeTemplateSection
            }
        }
        .screenAppearAnalytics(name: "RecipesView")
        .onFirstTask {
            await viewModel.loadMyRecipesIfNeeded()
            await viewModel.loadTopRecipesIfNeeded()
            await viewModel.syncSavedRecipesFromUser()
        }
        .refreshable {
            await viewModel.loadMyRecipesIfNeeded()
            await viewModel.loadTopRecipesIfNeeded()
            await viewModel.syncSavedRecipesFromUser()
        }
        .onChange(of: viewModel.currentUser) {
            Task {
                await viewModel.syncSavedRecipesFromUser()
            }
        }
    }

    // MARK: UI Components
    private var favouriteRecipeTemplatesSection: some View {
        Section {
            ForEach(viewModel.favouriteRecipes) { recipe in
                CustomListCellView(
                    imageName: recipe.imageURL,
                    title: recipe.name,
                    subtitle: recipe.description
                )
                .anyButton(.highlight) {
                    viewModel.onRecipePressed(recipe: recipe)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Favourites")
        }
        .onAppear {
            viewModel.favouritesSectionViewed()
        }
    }

    private var bookmarkedRecipeTemplatesSection: some View {
        Section {
            ForEach(viewModel.bookmarkedOnlyRecipes) { recipe in
                CustomListCellView(
                    imageName: recipe.imageURL,
                    title: recipe.name,
                    subtitle: recipe.description
                )
                .anyButton(.highlight) {
                    viewModel.onRecipePressed(recipe: recipe)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Bookmarked")
        }
        .onAppear {
            viewModel.bookmarksSectionViewed()
        }
    }

    private var recipeTemplateSection: some View {
        Section {
            if viewModel.isLoading {
                HStack {
                    ProgressView()
                    Text("Loading...")
                }
                .foregroundStyle(Color.secondary)
                .removeListRowFormatting()
            }
            ForEach(viewModel.visibleRecipeTemplates) { recipe in
                CustomListCellView(
                    imageName: recipe.imageURL,
                    title: recipe.name,
                    subtitle: recipe.description
                )
                .anyButton(.highlight) {
                    viewModel.onRecipePressed(recipe: recipe)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text(viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Trending Templates" : "Search Results")
        }
        .onAppear {
            viewModel.trendingSectionViewed()
        }
    }

    private var myRecipeSection: some View {
        Section {
            if viewModel.myRecipesVisible.isEmpty {
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
                    viewModel.emptyStateShown()
                }
            } else {
                ForEach(viewModel.myRecipesVisible) { recipe in
                    CustomListCellView(
                        imageName: recipe.imageURL,
                        title: recipe.name,
                        subtitle: recipe.description
                    )
                    .anyButton(.highlight) {
                        viewModel.onRecipePressed(recipe: recipe)
                    }
                    .removeListRowFormatting()
                }
            }
        } header: {
            HStack {
                Text("My Templates")
                Spacer()
                Button {
                    viewModel.onAddRecipePressed()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                }
            }
        }
        .onAppear {
            viewModel.myTemplatesSectionViewed()
        }
    }
}

#Preview("Recipes View") {
    List {
        RecipesView(
            viewModel: RecipesViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                ),
                showCreateRecipe: Binding.constant(false),
                selectedIngredientTemplate: Binding.constant(nil),
                selectedRecipeTemplate: Binding.constant(nil),
                isShowingInspector: Binding.constant(false)
            )
        )
    }
    .previewEnvironment()
}
