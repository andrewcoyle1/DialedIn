//
//  RecipesView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/10/2025.
//

import SwiftUI
import CustomRouting

struct RecipesView: View {

    @State var presenter: RecipesPresenter

    var delegate: RecipesDelegate
    
    var body: some View {
        Group {
            if presenter.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

                if !presenter.favouriteRecipes.isEmpty {
                    favouriteRecipeTemplatesSection
                }

                myRecipeSection

                if !presenter.bookmarkedOnlyRecipes.isEmpty {
                    bookmarkedRecipeTemplatesSection
                }

                if !presenter.trendingRecipesDeduped.isEmpty {
                    recipeTemplateSection
                }
            } else {
                // Show search results when there is a query
                recipeTemplateSection
            }
        }
        .screenAppearAnalytics(name: "RecipesView")
        .onFirstTask {
            await presenter.loadMyRecipesIfNeeded()
            await presenter.loadTopRecipesIfNeeded()
            await presenter.syncSavedRecipesFromUser()
        }
        .refreshable {
            await presenter.loadMyRecipesIfNeeded()
            await presenter.loadTopRecipesIfNeeded()
            await presenter.syncSavedRecipesFromUser()
        }
        .onChange(of: presenter.currentUser) {
            Task {
                await presenter.syncSavedRecipesFromUser()
            }
        }
    }

    // MARK: UI Components
    private var favouriteRecipeTemplatesSection: some View {
        Section {
            ForEach(presenter.favouriteRecipes) { recipe in
                CustomListCellView(
                    imageName: recipe.imageURL,
                    title: recipe.name,
                    subtitle: recipe.description
                )
                .anyButton(.highlight) {
                    presenter.onRecipePressed(recipe: recipe)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Favourites")
        }
        .onAppear {
            presenter.favouritesSectionViewed()
        }
    }

    private var bookmarkedRecipeTemplatesSection: some View {
        Section {
            ForEach(presenter.bookmarkedOnlyRecipes) { recipe in
                CustomListCellView(
                    imageName: recipe.imageURL,
                    title: recipe.name,
                    subtitle: recipe.description
                )
                .anyButton(.highlight) {
                    presenter.onRecipePressed(recipe: recipe)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Bookmarked")
        }
        .onAppear {
            presenter.bookmarksSectionViewed()
        }
    }

    private var recipeTemplateSection: some View {
        Section {
            if presenter.isLoading {
                HStack {
                    ProgressView()
                    Text("Loading...")
                }
                .foregroundStyle(Color.secondary)
                .removeListRowFormatting()
            }
            ForEach(presenter.visibleRecipeTemplates) { recipe in
                CustomListCellView(
                    imageName: recipe.imageURL,
                    title: recipe.name,
                    subtitle: recipe.description
                )
                .anyButton(.highlight) {
                    presenter.onRecipePressed(recipe: recipe)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text(presenter.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Trending Templates" : "Search Results")
        }
        .onAppear {
            presenter.trendingSectionViewed()
        }
    }

    private var myRecipeSection: some View {
        Section {
            if presenter.myRecipesVisible.isEmpty {
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
                    presenter.emptyStateShown()
                }
            } else {
                ForEach(presenter.myRecipesVisible) { recipe in
                    CustomListCellView(
                        imageName: recipe.imageURL,
                        title: recipe.name,
                        subtitle: recipe.description
                    )
                    .anyButton(.highlight) {
                        presenter.onRecipePressed(recipe: recipe)
                    }
                    .removeListRowFormatting()
                }
            }
        } header: {
            HStack {
                Text("My Templates")
                Spacer()
                Button {
                    presenter.onAddRecipePressed(showCreateRecipe: delegate.showCreateRecipe)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                }
            }
        }
        .onAppear {
            presenter.myTemplatesSectionViewed()
        }
    }
}

#Preview("Recipes View") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    let delegate = RecipesDelegate(
        showCreateRecipe: Binding.constant(
            false
        ),
        selectedIngredientTemplate: Binding.constant(
            nil
        ),
        selectedRecipeTemplate: Binding.constant(
            nil
        ),
        isShowingInspector: Binding.constant(
            false
        )
    )
    List {
        RouterView { router in
            builder.recipesView(router: router, delegate: delegate)
        }
    }
    .previewEnvironment()
}
