import SwiftUI

struct IngredientListBuilderDelegate {
    var onIngredientPressed: ((IngredientTemplateModel) -> Void)?
}

struct IngredientListBuilderView: View {
    
    @State var presenter: IngredientListBuilderPresenter
    
    let delegate: IngredientListBuilderDelegate
    
    var body: some View {
        List {
            if presenter.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

                if !presenter.favouriteIngredients.isEmpty {
                    favouriteIngredientTemplatesSection
                }

                myIngredientSection

                if !presenter.bookmarkedOnlyIngredients.isEmpty {
                    bookmarkedIngredientTemplatesSection
                }

                if !presenter.trendingIngredientsDeduped.isEmpty {
                    ingredientTemplateSection
                }
            } else {
                // Show search results when there is a query
                ingredientTemplateSection
            }
        }
        .screenAppearAnalytics(name: "IngredientsView")
        .navigationTitle("Ingredients")
        .navigationSubtitle("\(presenter.ingredients.count) ingredients")
        .scrollIndicators(.hidden)
        .task {
            await presenter.loadAllIngredients()
        }
        .refreshable {
            await presenter.loadAllIngredients()
        }
        .onChange(of: presenter.currentUser) {
            Task {
                await presenter.syncSavedIngredientsFromUser()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    presenter.onAddIngredientPressed()
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(.glassProminent)
            }
        }
    }
    
    // MARK: UI Components
    private var favouriteIngredientTemplatesSection: some View {
        Section {
            ForEach(presenter.favouriteIngredients) { ingredient in
                CustomListCellView(
                    imageName: ingredient.imageURL,
                    title: ingredient.name,
                    subtitle: ingredient.description
                )
                .anyButton(.highlight) {
                    presenter.onIngredientPressedFromFavourites(ingredient: ingredient, onIngredientPressed: delegate.onIngredientPressed)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Favourites")
        }
        .onAppear {
            presenter.favouriteIngredientsShown()
        }
    }

    private var bookmarkedIngredientTemplatesSection: some View {
        Section {
            ForEach(presenter.bookmarkedOnlyIngredients) { ingredient in
                CustomListCellView(
                    imageName: ingredient.imageURL,
                    title: ingredient.name,
                    subtitle: ingredient.description
                )
                .anyButton(.highlight) {
                    presenter.onIngredientPressedFromBookmarked(ingredient: ingredient, onIngredientPressed: delegate.onIngredientPressed)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Bookmarked")
        }
        .onAppear {
            presenter.bookmarkedIngredientsShown()
        }
    }

    private var ingredientTemplateSection: some View {
        Section {
            if presenter.isLoading {
                HStack {
                    ProgressView()
                    Text("Loading...")
                }
                .foregroundStyle(Color.secondary)
                .removeListRowFormatting()
            }
            ForEach(presenter.visibleIngredientTemplates) { ingredient in
                CustomListCellView(
                    imageName: ingredient.imageURL,
                    title: ingredient.name,
                    subtitle: ingredient.description
                )
                .anyButton(.highlight) {
                    presenter.onIngredientPressedFromTrending(ingredient: ingredient, onIngredientPressed: delegate.onIngredientPressed)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text(presenter.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Trending Templates" : "Search Results")
        }
        .onAppear {
            presenter.trendingSectionShown()
            
        }
    }

    private var myIngredientSection: some View {
        Section {
            if presenter.myIngredientsVisible.isEmpty {
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
                    presenter.emptyStateShown()
                }
            } else {
                ForEach(presenter.myIngredientsVisible) { ingredient in
                    CustomListCellView(
                        imageName: ingredient.imageURL,
                        title: ingredient.name,
                        subtitle: ingredient.description
                    )
                    .anyButton(.highlight) {
                        presenter.onIngredientPressedFromMyTemplates(ingredient: ingredient, onIngredientPressed: delegate.onIngredientPressed)
                    }
                    .removeListRowFormatting()
                }
            }
        } header: {
            Text("My Templates")
        }
        .onAppear {
            presenter.onMyTemplatesShown()
        }
    }
}

extension CoreBuilder {
    
    func ingredientListBuilderView(router: Router, delegate: IngredientListBuilderDelegate) -> some View {
        IngredientListBuilderView(
            presenter: IngredientListBuilderPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showIngredientListBuilderView(delegate: IngredientListBuilderDelegate) {
        router.showScreen(.push) { router in
            builder.ingredientListBuilderView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = IngredientListBuilderDelegate()
    
    return RouterView { router in
        builder.ingredientListBuilderView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
