//
//  IngredientDetailView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI

struct IngredientDetailViewDelegate {
    let ingredientTemplate: IngredientTemplateModel
}
struct IngredientDetailView: View {
    @Environment(CoreBuilder.self) private var builder
    @State var viewModel: IngredientDetailViewModel

    let delegate: IngredientDetailViewDelegate

    var body: some View {
        List {
            if let url = delegate.ingredientTemplate.imageURL {
                imageSection(url: url)
            }
            macroNutrientSection
            essentialMacroMineralsSection
            essentialTraceMineralsSection
            fatSolubleVitaminsSection
            waterSolubleVitaminsSection
            bioactiveCompoundsSection
            dateCreatedSection
            if let authorId =  delegate.ingredientTemplate.authorId {
                authorSection(id: authorId)
            }
        }
        .navigationTitle(delegate.ingredientTemplate.name)
        .navigationSubtitle(delegate.ingredientTemplate.description ?? "")
        .navigationBarTitleDisplayMode(.large)
        .showCustomAlert(alert: $viewModel.showAlert)
        .screenAppearAnalytics(name: "IngredientDetailView")
        .toolbar {
            toolbarContent
        }
        .task { await viewModel.loadInitialState(ingredientTemplate: delegate.ingredientTemplate) }
        .onChange(of: viewModel.currentUser) { _, _ in
            let user = viewModel.currentUser
            let isAuthor = user?.userId == delegate.ingredientTemplate.authorId
            viewModel.isBookmarked = isAuthor || (user?.bookmarkedIngredientTemplateIds?.contains(delegate.ingredientTemplate.id) ?? false) || (user?.createdIngredientTemplateIds?.contains(delegate.ingredientTemplate.id) ?? false)
            viewModel.isFavourited = user?.favouritedIngredientTemplateIds?.contains(delegate.ingredientTemplate.id) ?? false
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $viewModel.showDebugView) {
            builder.devSettingsView()
        }
        #endif
    }

    private func imageSection(url: String) -> some View {
        Section {
            ImageLoaderView(urlString: url, resizingMode: .fill)
                .frame(maxWidth: .infinity, minHeight: 180)
        }
        .removeListRowFormatting()
    }

    private func descriptionSection(description: String) -> some View {
        Section(header: Text("Description")) {
            Text(description)
                .font(.body)
        }
    }

    private var macroNutrientSection: some View {
        Section {
            // Primary macronutrients
            rowItem(label: "Calories", value: delegate.ingredientTemplate.calories, unit: "kcal")

            // Macronutrient composition
            rowItem(label: "Protein", value: delegate.ingredientTemplate.protein, unit: "g")
            rowItem(label: "Carbohydrates", value: delegate.ingredientTemplate.carbs, unit: "g")
            rowItem(label: "Total Fat", value: delegate.ingredientTemplate.fatTotal, unit: "g")

            // Fat breakdown
            if delegate.ingredientTemplate.fatSaturated != nil || delegate.ingredientTemplate.fatMonounsaturated != nil || delegate.ingredientTemplate.fatPolyunsaturated != nil {
                rowItem(label: "Saturated Fat", value: delegate.ingredientTemplate.fatSaturated, unit: "g")
                rowItem(label: "Monounsaturated Fat", value: delegate.ingredientTemplate.fatMonounsaturated, unit: "g")
                rowItem(label: "Polyunsaturated Fat", value: delegate.ingredientTemplate.fatPolyunsaturated, unit: "g")
            }

            // Carbohydrate breakdown
            if delegate.ingredientTemplate.fiber != nil || delegate.ingredientTemplate.sugar != nil {
                rowItem(label: "Dietary Fiber", value: delegate.ingredientTemplate.fiber, unit: "g")
                rowItem(label: "Total Sugars", value: delegate.ingredientTemplate.sugar, unit: "g")
            }
        } header: {
            Text("Nutrition Information (per 100g)")
        }
    }

    private var essentialMacroMineralsSection: some View {
        Section {
            // Essential Macrominerals - Required in larger amounts
            rowItem(label: "Calcium", value: delegate.ingredientTemplate.calciumMg, unit: "mg")
            rowItem(label: "Phosphorus", value: delegate.ingredientTemplate.phosphorusMg, unit: "mg")
            rowItem(label: "Magnesium", value: delegate.ingredientTemplate.magnesiumMg, unit: "mg")
            rowItem(label: "Sodium", value: delegate.ingredientTemplate.sodiumMg, unit: "mg")
            rowItem(label: "Potassium", value: delegate.ingredientTemplate.potassiumMg, unit: "mg")
            rowItem(label: "Chloride", value: delegate.ingredientTemplate.chlorideMg, unit: "mg")
        } header: {
            Text("Essential Macrominerals (per 100g)")
        }
    }

    private var essentialTraceMineralsSection: some View {
        Section {
            // Essential Trace Minerals - Required in smaller amounts
            rowItem(label: "Iron", value: delegate.ingredientTemplate.ironMg, unit: "mg")
            rowItem(label: "Zinc", value: delegate.ingredientTemplate.zincMg, unit: "mg")
            rowItem(label: "Copper", value: delegate.ingredientTemplate.copperMg, unit: "mg")
            rowItem(label: "Manganese", value: delegate.ingredientTemplate.manganeseMg, unit: "mg")
            rowItem(label: "Iodine", value: delegate.ingredientTemplate.iodineMcg, unit: "μg")
            rowItem(label: "Selenium", value: delegate.ingredientTemplate.seleniumMcg, unit: "μg")
            rowItem(label: "Molybdenum", value: delegate.ingredientTemplate.molybdenumMcg, unit: "μg")
            rowItem(label: "Chromium", value: delegate.ingredientTemplate.chromiumMcg, unit: "μg")
        } header: {
            Text("Essential Trace Minerals (per 100g)")
        }
    }

    private var fatSolubleVitaminsSection: some View {
        Section {
            // Fat-Soluble Vitamins - A, D, E, K
            rowItem(label: "Vitamin A", value: delegate.ingredientTemplate.vitaminAMcg, unit: " mcg RAE")
            rowItem(label: "Vitamin D", value: delegate.ingredientTemplate.vitaminDMcg, unit: " mcg")
            rowItem(label: "Vitamin E", value: delegate.ingredientTemplate.vitaminEMg, unit: " mg α-tocopherol")
            rowItem(label: "Vitamin K", value: delegate.ingredientTemplate.vitaminKMcg, unit: " mcg")
        } header: {
            Text("Fat-Soluble Vitamins (per 100g)")
        }
    }

    private var waterSolubleVitaminsSection: some View {
        Section {
            // Water-Soluble Vitamins - B-Complex & C
            rowItem(label: "Thiamin - B1", value: delegate.ingredientTemplate.thiaminMg, unit: " mg")
            rowItem(label: "Riboflavin - B2", value: delegate.ingredientTemplate.riboflavinMg, unit: " mg")
            rowItem(label: "Niacin - B3", value: delegate.ingredientTemplate.niacinMg, unit: " mg NE")
            rowItem(label: "Pantothenic Acid - B5", value: delegate.ingredientTemplate.pantothenicAcidMg, unit: " mg")
            rowItem(label: "Vitamin B6", value: delegate.ingredientTemplate.vitaminB6Mg, unit: " mg")
            rowItem(label: "Folate - B9", value: delegate.ingredientTemplate.folateMcg, unit: " mcg DFE")
            rowItem(label: "Vitamin B12", value: delegate.ingredientTemplate.vitaminB12Mcg, unit: " mcg")
            rowItem(label: "Biotin - B7", value: delegate.ingredientTemplate.biotinMcg, unit: " mcg")
            rowItem(label: "Vitamin C", value: delegate.ingredientTemplate.vitaminCMg, unit: " mg")
        } header: {
            Text("Water-Soluble Vitamins (per 100g)")
        }
    }

    private var bioactiveCompoundsSection: some View {
        Section {
            // Bioactive Compounds
            rowItem(label: "Cholesterol", value: delegate.ingredientTemplate.cholesterolMg, unit: " mg")
            rowItem(label: "Caffeine", value: delegate.ingredientTemplate.caffeineMg, unit: " mg")
        } header: {
            Text("Bioactive Compounds (per 100g)")
        }
    }

    private func rowItem(label: String, value: Double?, unit: String? = nil) -> some View {
        HStack {
            Text(label)
            Spacer()
            if let value = value {
                Text(value.formatted() + " " + (unit ?? ""))
            } else {
                Text("-")
            }
        }
    }

    private var dateCreatedSection: some View {
        Section(header: Text("Date Created")) {
            Text(delegate.ingredientTemplate.dateCreated.formatted(date: .abbreviated, time: .omitted))
        }
    }

    private func authorSection(id: String) -> some View {
        Section(header: Text("Author ID")) {
            Text(id)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
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
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                Task {
                    await viewModel.onFavoritePressed(ingredientTemplate: delegate.ingredientTemplate)
                }
            } label: {
                Image(systemName: viewModel.isFavourited ? "heart.fill" : "heart")
            }
        }
        // Hide bookmark button when the current user is the author
        if viewModel.currentUser?.userId != nil && viewModel.currentUser?.userId != delegate.ingredientTemplate.authorId {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        await viewModel.onBookmarkPressed(ingredientTemplate: delegate.ingredientTemplate)
                    }
                } label: {
                    Image(systemName: viewModel.isBookmarked ? "book.closed.fill" : "book.closed")
                }
            }
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    NavigationStack {
        builder.ingredientDetailView(delegate: IngredientDetailViewDelegate(ingredientTemplate: IngredientTemplateModel.mocks[0]))
    }
    .previewEnvironment()
}
