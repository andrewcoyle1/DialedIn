//
//  NutritionLibraryPickerView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct NutritionLibraryPickerDelegate {
    var onPick: (MealItemModel) -> Void
}

struct NutritionLibraryPickerView: View {

    @State var presenter: NutritionLibraryPickerPresenter

    var delegate: NutritionLibraryPickerDelegate

    var body: some View {
        List {
            Section {
                Picker("Type", selection: $presenter.mode) {
                    Text("Ingredients").tag(NutritionLibraryPickerPresenter.PickerMode.ingredients)
                    Text("Recipes").tag(NutritionLibraryPickerPresenter.PickerMode.recipes)
                }
                .pickerStyle(.segmented)
            }
            .listSectionSpacing(0)
            .removeListRowFormatting()
            
            if presenter.isLoading {
                Section {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                }
            } else {
                switch presenter.mode {
                case .ingredients:
                    ingredientsSection
                case .recipes:
                    recipesSection
                }
            }
        }
        .navigationTitle("Add Item")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $presenter.searchText)
        .onChange(of: presenter.searchText) { _, newValue in
            Task { await presenter.performSearch(query: newValue) }
        }
        .task {
            await presenter.loadInitial()
        }
        .toolbar {
            toolbarContent
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.dismissScreen()
            } label: {
                Image(systemName: "xmark")
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.dismissScreen()
            } label: {
                Image(systemName: "checkmark")
            }
            .buttonStyle(.glassProminent)
        }
    }
    
    private var ingredientsSection: some View {
        Section {
            if presenter.ingredients.isEmpty {
                Text(presenter.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "No ingredients to show yet" : "No results")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(presenter.ingredients) { ingredient in
                    Button {
                        presenter.navToIngredientAmount(ingredient, onPick: delegate.onPick)
                    } label: {
                        CustomListCellView(
                            imageName: ingredient.imageURL,
                            title: ingredient.name,
                            subtitle: ingredient.description
                        )
                    }
                }
                .removeListRowFormatting()
            }
        }
        
    }
    
    private var recipesSection: some View {
        Section {
            if presenter.recipes.isEmpty {
                Text(presenter.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "No recipes to show yet" : "No results")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(presenter.recipes) { recipe in
                    Button {
                        presenter.navToRecipeAmount(recipe, onPick: delegate.onPick)
                    } label: {
                        CustomListCellView(
                            imageName: nil,
                            title: recipe.name,
                            subtitle: recipe.description
                        )
                    }
                }
                .removeListRowFormatting()
            }
        }
    }
}

extension CoreBuilder {
    func nutritionLibraryPickerView(router: AnyRouter, delegate: NutritionLibraryPickerDelegate) -> some View {
        NutritionLibraryPickerView(
            presenter: NutritionLibraryPickerPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showNutritionLibraryPickerView(delegate: NutritionLibraryPickerDelegate) {
        router.showScreen(.sheet) { router in
            builder.nutritionLibraryPickerView(router: router, delegate: delegate)
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    let delegate = NutritionLibraryPickerDelegate(
        onPick: { item in
            print(item.displayName)
        }
    )
    RouterView { router in
        builder.nutritionLibraryPickerView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
