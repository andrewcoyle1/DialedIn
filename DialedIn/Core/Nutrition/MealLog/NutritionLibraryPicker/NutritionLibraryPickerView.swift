//
//  NutritionLibraryPickerView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/10/2025.
//

import SwiftUI

struct NutritionLibraryPickerView: View {
    @State var viewModel: NutritionLibraryPickerViewModel
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
                        IngredientAmountView(ingredient: ingredient) { item in
                            viewModel.onPick(item)
                        }
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
                        RecipeAmountView(recipe: recipe) { item in
                            viewModel.onPick(item)
                        }
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

private struct IngredientAmountView: View {
    @Environment(IngredientTemplateManager.self) private var ingredientTemplateManager
    
    let ingredient: IngredientTemplateModel
    let onConfirm: (MealItemModel) -> Void
    
    @State private var amountText: String = "100"
    
    private var unitLabel: String {
        switch ingredient.measurementMethod {
        case .weight: return "g"
        case .volume: return "ml"
        }
    }
    
    private var amountValue: Double { Double(amountText) ?? 0 }
    private var scale: Double { max(amountValue, 0) / 100.0 }
    
    private var calories: Double? { ingredient.calories.map { $0 * scale } }
    private var protein: Double? { ingredient.protein.map { $0 * scale } }
    private var carbs: Double? { ingredient.carbs.map { $0 * scale } }
    private var fat: Double? { ingredient.fatTotal.map { $0 * scale } }
    
    var body: some View {
        Form {
            Section("Amount") {
                HStack {
                    TextField("Amount", text: $amountText)
                        .keyboardType(.decimalPad)
                    Text(unitLabel)
                        .foregroundStyle(.secondary)
                }
            }
            
            Section("Estimated Macros") {
                HStack {
                    Text("Calories")
                    Spacer()
                    Text(calories.map { String(Int(round($0))) } ?? "-")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Protein")
                    Spacer()
                    Text(protein.map { String(format: "%.1f g", $0) } ?? "-")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Carbs")
                    Spacer()
                    Text(carbs.map { String(format: "%.1f g", $0) } ?? "-")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Fat")
                    Spacer()
                    Text(fat.map { String(format: "%.1f g", $0) } ?? "-")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(ingredient.name)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") { add() }
                    .disabled((Double(amountText) ?? 0) <= 0)
            }
        }
    }
    
    private func add() {
        let resolvedGrams = ingredient.measurementMethod == .weight ? amountValue : nil
        let resolvedMl = ingredient.measurementMethod == .volume ? amountValue : nil
        let item = MealItemModel(
            itemId: UUID().uuidString,
            sourceType: .ingredient,
            sourceId: ingredient.ingredientId,
            displayName: ingredient.name,
            amount: amountValue,
            unit: unitLabel,
            resolvedGrams: resolvedGrams,
            resolvedMilliliters: resolvedMl,
            calories: calories,
            proteinGrams: protein,
            carbGrams: carbs,
            fatGrams: fat
        )
        onConfirm(item)
    }
}

private struct RecipeAmountView: View {
    let recipe: RecipeTemplateModel
    let onConfirm: (MealItemModel) -> Void
    
    @State private var servingsText: String = "1"
    
    // Simple estimate: sum ingredient macros using their per-100g values and amounts.
    private var baseCalories: Double? {
        aggregate { $0.calories }
    }
    private var baseProtein: Double? {
        aggregate { $0.protein }
    }
    private var baseCarbs: Double? {
        aggregate { $0.carbs }
    }
    private var baseFat: Double? {
        aggregate { $0.fatTotal }
    }
    
    private var servings: Double { max(Double(servingsText) ?? 0, 0) }
    
    private func aggregate(_ keyPath: (IngredientTemplateModel) -> Double?) -> Double? {
        var total: Double = 0
        var hasValue = false
        for recipeIngredient in recipe.ingredients {
            guard let per100 = keyPath(recipeIngredient.ingredient) else { continue }
            hasValue = true
            let grams: Double
            switch recipeIngredient.unit {
            case .grams:
                grams = recipeIngredient.amount
            case .milliliters:
                grams = recipeIngredient.amount // approximation
            case .units:
                grams = recipeIngredient.amount * 100 // rough fallback
            }
            total += per100 * (grams / 100.0)
        }
        return hasValue ? total : nil
    }
    
    var body: some View {
        Form {
            Section("Servings") {
                TextField("Servings", text: $servingsText)
                    .keyboardType(.decimalPad)
            }
            Section("Estimated Macros (per serving)") {
                HStack {
                    Text("Calories")
                    Spacer()
                    Text(baseCalories.map { String(Int(round($0))) } ?? "-")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Protein")
                    Spacer()
                    Text(baseProtein.map { String(format: "%.1f g", $0) } ?? "-")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Carbs")
                    Spacer()
                    Text(baseCarbs.map { String(format: "%.1f g", $0) } ?? "-")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Fat")
                    Spacer()
                    Text(baseFat.map { String(format: "%.1f g", $0) } ?? "-")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(recipe.name)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") { add() }
                    .disabled(servings <= 0)
            }
        }
    }
    
    private func add() {
        let calories = baseCalories.map { $0 * servings }
        let protein = baseProtein.map { $0 * servings }
        let carbs = baseCarbs.map { $0 * servings }
        let fat = baseFat.map { $0 * servings }
        let item = MealItemModel(
            itemId: UUID().uuidString,
            sourceType: .recipe,
            sourceId: recipe.recipeId,
            displayName: recipe.name,
            amount: servings,
            unit: "serving",
            resolvedGrams: nil,
            resolvedMilliliters: nil,
            calories: calories,
            proteinGrams: protein,
            carbGrams: carbs,
            fatGrams: fat
        )
        onConfirm(item)
    }
}

#Preview {
    NutritionLibraryPickerView(viewModel: NutritionLibraryPickerViewModel(interactor: CoreInteractor(container: DevPreview.shared.container), onPick: { item in
        print(item.displayName)
    }))
    .previewEnvironment()
}
