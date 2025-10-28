//
//  IngredientsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/10/2025.
//

import SwiftUI

struct IngredientsView: View {
    @State var viewModel: IngredientsViewModel

    @Binding var isShowingInspector: Bool
    @Binding var selectedIngredientTemplate: IngredientTemplateModel?
    @Binding var selectedRecipeTemplate: RecipeTemplateModel?
    @Binding var showCreateIngredient: Bool
    
    var body: some View {
        Group {
            if viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

                if !viewModel.favouriteIngredients.isEmpty {
                    favouriteIngredientTemplatesSection
                }

                myIngredientSection

                if !viewModel.bookmarkedOnlyIngredients.isEmpty {
                    bookmarkedIngredientTemplatesSection
                }

                if !viewModel.trendingIngredientsDeduped.isEmpty {
                    ingredientTemplateSection
                }
            } else {
                // Show search results when there is a query
                ingredientTemplateSection
            }
        }
        .screenAppearAnalytics(name: "IngredientsView")
        .task {
            await viewModel.loadMyIngredientsIfNeeded()
            await viewModel.loadTopIngredientsIfNeeded()
            await viewModel.syncSavedIngredientsFromUser()
        }
        .onChange(of: viewModel.currentUser) {
            Task {
                await viewModel.syncSavedIngredientsFromUser()
            }
        }
    }

    // MARK: UI Components
    private var favouriteIngredientTemplatesSection: some View {
        Section {
            ForEach(viewModel.favouriteIngredients) { ingredient in
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
            viewModel.favouriteIngredientsShown()
        }
    }

    private var bookmarkedIngredientTemplatesSection: some View {
        Section {
            ForEach(viewModel.bookmarkedOnlyIngredients) { ingredient in
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
            viewModel.bookmarkedIngredientsShown()
        }
    }

    private var ingredientTemplateSection: some View {
        Section {
            if viewModel.isLoading {
                HStack {
                    ProgressView()
                    Text("Loading...")
                }
                .foregroundStyle(Color.secondary)
                .removeListRowFormatting()
            }
            ForEach(viewModel.visibleIngredientTemplates) { ingredient in
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
            Text(viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Trending Templates" : "Search Results")
        }
        .onAppear {
            viewModel.trendingSectionShown()
            
        }
    }

    private var myIngredientSection: some View {
        Section {
            if viewModel.myIngredientsVisible.isEmpty {
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
                    viewModel.emptyStateShown()
                }
            } else {
                ForEach(viewModel.myIngredientsVisible) { ingredient in
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
            viewModel.onMyTemplatesShown()
        }
    }
    
    // MARK: - Actions
    private func onIngredientPressedFromFavourites(ingredient: IngredientTemplateModel) {
        viewModel.onIngredientPressedFromFavourites(ingredient: ingredient)
        updateBindings(ingredient: ingredient)
    }
    
    private func onIngredientPressedFromBookmarked(ingredient: IngredientTemplateModel) {
        viewModel.onIngredientPressedFromBookmarked(ingredient: ingredient)
        updateBindings(ingredient: ingredient)
    }
    
    private func onIngredientPressedFromTrending(ingredient: IngredientTemplateModel) {
        viewModel.onIngredientPressedFromTrending(ingredient: ingredient)
        updateBindings(ingredient: ingredient)
    }
    
    private func onIngredientPressedFromMyTemplates(ingredient: IngredientTemplateModel) {
        viewModel.onIngredientPressedFromMyTemplates(ingredient: ingredient)
        updateBindings(ingredient: ingredient)
    }
    
    private func onAddIngredientPressed() {
        viewModel.onAddIngredientPressed()
        showCreateIngredient = true
    }
    
    private func updateBindings(ingredient: IngredientTemplateModel) {
        selectedRecipeTemplate = nil
        selectedIngredientTemplate = ingredient
        isShowingInspector = true
    }
}

#Preview("Ingredients View") {
    List {
        IngredientsView(
            viewModel: IngredientsViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                )
            ),
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
    }
    .previewEnvironment()
}
