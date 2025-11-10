//
//  IngredientDetailView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI

struct IngredientDetailView: View {
    @Environment(CoreBuilder.self) private var builder
    @State var viewModel: IngredientDetailViewModel

    var body: some View {
        List {
            if let url = viewModel.ingredientTemplate.imageURL {
                imageSection(url: url)
            }
            macroNutrientSection
            essentialMacroMineralsSection
            essentialTraceMineralsSection
            fatSolubleVitaminsSection
            waterSolubleVitaminsSection
            bioactiveCompoundsSection
            dateCreatedSection
            if let authorId =  viewModel.ingredientTemplate.authorId {
                authorSection(id: authorId)
            }
        }
        .navigationTitle(viewModel.ingredientTemplate.name)
        .navigationSubtitle(viewModel.ingredientTemplate.description ?? "")
        .navigationBarTitleDisplayMode(.large)
        .showCustomAlert(alert: $viewModel.showAlert)
        .screenAppearAnalytics(name: "IngredientDetailView")
        .toolbar {
            toolbarContent
        }
        .task { await viewModel.loadInitialState() }
        .onChange(of: viewModel.currentUser) { _, _ in
            let user = viewModel.currentUser
            let isAuthor = user?.userId == viewModel.ingredientTemplate.authorId
            viewModel.isBookmarked = isAuthor || (user?.bookmarkedIngredientTemplateIds?.contains(viewModel.ingredientTemplate.id) ?? false) || (user?.createdIngredientTemplateIds?.contains(viewModel.ingredientTemplate.id) ?? false)
            viewModel.isFavourited = user?.favouritedIngredientTemplateIds?.contains(viewModel.ingredientTemplate.id) ?? false
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
            rowItem(label: "Calories", value: viewModel.ingredientTemplate.calories, unit: "kcal")

            // Macronutrient composition
            rowItem(label: "Protein", value: viewModel.ingredientTemplate.protein, unit: "g")
            rowItem(label: "Carbohydrates", value: viewModel.ingredientTemplate.carbs, unit: "g")
            rowItem(label: "Total Fat", value: viewModel.ingredientTemplate.fatTotal, unit: "g")
            
            // Fat breakdown
            if viewModel.ingredientTemplate.fatSaturated != nil || viewModel.ingredientTemplate.fatMonounsaturated != nil || viewModel.ingredientTemplate.fatPolyunsaturated != nil {
                rowItem(label: "Saturated Fat", value: viewModel.ingredientTemplate.fatSaturated, unit: "g")
                rowItem(label: "Monounsaturated Fat", value: viewModel.ingredientTemplate.fatMonounsaturated, unit: "g")
                rowItem(label: "Polyunsaturated Fat", value: viewModel.ingredientTemplate.fatPolyunsaturated, unit: "g")
            }

            // Carbohydrate breakdown
            if viewModel.ingredientTemplate.fiber != nil || viewModel.ingredientTemplate.sugar != nil {
                rowItem(label: "Dietary Fiber", value: viewModel.ingredientTemplate.fiber, unit: "g")
                rowItem(label: "Total Sugars", value: viewModel.ingredientTemplate.sugar, unit: "g")
            }
        } header: {
            Text("Nutrition Information (per 100g)")
        }
    }

    private var essentialMacroMineralsSection: some View {
        Section {
            // Essential Macrominerals - Required in larger amounts
            rowItem(label: "Calcium", value: viewModel.ingredientTemplate.calciumMg, unit: "mg")
            rowItem(label: "Phosphorus", value: viewModel.ingredientTemplate.phosphorusMg, unit: "mg")
            rowItem(label: "Magnesium", value: viewModel.ingredientTemplate.magnesiumMg, unit: "mg")
            rowItem(label: "Sodium", value: viewModel.ingredientTemplate.sodiumMg, unit: "mg")
            rowItem(label: "Potassium", value: viewModel.ingredientTemplate.potassiumMg, unit: "mg")
            rowItem(label: "Chloride", value: viewModel.ingredientTemplate.chlorideMg, unit: "mg")
        } header: {
            Text("Essential Macrominerals (per 100g)")
        }
    }

    private var essentialTraceMineralsSection: some View {
        Section {
            // Essential Trace Minerals - Required in smaller amounts
            rowItem(label: "Iron", value: viewModel.ingredientTemplate.ironMg, unit: "mg")
            rowItem(label: "Zinc", value: viewModel.ingredientTemplate.zincMg, unit: "mg")
            rowItem(label: "Copper", value: viewModel.ingredientTemplate.copperMg, unit: "mg")
            rowItem(label: "Manganese", value: viewModel.ingredientTemplate.manganeseMg, unit: "mg")
            rowItem(label: "Iodine", value: viewModel.ingredientTemplate.iodineMcg, unit: "μg")
            rowItem(label: "Selenium", value: viewModel.ingredientTemplate.seleniumMcg, unit: "μg")
            rowItem(label: "Molybdenum", value: viewModel.ingredientTemplate.molybdenumMcg, unit: "μg")
            rowItem(label: "Chromium", value: viewModel.ingredientTemplate.chromiumMcg, unit: "μg")
        } header: {
            Text("Essential Trace Minerals (per 100g)")
        }
    }

    private var fatSolubleVitaminsSection: some View {
        Section {
            // Fat-Soluble Vitamins - A, D, E, K
            rowItem(label: "Vitamin A", value: viewModel.ingredientTemplate.vitaminAMcg, unit: " mcg RAE")
            rowItem(label: "Vitamin D", value: viewModel.ingredientTemplate.vitaminDMcg, unit: " mcg")
            rowItem(label: "Vitamin E", value: viewModel.ingredientTemplate.vitaminEMg, unit: " mg α-tocopherol")
            rowItem(label: "Vitamin K", value: viewModel.ingredientTemplate.vitaminKMcg, unit: " mcg")
        } header: {
            Text("Fat-Soluble Vitamins (per 100g)")
        }
    }

    private var waterSolubleVitaminsSection: some View {
        Section {
            // Water-Soluble Vitamins - B-Complex & C
            rowItem(label: "Thiamin - B1", value: viewModel.ingredientTemplate.thiaminMg, unit: " mg")
            rowItem(label: "Riboflavin - B2", value: viewModel.ingredientTemplate.riboflavinMg, unit: " mg")
            rowItem(label: "Niacin - B3", value: viewModel.ingredientTemplate.niacinMg, unit: " mg NE")
            rowItem(label: "Pantothenic Acid - B5", value: viewModel.ingredientTemplate.pantothenicAcidMg, unit: " mg")
            rowItem(label: "Vitamin B6", value: viewModel.ingredientTemplate.vitaminB6Mg, unit: " mg")
            rowItem(label: "Folate - B9", value: viewModel.ingredientTemplate.folateMcg, unit: " mcg DFE")
            rowItem(label: "Vitamin B12", value: viewModel.ingredientTemplate.vitaminB12Mcg, unit: " mcg")
            rowItem(label: "Biotin - B7", value: viewModel.ingredientTemplate.biotinMcg, unit: " mcg")
            rowItem(label: "Vitamin C", value: viewModel.ingredientTemplate.vitaminCMg, unit: " mg")
        } header: {
            Text("Water-Soluble Vitamins (per 100g)")
        }
    }

    private var bioactiveCompoundsSection: some View {
        Section {
            // Bioactive Compounds
            rowItem(label: "Cholesterol", value: viewModel.ingredientTemplate.cholesterolMg, unit: " mg")
            rowItem(label: "Caffeine", value: viewModel.ingredientTemplate.caffeineMg, unit: " mg")
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
            Text(viewModel.ingredientTemplate.dateCreated.formatted(date: .abbreviated, time: .omitted))
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
                    await viewModel.onFavoritePressed()
                }
            } label: {
                Image(systemName: viewModel.isFavourited ? "heart.fill" : "heart")
            }
        }
        // Hide bookmark button when the current user is the author
        if viewModel.currentUser?.userId != nil && viewModel.currentUser?.userId != viewModel.ingredientTemplate.authorId {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        await viewModel.onBookmarkPressed()
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
        builder.ingredientDetailView(ingredientTemplate: IngredientTemplateModel.mocks[0])
    }
    .previewEnvironment()
}
