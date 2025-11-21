//
//  NutritionView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 25/09/2025.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif
import CustomRouting

struct NutritionView: View {

    @Environment(\.layoutMode) private var layoutMode

    @State var viewModel: NutritionViewModel

    @ViewBuilder var mealLogView: (MealLogViewDelegate) -> AnyView
    @ViewBuilder var recipesView: (RecipesViewDelegate) -> AnyView
    @ViewBuilder var ingredientsView: (IngredientsViewDelegate) -> AnyView
    @ViewBuilder var ingredientDetailView: (IngredientDetailViewDelegate) -> AnyView
    @ViewBuilder var recipeDetailView: (RecipeDetailViewDelegate) -> AnyView
    
    var body: some View {
        List {
            pickerSection
            listContents
        }
        .scrollIndicators(.hidden)
        .showCustomAlert(alert: $viewModel.showAlert)
        .navigationTitle("Nutrition")
        .navigationSubtitle(Date.now.formatted(date: .abbreviated, time: .omitted))
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            toolbarContent
        }
//        .onChange(of: viewModel.selectedIngredientTemplate) { _, ingredient in
//            guard layoutMode == .splitView else { return }
//            if let ingredient { delegate.path.wrappedValue = [.ingredientTemplateDetail(template: ingredient)] }
//        }
//        .onChange(of: viewModel.selectedRecipeTemplate) { _, recipe in
//            guard layoutMode == .splitView else { return }
//            if let recipe { delegate.path.wrappedValue = [.recipeTemplateDetail(template: recipe)] }
//        }
    }

    private var pickerSection: some View {
        Section {
            Picker("Section", selection: $viewModel.presentationMode) {
                Text("Meal Log").tag(NutritionViewModel.NutritionPresentationMode.log)
                Text("Recipes").tag(NutritionViewModel.NutritionPresentationMode.recipes)
                Text("Ingredients").tag(NutritionViewModel.NutritionPresentationMode.ingredients)
            }
            .pickerStyle(.segmented)
        }
        .listSectionSpacing(0)
        .removeListRowFormatting()
    }
    
    private var listContents: some View {
        Group {
            switch viewModel.presentationMode {
            case .log:
                mealLogView(
                    MealLogViewDelegate(
                        path: .constant([]),
                        isShowingInspector: $viewModel.isShowingInspector,
                        selectedIngredientTemplate: $viewModel.selectedIngredientTemplate,
                        selectedRecipeTemplate: $viewModel.selectedRecipeTemplate
                    )
                )
            case .recipes:
                recipesView(
                    RecipesViewDelegate(
                        showCreateRecipe: .constant(false),
                        selectedIngredientTemplate: $viewModel.selectedIngredientTemplate,
                        selectedRecipeTemplate: $viewModel.selectedRecipeTemplate,
                        isShowingInspector: $viewModel.isShowingInspector
                    )
                )
            case .ingredients:
                ingredientsView(
                    IngredientsViewDelegate(
                        isShowingInspector: $viewModel.isShowingInspector,
                        selectedIngredientTemplate: $viewModel.selectedIngredientTemplate,
                        selectedRecipeTemplate: $viewModel.selectedRecipeTemplate,
                        showCreateIngredient: .constant(false)
                    )
                )
            }
        }
    }
    
    private var inspectorContent: some View {
        Group {
            if let ingredient = viewModel.selectedIngredientTemplate {
                NavigationStack {
                    ingredientDetailView(
                        IngredientDetailViewDelegate(
                            ingredientTemplate: ingredient
                        )
                    )
                }
            } else if let recipe = viewModel.selectedRecipeTemplate {
                NavigationStack {
                    recipeDetailView(
                        RecipeDetailViewDelegate(
                            recipeTemplate: recipe
                        )
                    )
                }
            } else {
                Text("Select an item")
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
        .inspectorColumnWidth(min: 300, ideal: 400, max: 600)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                viewModel.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        
        ToolbarItem(placement: .topBarLeading) {
            Button {
                viewModel.onNotificationsPressed()
            } label: {
                Image(systemName: "bell")
            }
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.nutritionView(router: router)
    }
    .previewEnvironment()
}
