//
//  NutritionLibraryPickerView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/10/2025.
//

import SwiftUI
import CustomRouting

struct NutritionLibraryPickerViewDelegate {
    var onPick: (MealItemModel) -> Void
}

struct NutritionLibraryPickerView: View {

    @State var viewModel: NutritionLibraryPickerViewModel

    var delegate: NutritionLibraryPickerViewDelegate

    var body: some View {
        List {
            Section {
                Picker("Type", selection: $viewModel.mode) {
                    Text("Ingredients").tag(NutritionLibraryPickerViewModel.PickerMode.ingredients)
                    Text("Recipes").tag(NutritionLibraryPickerViewModel.PickerMode.recipes)
                }
                .pickerStyle(.segmented)
            }
            .listSectionSpacing(0)
            .removeListRowFormatting()
            
            if viewModel.isLoading {
                Section {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                }
            } else {
                switch viewModel.mode {
                case .ingredients:
                    ingredientsSection
                case .recipes:
                    recipesSection
                }
            }
        }
        .navigationTitle("Add Item")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $viewModel.searchText)
        .onChange(of: viewModel.searchText) { _, newValue in
            Task { await viewModel.performSearch(query: newValue) }
        }
        .task {
            await viewModel.loadInitial()
        }
        .toolbar {
            toolbarContent
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                viewModel.dismissScreen()
            } label: {
                Image(systemName: "xmark")
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.dismissScreen()
            } label: {
                Image(systemName: "checkmark")
            }
            .buttonStyle(.glassProminent)
        }
    }
    
    private var ingredientsSection: some View {
        Section {
            if viewModel.ingredients.isEmpty {
                Text(viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "No ingredients to show yet" : "No results")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.ingredients) { ingredient in
                    Button {
                        viewModel.navToIngredientAmount(ingredient, onPick: delegate.onPick)
                    } label: {
                        CustomListCellView(
                            imageName: ingredient.imageURL,
                            title: ingredient.name,
                            subtitle: ingredient.description
                        )
                        .removeListRowFormatting()
                    }
                }
            }
        }
    }
    
    private var recipesSection: some View {
        Section {
            if viewModel.recipes.isEmpty {
                Text(viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "No recipes to show yet" : "No results")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.recipes) { recipe in
                    Button {
                        viewModel.navToRecipeAmount(recipe, onPick: delegate.onPick)
                    } label: {
                        CustomListCellView(
                            imageName: nil,
                            title: recipe.name,
                            subtitle: recipe.description
                        )
                        .removeListRowFormatting()
                    }
                }
            }
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    let delegate = NutritionLibraryPickerViewDelegate(
        onPick: { item in
            print(
                item.displayName
            )
        }
    )
    RouterView { router in
        builder.nutritionLibraryPickerView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
