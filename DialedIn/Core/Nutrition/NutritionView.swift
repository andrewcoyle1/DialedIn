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

struct NutritionViewDelegate {
    var path: Binding<[TabBarPathOption]>
}

struct NutritionView: View {
    @Environment(CoreBuilder.self) private var builder
    @Environment(\.layoutMode) private var layoutMode

    @State var viewModel: NutritionViewModel
    
    var delegate: NutritionViewDelegate

    var body: some View {
        Group {
            if layoutMode == .tabBar {
                NavigationStack(path: delegate.path) {
                    contentView
                }
                .navDestinationForTabBarModule(path: delegate.path)
            } else {
                contentView
            }
        }
        // Only show inspector in compact/tabBar modes; not in split view where detail is used
        .inspectorIfCompact(isPresented: $viewModel.isShowingInspector, inspector: { inspectorContent }, enabled: layoutMode != .splitView)
        .onChange(of: viewModel.selectedIngredientTemplate) { _, ingredient in
            guard layoutMode == .splitView else { return }
            if let ingredient { delegate.path.wrappedValue = [.ingredientTemplateDetail(template: ingredient)] }
        }
        .onChange(of: viewModel.selectedRecipeTemplate) { _, recipe in
            guard layoutMode == .splitView else { return }
            if let recipe { delegate.path.wrappedValue = [.recipeTemplateDetail(template: recipe)] }
        }
    }
    
    private var contentView: some View {
        VStack(spacing: 0) {
            List {
                pickerSection
                listContents
            }
            .scrollIndicators(.hidden)
            .showCustomAlert(alert: $viewModel.showAlert)
            #if DEBUG || MOCK
            .sheet(isPresented: $viewModel.showDebugView) {
                builder.devSettingsView()
            }
            #endif
            .sheet(isPresented: $viewModel.showNotifications) {
                builder.notificationsView()
            }
            .sheet(isPresented: $viewModel.showCreateIngredient) {
                builder.createIngredientView()
            }
            .sheet(isPresented: $viewModel.showCreateRecipe) {
                builder.createRecipeView()
            }
        }
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
                builder.mealLogView(
                    delegate: MealLogViewDelegate(
                        path: delegate.path,
                        isShowingInspector: $viewModel.isShowingInspector,
                        selectedIngredientTemplate: $viewModel.selectedIngredientTemplate,
                        selectedRecipeTemplate: $viewModel.selectedRecipeTemplate
                    )
                )
            case .recipes:
                builder.recipesView(
                    delegate: RecipesViewDelegate(
                        showCreateRecipe: $viewModel.showCreateRecipe,
                        selectedIngredientTemplate: $viewModel.selectedIngredientTemplate,
                        selectedRecipeTemplate: $viewModel.selectedRecipeTemplate,
                        isShowingInspector: $viewModel.isShowingInspector
                    )
                )
            case .ingredients:
                builder.ingredientsView(
                    delegate: IngredientsViewDelegate(
                        isShowingInspector: $viewModel.isShowingInspector,
                        selectedIngredientTemplate: $viewModel.selectedIngredientTemplate,
                        selectedRecipeTemplate: $viewModel.selectedRecipeTemplate,
                        showCreateIngredient: $viewModel.showCreateIngredient
                    )
                )
            }
        }
    }
    
    private var inspectorContent: some View {
        Group {
            if let ingredient = viewModel.selectedIngredientTemplate {
                NavigationStack {
                    let delegate = IngredientDetailViewDelegate(ingredientTemplate: ingredient)
                    builder.ingredientDetailView(delegate: delegate)
                }
            } else if let recipe = viewModel.selectedRecipeTemplate {
                NavigationStack {
                    builder.recipeDetailView(recipeTemplate: recipe)
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
                viewModel.showDebugView = true
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
    @Previewable @State var path: [TabBarPathOption] = []
    let builder = CoreBuilder(container: DevPreview.shared.container)
    builder.nutritionView(delegate: NutritionViewDelegate(path: $path))
    .previewEnvironment()
}
