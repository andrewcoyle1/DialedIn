//
//  NutritionLibraryPickerView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/10/2025.
//

import SwiftUI

struct NutritionLibraryPickerView: View {
    @State var viewModel: NutritionLibraryPickerViewModel
    @Environment(DependencyContainer.self) private var container
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
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
            .showCustomAlert(alert: $viewModel.showAlert)
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                dismiss()
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
                    NavigationLink {
                        IngredientAmountView(viewModel: IngredientAmountViewModel(interactor: CoreInteractor(container: container), ingredient: ingredient) { item in
                            viewModel.onPick(item)
                        })
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
                    NavigationLink {
                        RecipeAmountView(
                            viewModel: RecipeAmountViewModel(
                                interactor: CoreInteractor(
                                    container: container
                                ),
                                recipe: recipe, onConfirm:
                             { item in
                            viewModel.onPick(item)
                        }
                                         ))
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
    NutritionLibraryPickerView(viewModel: NutritionLibraryPickerViewModel(interactor: CoreInteractor(container: DevPreview.shared.container), onPick: { item in
        print(item.displayName)
    }))
    .previewEnvironment()
}
