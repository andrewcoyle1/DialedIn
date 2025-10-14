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
    @State private var showAddIngredientModal: Bool = false
    @State private var selectedIngredientTemplate: IngredientTemplateModel?

    @State private var searchRecipeTask: Task<Void, Never>?
    @State private var myRecipes: [RecipeTemplateModel] = []
    @State private var favouriteRecipes: [RecipeTemplateModel] = []
    @State private var bookmarkedRecipes: [RecipeTemplateModel] = []
    @State private var recipes: [RecipeTemplateModel] = []
    @State private var showAddRecipeModal: Bool = false
    @State private var selectedRecipeTemplate: RecipeTemplateModel?

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
        NavigationStack {
            List {
                pickerSection
                listContents
            }
            .navigationTitle("Nutrition")
            .navigationSubtitle(Date.now.formatted(date: .abbreviated, time: .omitted))
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .scrollIndicators(.hidden)
            .showCustomAlert(alert: $showAlert)
            .toolbar {
                toolbarContent
            }
            #if DEBUG || MOCK
            .sheet(isPresented: $showDebugView) {
                DevSettingsView()
            }
            #endif
            .sheet(isPresented: $showNotifications) {
                NotificationsView()
            }
        }
        .inspector(isPresented: $isShowingInspector) {
            inspectorContent
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
                    selectedRecipeTemplate: $selectedRecipeTemplate
                )
            case .ingredients:
                // ingredientsSection
                IngredientsView(
                    isShowingInspector: $isShowingInspector,
                    selectedIngredientTemplate: $selectedIngredientTemplate,
                    selectedRecipeTemplate: $selectedRecipeTemplate
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

        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom != .phone {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingInspector.toggle()
                } label: {
                    Image(systemName: "info")
                }
            }
        }
        #else
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                isShowingInspector.toggle()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                onNotificationsPressed()
            } label: {
                Image(systemName: "bell")
            }
        }
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
