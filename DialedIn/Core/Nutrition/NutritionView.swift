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

struct NutritionView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: NutritionViewModel
    @Environment(\.layoutMode) private var layoutMode
    @Environment(DetailNavigationModel.self) private var detail
    
    var body: some View {
        Group {
            if layoutMode == .tabBar {
                NavigationStack {
                    contentView
                }
            } else {
                contentView
            }
        }
        // Only show inspector in compact/tabBar modes; not in split view where detail is used
        .modifier(InspectorIfCompact(isPresented: $viewModel.isShowingInspector, inspector: { inspectorContent }, enabled: layoutMode != .splitView))
        .onChange(of: viewModel.selectedIngredientTemplate) { _, ing in
            guard layoutMode == .splitView else { return }
            if let ing { detail.path = [.ingredientTemplateDetail(template: ing)] }
        }
        .onChange(of: viewModel.selectedRecipeTemplate) { _, rec in
            guard layoutMode == .splitView else { return }
            if let rec { detail.path = [.recipeTemplateDetail(template: rec)] }
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
                DevSettingsView(viewModel: DevSettingsViewModel(interactor: CoreInteractor(container: container)))
            }
            #endif
            .sheet(isPresented: $viewModel.showNotifications) {
                NotificationsView(viewModel: NotificationsViewModel(interactor: CoreInteractor(container: container)))
            }
            .sheet(isPresented: $viewModel.showCreateIngredient) {
                CreateIngredientView(viewModel: CreateIngredientViewModel(interactor: CoreInteractor(container: container)))
            }
            .sheet(isPresented: $viewModel.showCreateRecipe) {
                CreateRecipeView(viewModel: CreateRecipeViewModel(interactor: CoreInteractor(container: container)))
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
                MealLogView(
                    viewModel: MealLogViewModel(interactor: CoreInteractor(container: container)),
                    isShowingInspector: $viewModel.isShowingInspector,
                    selectedIngredientTemplate: $viewModel.selectedIngredientTemplate,
                    selectedRecipeTemplate: $viewModel.selectedRecipeTemplate
                )
            case .recipes:
                RecipesView(
                    viewModel: RecipesViewModel(
                        interactor: CoreInteractor(
                            container: container
                        )
                    )
                )
            case .ingredients:
                IngredientsView(
                    viewModel: IngredientsViewModel(interactor: CoreInteractor(container: container)),
                    isShowingInspector: $viewModel.isShowingInspector,
                    selectedIngredientTemplate: $viewModel.selectedIngredientTemplate,
                    selectedRecipeTemplate: $viewModel.selectedRecipeTemplate,
                    showCreateIngredient: $viewModel.showCreateIngredient
                )
            }
        }
    }
    
    private var inspectorContent: some View {
        Group {
            if let ingredient = viewModel.selectedIngredientTemplate {
                NavigationStack {
                    IngredientDetailView(viewModel: IngredientDetailViewModel(interactor: CoreInteractor(container: container), ingredientTemplate: ingredient))
                }
            } else if let recipe = viewModel.selectedRecipeTemplate {
                NavigationStack {
                    RecipeDetailView(viewModel: RecipeDetailViewModel(interactor: CoreInteractor(container: container), recipeTemplate: recipe))
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
    NutritionView(
        viewModel: NutritionViewModel(
            interactor: CoreInteractor(
                container: DevPreview.shared.container
            )
        )
    )
    .previewEnvironment()
}
