import SwiftUI

struct NutritionAnalyticsDelegate {
    
}

struct NutritionAnalyticsView: View {
    
    @Environment(\.scenePhase) private var scenePhase
    @State var presenter: NutritionAnalyticsPresenter
    let delegate: NutritionAnalyticsDelegate
    
    var body: some View {
        List {
            Group {
                caloriesAndMacrosSection
                carbBreakdownSection
                fatBreakdownSection
                proteinBreakdownSection
                vitaminBreakdownSection
                mineralBreakdownSection
                otherBreakdownSection
            }
            .listSectionMargins(.horizontal, 0)
            .listRowSeparator(.hidden)
        }
        .navigationTitle("Nutrition")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            presenter.onViewAppear()
        }
        .onDisappear {
            presenter.onViewDisappear()
        }
        .scrollIndicators(.hidden)
        .task {
            await presenter.loadData()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Task { await presenter.loadData() }
            }
        }
        .onNotificationReceived(name: Constants.remoteDataSyncDidComplete) { _ in
            Task { await presenter.loadData() }
        }
    }
    
    private var caloriesAndMacrosSection: some View {
        let proteinColor = MacroProgressChart.proteinColor
        let caloriesColor = Color.blue
        let fatColor = MacroProgressChart.fatColor
        let carbsColor = MacroProgressChart.carbsColor
        return breakdownSection(header: "Calories & Macros") {
            AnalyticsCard(
                title: "Macros",
                subtitle: presenter.macrosLast7Days.isEmpty ? "No Data" : "Last 7 Days",
                subsubtitle: presenter.macrosLast7Days.isEmpty ? "--" : Int(presenter.macrosAverageCalories).formatted(),
                subsubsubtitle: "kcal",
                themeColor: proteinColor,
                chartConfiguration: .compact,
                chart: {
                    let chartData = presenter.macrosLast7Days.isEmpty
                        ? Array(repeating: DailyMacroTarget(calories: 0, proteinGrams: 0, carbGrams: 0, fatGrams: 0), count: 7)
                        : presenter.macrosLast7Days
                    return MacroStackedBarChart(data: chartData)
                }
            )
            .analyticsCardButton {
                presenter.onMacrosPressed(themeColor: proteinColor)
            }
            macroCard(
                title: "Calories",
                card: MacroCard(value: presenter.caloriesCurrent, target: presenter.caloriesTarget, maxValue: presenter.caloriesMax, unit: "kcal"),
                color: caloriesColor,
                action: { presenter.onCaloriesPressed(themeColor: caloriesColor) }
            )
            macroCard(
                title: "Protein",
                card: MacroCard(value: presenter.proteinCurrent, target: presenter.proteinTarget, maxValue: presenter.proteinMax, unit: "g"),
                color: proteinColor,
                action: { presenter.onProteinPressed(themeColor: proteinColor) }
            )
            macroCard(
                title: "Fat",
                card: MacroCard(value: presenter.fatCurrent, target: presenter.fatTarget, maxValue: presenter.fatMax, unit: "g"),
                color: fatColor,
                action: { presenter.onFatPressed(themeColor: fatColor) }
            )
            macroCard(
                title: "Carbs",
                card: MacroCard(value: presenter.carbsCurrent, target: presenter.carbsTarget, maxValue: presenter.carbsMax, unit: "g"),
                color: carbsColor,
                action: { presenter.onCarbsPressed(themeColor: carbsColor) }
            )
        }
    }

    /// One macro's today-against-target numbers, bundled so the card takes a value rather than
    /// five loose parameters.
    struct MacroCard {
        let value: Double
        let target: Double?
        let maxValue: Double
        let unit: String
        /// kcal reads as a whole number; grams to one decimal place.
        var decimals: Int { unit == "kcal" ? 0 : 1 }
    }

    /// The today-against-target card the four macros share.
    private func macroCard(
        title: String,
        card: MacroCard,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        AnalyticsCard(
            title: title,
            subtitle: presenter.dailyTotals != nil ? "Today" : "No Data",
            subsubtitle: presenter.dailyTotals != nil
                ? card.value.formatted(.number.precision(.fractionLength(card.decimals)))
                : "--",
            subsubsubtitle: card.unit,
            themeColor: color,
            chartConfiguration: .compact,
            chart: {
                MacroProgressChart(
                    current: card.value,
                    target: card.target,
                    maxValue: card.maxValue,
                    color: color
                )
            }
        )
        .analyticsCardButton(action: action)
    }

    /// Every breakdown list is the same grid under the same header.
    private func breakdownSection<Content: View>(
        header: String,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        Section {
            AnalyticsCardGrid(content: content)
        } header: {
            SectionHeaderView(title: header)
        }
    }

    /// `isTracked: false` marks a nutrient the food model carries no field for. Those cards used to
    /// look like every other one, show "--", and open a detail screen that was always empty
    /// whatever the user had logged. They now read as unavailable and do not take a tap.
    @ViewBuilder
    private func breakdownCard(
        title: String,
        metric: NutritionMetric,
        value: Double? = nil,
        isTracked: Bool = true,
        unit: String,
        color: Color
    ) -> some View {
        let card = AnalyticsCard(
            title: title,
            subtitle: isTracked ? "Today" : "Not Tracked",
            subsubtitle: isTracked ? presenter.formatBreakdown(value, unit: unit) : "--",
            subsubsubtitle: unit,
            themeColor: color,
            chartConfiguration: .compact,
            chart: {
                MacroProgressChart(
                    current: isTracked ? (value ?? 0) : 0,
                    target: nil,
                    maxValue: presenter.breakdownChartMax(current: value, defaultMax: 50),
                    color: color
                )
            }
        )

        if isTracked {
            card.analyticsCardButton {
                presenter.onBreakdownMetricPressed(metric, themeColor: color)
            }
        } else {
            card
                .opacity(0.5)
                .allowsHitTesting(false)
        }
    }

    private var carbBreakdownSection: some View {
        breakdownSection(header: "Carb Breakdown") {
            breakdownCard(title: "Fiber", metric: .fiber, value: presenter.dailyBreakdown?.fiberGrams, unit: "g", color: MacroProgressChart.carbsColor)
            breakdownCard(title: "Net (Non-fiber)", metric: .netCarbs, value: presenter.dailyBreakdown?.netCarbsGrams, unit: "g", color: MacroProgressChart.carbsColor)
            breakdownCard(title: "Starch", metric: .starch, isTracked: false, unit: "g", color: MacroProgressChart.carbsColor)
            breakdownCard(title: "Sugars", metric: .sugars, value: presenter.dailyBreakdown?.sugarGrams, unit: "g", color: MacroProgressChart.carbsColor)
            breakdownCard(title: "Sugars Added", metric: .sugarsAdded, isTracked: false, unit: "g", color: MacroProgressChart.carbsColor)
        }
    }
    
    private var fatBreakdownSection: some View {
        breakdownSection(header: "Fat Breakdown") {
            breakdownCard(title: "Monounsaturated", metric: .fatMono, value: presenter.dailyBreakdown?.fatMonounsaturatedGrams, unit: "g", color: MacroProgressChart.fatColor)
            breakdownCard(title: "Polyunsaturated", metric: .fatPoly, value: presenter.dailyBreakdown?.fatPolyunsaturatedGrams, unit: "g", color: MacroProgressChart.fatColor)
            breakdownCard(title: "Omega-3", metric: .omega3, isTracked: false, unit: "g", color: MacroProgressChart.fatColor)
            breakdownCard(title: "Omega-3 ALA", metric: .omega3ALA, isTracked: false, unit: "g", color: MacroProgressChart.fatColor)
            breakdownCard(title: "Omega-3 DHA", metric: .omega3DHA, isTracked: false, unit: "g", color: MacroProgressChart.fatColor)
            breakdownCard(title: "Omega-3 EPA", metric: .omega3EPA, isTracked: false, unit: "g", color: MacroProgressChart.fatColor)
            breakdownCard(title: "Omega-6", metric: .omega6, isTracked: false, unit: "g", color: MacroProgressChart.fatColor)
            breakdownCard(title: "Saturated", metric: .fatSaturated, value: presenter.dailyBreakdown?.fatSaturatedGrams, unit: "g", color: MacroProgressChart.fatColor)
            breakdownCard(title: "Trans Fat", metric: .transFat, isTracked: false, unit: "g", color: MacroProgressChart.fatColor)
        }
    }
    
    private var proteinBreakdownSection: some View {
        breakdownSection(header: "Protein Breakdown") {
            breakdownCard(title: "Cysteine", metric: .cysteine, isTracked: false, unit: "g", color: MacroProgressChart.proteinColor)
            breakdownCard(title: "Histidine", metric: .histidine, isTracked: false, unit: "g", color: MacroProgressChart.proteinColor)
            breakdownCard(title: "Isoleucine", metric: .isoleucine, isTracked: false, unit: "g", color: MacroProgressChart.proteinColor)
            breakdownCard(title: "Leucine", metric: .leucine, isTracked: false, unit: "g", color: MacroProgressChart.proteinColor)
            breakdownCard(title: "Lysine", metric: .lysine, isTracked: false, unit: "g", color: MacroProgressChart.proteinColor)
            breakdownCard(title: "Methionine", metric: .methionine, isTracked: false, unit: "g", color: MacroProgressChart.proteinColor)
            breakdownCard(title: "Phenylalanine", metric: .phenylalanine, isTracked: false, unit: "g", color: MacroProgressChart.proteinColor)
            breakdownCard(title: "Threonine", metric: .threonine, isTracked: false, unit: "g", color: MacroProgressChart.proteinColor)
            breakdownCard(title: "Tryptophan", metric: .tryptophan, isTracked: false, unit: "g", color: MacroProgressChart.proteinColor)
            breakdownCard(title: "Tyrosine", metric: .tyrosine, isTracked: false, unit: "g", color: MacroProgressChart.proteinColor)
            breakdownCard(title: "Valine", metric: .valine, isTracked: false, unit: "g", color: MacroProgressChart.proteinColor)
        }
    }
    
    private var vitaminBreakdownSection: some View {
        breakdownSection(header: "Vitamin Breakdown") {
            breakdownCard(title: "B1, Thiamine", metric: .thiamin, value: presenter.dailyBreakdown?.thiaminMg, unit: "mg", color: MacroProgressChart.vitaminColor)
            breakdownCard(title: "B2, Riboflavin", metric: .riboflavin, value: presenter.dailyBreakdown?.riboflavinMg, unit: "mg", color: MacroProgressChart.vitaminColor)
            breakdownCard(title: "B3, Niacin", metric: .niacin, value: presenter.dailyBreakdown?.niacinMg, unit: "mg", color: MacroProgressChart.vitaminColor)
            breakdownCard(title: "B5, Pantothenic Acid", metric: .pantothenicAcid, value: presenter.dailyBreakdown?.pantothenicAcidMg, unit: "mg", color: MacroProgressChart.vitaminColor)
            breakdownCard(title: "B6, Pyridoxine", metric: .vitaminB6, value: presenter.dailyBreakdown?.vitaminB6Mg, unit: "mg", color: MacroProgressChart.vitaminColor)
            breakdownCard(title: "B12, Cobalamin", metric: .vitaminB12, value: presenter.dailyBreakdown?.vitaminB12Mcg, unit: "mcg", color: MacroProgressChart.vitaminColor)
            breakdownCard(title: "Folate", metric: .folate, value: presenter.dailyBreakdown?.folateMcg, unit: "mcg", color: MacroProgressChart.vitaminColor)
            breakdownCard(title: "Vitamin A", metric: .vitaminA, value: presenter.dailyBreakdown?.vitaminAMcg, unit: "mcg", color: MacroProgressChart.vitaminColor)
            breakdownCard(title: "Vitamin C", metric: .vitaminC, value: presenter.dailyBreakdown?.vitaminCMg, unit: "mg", color: MacroProgressChart.vitaminColor)
            breakdownCard(title: "Vitamin D", metric: .vitaminD, value: presenter.dailyBreakdown?.vitaminDMcg, unit: "mcg", color: MacroProgressChart.vitaminColor)
            breakdownCard(title: "Vitamin E", metric: .vitaminE, value: presenter.dailyBreakdown?.vitaminEMg, unit: "mg", color: MacroProgressChart.vitaminColor)
            breakdownCard(title: "Vitamin K", metric: .vitaminK, value: presenter.dailyBreakdown?.vitaminKMcg, unit: "mcg", color: MacroProgressChart.vitaminColor)
        }
    }
    
    private var mineralBreakdownSection: some View {
        breakdownSection(header: "Mineral Breakdown") {
            breakdownCard(title: "Calcium", metric: .calcium, value: presenter.dailyBreakdown?.calciumMg, unit: "mg", color: MacroProgressChart.mineralColor)
            breakdownCard(title: "Copper", metric: .copper, value: presenter.dailyBreakdown?.copperMg, unit: "mg", color: MacroProgressChart.mineralColor)
            breakdownCard(title: "Iron", metric: .iron, value: presenter.dailyBreakdown?.ironMg, unit: "mg", color: MacroProgressChart.mineralColor)
            breakdownCard(title: "Magnesium", metric: .magnesium, value: presenter.dailyBreakdown?.magnesiumMg, unit: "mg", color: MacroProgressChart.mineralColor)
            breakdownCard(title: "Manganese", metric: .manganese, value: presenter.dailyBreakdown?.manganeseMg, unit: "mg", color: MacroProgressChart.mineralColor)
            breakdownCard(title: "Phosphorus", metric: .phosphorus, value: presenter.dailyBreakdown?.phosphorusMg, unit: "mg", color: MacroProgressChart.mineralColor)
            breakdownCard(title: "Potassium", metric: .potassium, value: presenter.dailyBreakdown?.potassiumMg, unit: "mg", color: MacroProgressChart.mineralColor)
            breakdownCard(title: "Selenium", metric: .selenium, value: presenter.dailyBreakdown?.seleniumMcg, unit: "mcg", color: MacroProgressChart.mineralColor)
            breakdownCard(title: "Sodium", metric: .sodium, value: presenter.dailyBreakdown?.sodiumMg, unit: "mg", color: MacroProgressChart.mineralColor)
            breakdownCard(title: "Zinc", metric: .zinc, value: presenter.dailyBreakdown?.zincMg, unit: "mg", color: MacroProgressChart.mineralColor)
        }
    }
    
    private var otherBreakdownSection: some View {
        breakdownSection(header: "Other Breakdown") {
            breakdownCard(title: "Alcohol", metric: .alcohol, isTracked: false, unit: "g", color: MacroProgressChart.otherColor)
            breakdownCard(title: "Caffeine", metric: .caffeine, value: presenter.dailyBreakdown?.caffeineMg, unit: "mg", color: MacroProgressChart.otherColor)
            breakdownCard(title: "Cholesterol", metric: .cholesterol, value: presenter.dailyBreakdown?.cholesterolMg, unit: "mg", color: MacroProgressChart.otherColor)
            breakdownCard(title: "Choline", metric: .choline, isTracked: false, unit: "mg", color: MacroProgressChart.otherColor)
            breakdownCard(title: "Water", metric: .water, isTracked: false, unit: "g", color: MacroProgressChart.otherColor)
        }
    }
}

extension CoreBuilder {
    
    func nutritionAnalyticsView(router: AnyRouter, delegate: NutritionAnalyticsDelegate) -> some View {
        NutritionAnalyticsView(
            presenter: NutritionAnalyticsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showNutritionAnalyticsView(delegate: NutritionAnalyticsDelegate) {
        router.showScreen(.sheet) { router in
            builder.nutritionAnalyticsView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = NutritionAnalyticsDelegate()
    
    return RouterView { router in
        builder.nutritionAnalyticsView(router: router, delegate: delegate)
    }
    
}
