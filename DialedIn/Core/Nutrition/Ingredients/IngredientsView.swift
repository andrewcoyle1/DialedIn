//
//  IngredientsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct IngredientsView: View {
    @State var presenter: IngredientsPresenter

    var delegate: IngredientsDelegate

    var body: some View {
        Group {
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
        .task {
            await presenter.loadMyIngredientsIfNeeded()
            await presenter.loadTopIngredientsIfNeeded()
            await presenter.syncSavedIngredientsFromUser()
        }
        .onChange(of: presenter.currentUser) {
            Task {
                await presenter.syncSavedIngredientsFromUser()
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
                    onIngredientPressedFromFavourites(ingredient: ingredient)
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
                    onIngredientPressedFromBookmarked(ingredient: ingredient)
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
                    onIngredientPressedFromTrending(ingredient: ingredient)
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
            presenter.onMyTemplatesShown()
        }
    }
    
    // MARK: - Actions
    private func onIngredientPressedFromFavourites(ingredient: IngredientTemplateModel) {
        presenter.onIngredientPressedFromFavourites(ingredient: ingredient)
        updateBindings(ingredient: ingredient)
    }
    
    private func onIngredientPressedFromBookmarked(ingredient: IngredientTemplateModel) {
        presenter.onIngredientPressedFromBookmarked(ingredient: ingredient)
        updateBindings(ingredient: ingredient)
    }
    
    private func onIngredientPressedFromTrending(ingredient: IngredientTemplateModel) {
        presenter.onIngredientPressedFromTrending(ingredient: ingredient)
        updateBindings(ingredient: ingredient)
    }
    
    private func onIngredientPressedFromMyTemplates(ingredient: IngredientTemplateModel) {
        presenter.onIngredientPressedFromMyTemplates(ingredient: ingredient)
        updateBindings(ingredient: ingredient)
    }
    
    private func onAddIngredientPressed() {
        presenter.onAddIngredientPressed()
        delegate.showCreateIngredient.wrappedValue = true
    }
    
    private func updateBindings(ingredient: IngredientTemplateModel) {
        delegate.selectedRecipeTemplate.wrappedValue = nil
        delegate.selectedIngredientTemplate.wrappedValue = ingredient
        delegate.isShowingInspector.wrappedValue = true
    }
}

extension CoreBuilder {
    func ingredientsView(router: AnyRouter, delegate: IngredientsDelegate) -> some View {
        IngredientsView(
            presenter: IngredientsPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

#Preview("Ingredients View") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    List {
        RouterView { router in
            builder.ingredientsView(
                router: router, 
                delegate: IngredientsDelegate(
                    isShowingInspector: Binding.constant(
                        false
                    ),
                    selectedIngredientTemplate: Binding.constant(
                        nil
                    ),
                    selectedRecipeTemplate: Binding.constant(
                        nil
                    ),
                    showCreateIngredient: Binding.constant(
                        false
                    )
                )
            )
        }
    }
    .previewEnvironment()
}
