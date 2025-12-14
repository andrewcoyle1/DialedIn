import SwiftUI

struct RecipeListBuilderView: View {
    
    @State var presenter: RecipeListBuilderPresenter
    
    let delegate: RecipeListBuilderDelegate
    
    var body: some View {
        List {
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
        .navigationTitle("Recipes")
        .navigationSubtitle("\(presenter.recipes.count) recipes")
        .scrollIndicators(.hidden)
        .onFirstTask {
            await presenter.loadAllRecipes()
        }
        .refreshable {
            await presenter.loadAllRecipes()
        }
        .onChange(of: presenter.currentUser) {
            Task {
                await presenter.syncSavedRecipesFromUser()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    presenter.onAddRecipePressed()
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(.glassProminent)
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
                    presenter.onRecipePressedFromFavourites(recipe: recipe, onRecipePressed: delegate.onRecipePressed)
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
                    presenter.onRecipePressedFromBookmarked(recipe: recipe, onRecipePressed: delegate.onRecipePressed)
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
                    presenter.onRecipePressedFromTrending(recipe: recipe, onRecipePressed: delegate.onRecipePressed)
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
                        presenter.onRecipePressedFromMyTemplates(recipe: recipe, onRecipePressed: delegate.onRecipePressed)
                    }
                    .removeListRowFormatting()
                }
            }
        } header: {
            Text("My Templates")
        }
        .onAppear {
            presenter.myTemplatesSectionViewed()
        }
    }

}

extension CoreBuilder {
    
    func recipeListBuilderView(router: Router, delegate: RecipeListBuilderDelegate) -> some View {
        RecipeListBuilderView(
            presenter: RecipeListBuilderPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showRecipeListBuilderView(delegate: RecipeListBuilderDelegate) {
        router.showScreen(.push) { router in
            builder.recipeListBuilderView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = RecipeListBuilderDelegate()
    
    return RouterView { router in
        builder.recipeListBuilderView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
