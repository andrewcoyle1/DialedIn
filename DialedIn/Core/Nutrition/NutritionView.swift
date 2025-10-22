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

    @Environment(\.layoutMode) private var layoutMode
    @Environment(DetailNavigationModel.self) private var detail
    @State private var presentationMode: NutritionPresentationMode = .log

    @State private var isLoading: Bool = false
    @State private var searchText: String = ""
    @State private var showAlert: AnyAppAlert?
    @State private var isShowingInspector: Bool = false
    
    @State private var searchIngredientTask: Task<Void, Never>?
    @State private var myIngredients: [IngredientTemplateModel] = []
    @State private var favouriteIngredients: [IngredientTemplateModel] = []
    @State private var bookmarkedIngredients: [IngredientTemplateModel] = []
    @State private var ingredients: [IngredientTemplateModel] = []
    @State private var selectedIngredientTemplate: IngredientTemplateModel?
    @State private var showCreateIngredient: Bool = false

    @State private var searchRecipeTask: Task<Void, Never>?
    @State private var myRecipes: [RecipeTemplateModel] = []
    @State private var favouriteRecipes: [RecipeTemplateModel] = []
    @State private var bookmarkedRecipes: [RecipeTemplateModel] = []
    @State private var recipes: [RecipeTemplateModel] = []
    @State private var selectedRecipeTemplate: RecipeTemplateModel?
    @State private var showCreateRecipe: Bool = false

    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif
    @State private var showNotifications: Bool = false
    
    enum NutritionPresentationMode {
        case log
        case recipes
        case ingredients
    }
    
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
        .modifier(InspectorIfCompact(isPresented: $isShowingInspector, inspector: { inspectorContent }, enabled: layoutMode != .splitView))
        .onChange(of: selectedIngredientTemplate) { _, ing in
            guard layoutMode == .splitView else { return }
            if let ing { detail.path = [.ingredientTemplateDetail(template: ing)] }
        }
        .onChange(of: selectedRecipeTemplate) { _, rec in
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
            .showCustomAlert(alert: $showAlert)
            #if DEBUG || MOCK
            .sheet(isPresented: $showDebugView) {
                DevSettingsView(viewModel: DevSettingsViewModel(container: container))
            }
            #endif
            .sheet(isPresented: $showNotifications) {
                NotificationsView()
            }
            .sheet(isPresented: $showCreateIngredient) {
                CreateIngredientView()
            }
            .sheet(isPresented: $showCreateRecipe) {
                CreateRecipeView()
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
            Picker("Section", selection: $presentationMode) {
                Text("Meal Log").tag(NutritionPresentationMode.log)
                Text("Recipes").tag(NutritionPresentationMode.recipes)
                Text("Ingredients").tag(NutritionPresentationMode.ingredients)
            }
            .pickerStyle(.segmented)
        }
        .listSectionSpacing(0)
        .removeListRowFormatting()
    }
    
    private var listContents: some View {
        Group {
            switch presentationMode {
            case .log:
                MealLogView(isShowingInspector: $isShowingInspector,
                            selectedIngredientTemplate: $selectedIngredientTemplate,
                            selectedRecipeTemplate: $selectedRecipeTemplate)
            case .recipes:
                RecipesView(
                    isShowingInspector: $isShowingInspector,
                    selectedIngredientTemplate: $selectedIngredientTemplate,
                    selectedRecipeTemplate: $selectedRecipeTemplate,
                    showCreateRecipe: $showCreateRecipe
                )
            case .ingredients:
                // ingredientsSection
                IngredientsView(
                    isShowingInspector: $isShowingInspector,
                    selectedIngredientTemplate: $selectedIngredientTemplate,
                    selectedRecipeTemplate: $selectedRecipeTemplate,
                    showCreateIngredient: $showCreateIngredient
                )
            }
        }
    }
    
    private var inspectorContent: some View {
        Group {
            if let ingredient = selectedIngredientTemplate {
                NavigationStack {
                    IngredientDetailView(ingredientTemplate: ingredient)
                }
            } else if let recipe = selectedRecipeTemplate {
                NavigationStack {
                    RecipeDetailView(recipeTemplate: recipe)
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
                showDebugView = true
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        
        ToolbarItem(placement: .topBarLeading) {
            Button {
                onNotificationsPressed()
            } label: {
                Image(systemName: "bell")
            }
        }
        
//        #if os(iOS)
//        if UIDevice.current.userInterfaceIdiom != .phone {
//            ToolbarSpacer(placement: .topBarTrailing)
//            ToolbarItem(placement: .topBarTrailing) {
//                Button {
//                    isShowingInspector.toggle()
//                } label: {
//                    Image(systemName: "info")
//                }
//            }
//        }
//        #else
//        ToolbarSpacer(placement: .topBarTrailing)
//        ToolbarItem(placement: .topBarTrailing) {
//            Button {
//                isShowingInspector.toggle()
//            } label: {
//                Image(systemName: "info")
//            }
//        }
//        #endif
    }
}

#Preview {
    NutritionView()
        .previewEnvironment()
}

extension NutritionView {
    
    private func onNotificationsPressed() {
        showNotifications = true
    }
    
}
