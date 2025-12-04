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
import SwiftfulRouting

struct NutritionView<MealLogView: View, RecipesView: View, IngredientsView: View>: View {

    @Environment(\.layoutMode) private var layoutMode

    @State var presenter: NutritionPresenter

    @ViewBuilder var mealLogView: (MealLogDelegate) -> MealLogView
    @ViewBuilder var recipesView: (RecipesDelegate) -> RecipesView
    @ViewBuilder var ingredientsView: (IngredientsDelegate) -> IngredientsView

    var body: some View {
        List {
            pickerSection
            listContents
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Nutrition")
        .navigationSubtitle(Date.now.formatted(date: .abbreviated, time: .omitted))
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            toolbarContent
        }
    }

    private var pickerSection: some View {
        Section {
            Picker("Section", selection: $presenter.presentationMode) {
                Text("Meal Log").tag(NutritionPresenter.NutritionPresentationMode.log)
                Text("Recipes").tag(NutritionPresenter.NutritionPresentationMode.recipes)
                Text("Ingredients").tag(NutritionPresenter.NutritionPresentationMode.ingredients)
            }
            .pickerStyle(.segmented)
        }
        .listSectionSpacing(0)
        .removeListRowFormatting()
    }
    
    private var listContents: some View {
        Group {
            switch presenter.presentationMode {
            case .log:
                mealLogView(
                    MealLogDelegate(
                        isShowingInspector: $presenter.isShowingInspector,
                        selectedIngredientTemplate: $presenter.selectedIngredientTemplate,
                        selectedRecipeTemplate: $presenter.selectedRecipeTemplate
                    )
                )
            case .recipes:
                recipesView(
                    RecipesDelegate(
                        showCreateRecipe: .constant(false),
                        selectedIngredientTemplate: $presenter.selectedIngredientTemplate,
                        selectedRecipeTemplate: $presenter.selectedRecipeTemplate,
                        isShowingInspector: $presenter.isShowingInspector
                    )
                )
            case .ingredients:
                ingredientsView(
                    IngredientsDelegate(
                        isShowingInspector: $presenter.isShowingInspector,
                        selectedIngredientTemplate: $presenter.selectedIngredientTemplate,
                        selectedRecipeTemplate: $presenter.selectedRecipeTemplate,
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
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.onNotificationsPressed()
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
