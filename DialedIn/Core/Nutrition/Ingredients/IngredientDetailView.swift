//
//  IngredientDetailView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI

struct IngredientDetailView: View {
    @Environment(DependencyContainer.self) private var container

    @Environment(IngredientTemplateManager.self) private var ingredientTemplateManager
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager

    var ingredientTemplate: IngredientTemplateModel
    @State private var isBookmarked: Bool = false
    @State private var isFavourited: Bool = false
    
    @State private var showAlert: AnyAppAlert?
    
    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif
    
    var body: some View {
        List {
            if let url = ingredientTemplate.imageURL {
                imageSection(url: url)
            }
            macroNutrientSection
            essentialMacroMineralsSection
            essentialTraceMineralsSection
            fatSolubleVitaminsSection
            waterSolubleVitaminsSection
            bioactiveCompoundsSection
            dateCreatedSection
            if let authorId = ingredientTemplate.authorId {
                authorSection(id: authorId)
            }
        }
        .navigationTitle(ingredientTemplate.name)
        .navigationSubtitle(ingredientTemplate.description ?? "")
        .navigationBarTitleDisplayMode(.large)
        .showCustomAlert(alert: $showAlert)
        .screenAppearAnalytics(name: "IngredientDetailView")
        .toolbar {
            toolbarContent
        }
        .task { await loadInitialState() }
        .onChange(of: userManager.currentUser) { _, _ in
            let user = userManager.currentUser
            let isAuthor = user?.userId == ingredientTemplate.authorId
            isBookmarked = isAuthor || (user?.bookmarkedIngredientTemplateIds?.contains(ingredientTemplate.id) ?? false) || (user?.createdIngredientTemplateIds?.contains(ingredientTemplate.id) ?? false)
            isFavourited = user?.favouritedIngredientTemplateIds?.contains(ingredientTemplate.id) ?? false
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $showDebugView) {
            DevSettingsView(viewModel: DevSettingsViewModel(container: container))
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
            rowItem(label: "Calories", value: ingredientTemplate.calories, unit: "kcal")

            // Macronutrient composition
            rowItem(label: "Protein", value: ingredientTemplate.protein, unit: "g")
            rowItem(label: "Carbohydrates", value: ingredientTemplate.carbs, unit: "g")
            rowItem(label: "Total Fat", value: ingredientTemplate.fatTotal, unit: "g")
            
            // Fat breakdown
            if ingredientTemplate.fatSaturated != nil || ingredientTemplate.fatMonounsaturated != nil || ingredientTemplate.fatPolyunsaturated != nil {
                rowItem(label: "Saturated Fat", value: ingredientTemplate.fatSaturated, unit: "g")
                rowItem(label: "Monounsaturated Fat", value: ingredientTemplate.fatMonounsaturated, unit: "g")
                rowItem(label: "Polyunsaturated Fat", value: ingredientTemplate.fatPolyunsaturated, unit: "g")
            }

            // Carbohydrate breakdown
            if ingredientTemplate.fiber != nil || ingredientTemplate.sugar != nil {
                rowItem(label: "Dietary Fiber", value: ingredientTemplate.fiber, unit: "g")
                rowItem(label: "Total Sugars", value: ingredientTemplate.sugar, unit: "g")
            }
        } header: {
            Text("Nutrition Information (per 100g)")
        }
    }

    private var essentialMacroMineralsSection: some View {
        Section {
            // Essential Macrominerals - Required in larger amounts
            rowItem(label: "Calcium", value: ingredientTemplate.calciumMg, unit: "mg")
            rowItem(label: "Phosphorus", value: ingredientTemplate.phosphorusMg, unit: "mg")
            rowItem(label: "Magnesium", value: ingredientTemplate.magnesiumMg, unit: "mg")
            rowItem(label: "Sodium", value: ingredientTemplate.sodiumMg, unit: "mg")
            rowItem(label: "Potassium", value: ingredientTemplate.potassiumMg, unit: "mg")
            rowItem(label: "Chloride", value: ingredientTemplate.chlorideMg, unit: "mg")
        } header: {
            Text("Essential Macrominerals (per 100g)")
        }
    }

    private var essentialTraceMineralsSection: some View {
        Section {
            // Essential Trace Minerals - Required in smaller amounts
            rowItem(label: "Iron", value: ingredientTemplate.ironMg, unit: "mg")
            rowItem(label: "Zinc", value: ingredientTemplate.zincMg, unit: "mg")
            rowItem(label: "Copper", value: ingredientTemplate.copperMg, unit: "mg")
            rowItem(label: "Manganese", value: ingredientTemplate.manganeseMg, unit: "mg")
            rowItem(label: "Iodine", value: ingredientTemplate.iodineMcg, unit: "μg")
            rowItem(label: "Selenium", value: ingredientTemplate.seleniumMcg, unit: "μg")
            rowItem(label: "Molybdenum", value: ingredientTemplate.molybdenumMcg, unit: "μg")
            rowItem(label: "Chromium", value: ingredientTemplate.chromiumMcg, unit: "μg")
        } header: {
            Text("Essential Trace Minerals (per 100g)")
        }
    }

    private var fatSolubleVitaminsSection: some View {
        Section {
            // Fat-Soluble Vitamins - A, D, E, K
            rowItem(label: "Vitamin A", value: ingredientTemplate.vitaminAMcg, unit: " mcg RAE")
            rowItem(label: "Vitamin D", value: ingredientTemplate.vitaminDMcg, unit: " mcg")
            rowItem(label: "Vitamin E", value: ingredientTemplate.vitaminEMg, unit: " mg α-tocopherol")
            rowItem(label: "Vitamin K", value: ingredientTemplate.vitaminKMcg, unit: " mcg")
        } header: {
            Text("Fat-Soluble Vitamins (per 100g)")
        }
    }

    private var waterSolubleVitaminsSection: some View {
        Section {
            // Water-Soluble Vitamins - B-Complex & C
            rowItem(label: "Thiamin - B1", value: ingredientTemplate.thiaminMg, unit: " mg")
            rowItem(label: "Riboflavin - B2", value: ingredientTemplate.riboflavinMg, unit: " mg")
            rowItem(label: "Niacin - B3", value: ingredientTemplate.niacinMg, unit: " mg NE")
            rowItem(label: "Pantothenic Acid - B5", value: ingredientTemplate.pantothenicAcidMg, unit: " mg")
            rowItem(label: "Vitamin B6", value: ingredientTemplate.vitaminB6Mg, unit: " mg")
            rowItem(label: "Folate - B9", value: ingredientTemplate.folateMcg, unit: " mcg DFE")
            rowItem(label: "Vitamin B12", value: ingredientTemplate.vitaminB12Mcg, unit: " mcg")
            rowItem(label: "Biotin - B7", value: ingredientTemplate.biotinMcg, unit: " mcg")
            rowItem(label: "Vitamin C", value: ingredientTemplate.vitaminCMg, unit: " mg")
        } header: {
            Text("Water-Soluble Vitamins (per 100g)")
        }
    }

    private var bioactiveCompoundsSection: some View {
        Section {
            // Bioactive Compounds
            rowItem(label: "Cholesterol", value: ingredientTemplate.cholesterolMg, unit: " mg")
            rowItem(label: "Caffeine", value: ingredientTemplate.caffeineMg, unit: " mg")
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
            Text(ingredientTemplate.dateCreated.formatted(date: .abbreviated, time: .omitted))
        }
    }

    private func authorSection(id: String) -> some View {
        Section(header: Text("Author ID")) {
            Text(id)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }

    private func loadInitialState() async {
        let user = userManager.currentUser
        // Always treat authored templates as bookmarked
        let isAuthor = user?.userId == ingredientTemplate.authorId
        isBookmarked = isAuthor || (user?.bookmarkedIngredientTemplateIds?.contains(ingredientTemplate.id) ?? false) || (user?.createdIngredientTemplateIds?.contains(ingredientTemplate.id) ?? false)
        isFavourited = user?.favouritedIngredientTemplateIds?.contains(ingredientTemplate.id) ?? false
    }
    
    private func onBookmarkPressed() async {
        logManager.trackEvent(event: Event.bookmarkIngredientStart)
        let newState = !isBookmarked
        do {
            // If unbookmarking and currently favourited, unfavourite first to enforce rule
            if !newState && isFavourited {
                try await ingredientTemplateManager.favouriteIngredientTemplate(id: ingredientTemplate.id, isFavourited: false)
                isFavourited = false
                // Remove from user's favourited list
                try await userManager.removeFavouritedIngredientTemplate(ingredientId: ingredientTemplate.id)
            }
            try await ingredientTemplateManager.bookmarkIngredientTemplate(id: ingredientTemplate.id, isBookmarked: newState)
            if newState {
                try await userManager.addBookmarkedIngredientTemplate(ingredientId: ingredientTemplate.id)
            } else {
                try await userManager.removeBookmarkedIngredientTemplate(ingredientId: ingredientTemplate.id)
            }
            isBookmarked = newState
            logManager.trackEvent(event: Event.bookmarkIngredientSuccess)
        } catch {
            logManager.trackEvent(event: Event.bookmarkIngredientFail(error: error))
            showAlert = AnyAppAlert(title: "Failed to update bookmark status", subtitle: "Please try again later")
        }
    }
    
    private func onFavoritePressed() async {
        logManager.trackEvent(event: Event.favouriteIngredientSuccess)
        let newState = !isFavourited
        do {
            // If favouriting and not bookmarked, bookmark first to enforce rule
            if newState && !isBookmarked {
                try await ingredientTemplateManager.bookmarkIngredientTemplate(id: ingredientTemplate.id, isBookmarked: true)
                try await userManager.addBookmarkedIngredientTemplate(ingredientId: ingredientTemplate.id)
                isBookmarked = true
            }
            try await ingredientTemplateManager.favouriteIngredientTemplate(id: ingredientTemplate.id, isFavourited: newState)
            if newState {
                try await userManager.addFavouritedIngredientTemplate(ingredientId: ingredientTemplate.id)
            } else {
                try await userManager.removeFavouritedIngredientTemplate(ingredientId: ingredientTemplate.id)
            }
            isFavourited = newState
            logManager.trackEvent(event: Event.favouriteIngredientSuccess)
        } catch {
            logManager.trackEvent(event: Event.favouriteIngredientFail(error: error))
            showAlert = AnyAppAlert(title: "Failed to update favourite status", subtitle: "Please try again later")
        }
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
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                Task {
                    await onFavoritePressed()
                }
            } label: {
                Image(systemName: isFavourited ? "heart.fill" : "heart")
            }
        }
        // Hide bookmark button when the current user is the author
        if userManager.currentUser?.userId != nil && userManager.currentUser?.userId != ingredientTemplate.authorId {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        await onBookmarkPressed()
                    }
                } label: {
                    Image(systemName: isBookmarked ? "book.closed.fill" : "book.closed")
                }
            }
        }
    }

    enum Event: LoggableEvent {
        case favouriteIngredientStart
        case favouriteIngredientSuccess
        case favouriteIngredientFail(error: Error)
        case bookmarkIngredientStart
        case bookmarkIngredientSuccess
        case bookmarkIngredientFail(error: Error)

        var eventName: String {
            switch self {
            case .favouriteIngredientStart:    return "IngredientDetailView_Favourite_Start"
            case .favouriteIngredientSuccess:  return "IngredientDetailView_Favourite_Success"
            case .favouriteIngredientFail:     return "IngredientDetailView_Favourite_Fail"
            case .bookmarkIngredientStart:    return "IngredientDetailView_Bookmark_Start"
            case .bookmarkIngredientSuccess:  return "IngredientDetailView_Bookmark_Success"
            case .bookmarkIngredientFail:     return "IngredientDetailView_Bookmark_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .favouriteIngredientFail(error: let error), .bookmarkIngredientFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .favouriteIngredientFail, .bookmarkIngredientFail:
                return .severe
            default:
                return .analytic

            }
        }
    }
}

#Preview {
    NavigationStack {
        IngredientDetailView(ingredientTemplate: IngredientTemplateModel.mocks[0])
    }
    .previewEnvironment()
}
