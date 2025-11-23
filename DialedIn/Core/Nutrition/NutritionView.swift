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
