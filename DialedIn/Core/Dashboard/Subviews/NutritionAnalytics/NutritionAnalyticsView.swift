import SwiftUI

struct NutritionAnalyticsDelegate {
    
}

struct NutritionAnalyticsView: View {
    
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
        .screenAppearAnalytics(name: "NutritionAnalyticsView")
        .scrollIndicators(.hidden)
        .task {
            await presenter.loadData()
        }
    }
    
    private var caloriesAndMacrosSection: some View {
        Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                DashboardCard(
                    title: "Macros",
                    subtitle: "Last 7 Days",
                    subsubtitle: presenter.macrosLast7Days.isEmpty ? "--" : Int(presenter.macrosAverageCalories).formatted(),
                    subsubsubtitle: "kcal",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2),
                    chart: {
                        let chartData = presenter.macrosLast7Days.isEmpty
                            ? Array(repeating: DailyMacroTarget(calories: 0, proteinGrams: 0, carbGrams: 0, fatGrams: 0), count: 7)
                            : presenter.macrosLast7Days
                        return MacroStackedBarChart(data: chartData)
                    }
                )
                .tappableBackground()
                .anyButton(.press) {
                    presenter.onMacrosPressed()
                }
                DashboardCard(
                    title: "Calories",
                    subtitle: "Today",
                    subsubtitle: presenter.dailyTotals != nil ? Int(presenter.caloriesCurrent).formatted() : "--",
                    subsubsubtitle: "kcal",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2),
                    chart: {
                        MacroProgressChart(
                            current: presenter.caloriesCurrent,
                            target: presenter.caloriesTarget,
                            maxValue: presenter.caloriesMax,
                            color: .blue
                        )
                    }
                )
                .tappableBackground()
                .anyButton(.press) {
                    presenter.onCaloriesPressed()
                }
                DashboardCard(
                    title: "Protein",
                    subtitle: "Today",
                    subsubtitle: presenter.dailyTotals != nil ? presenter.proteinCurrent.formatted(.number.precision(.fractionLength(1))) : "--",
                    subsubsubtitle: "g",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2),
                    chart: {
                        MacroProgressChart(
                            current: presenter.proteinCurrent,
                            target: presenter.proteinTarget,
                            maxValue: presenter.proteinMax,
                            color: MacroProgressChart.proteinColor
                        )
                    }
                )
                .tappableBackground()
                .anyButton(.press) {
                    presenter.onProteinPressed()
                }
                DashboardCard(
                    title: "Fat",
                    subtitle: "Today",
                    subsubtitle: presenter.dailyTotals != nil ? presenter.fatCurrent.formatted(.number.precision(.fractionLength(1))) : "--",
                    subsubsubtitle: "g",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2),
                    chart: {
                        MacroProgressChart(
                            current: presenter.fatCurrent,
                            target: presenter.fatTarget,
                            maxValue: presenter.fatMax,
                            color: MacroProgressChart.fatColor
                        )
                    }
                )
                .tappableBackground()
                .anyButton(.press) {
                    presenter.onFatPressed()
                }
                DashboardCard(
                    title: "Carbs",
                    subtitle: "Today",
                    subsubtitle: presenter.dailyTotals != nil ? presenter.carbsCurrent.formatted(.number.precision(.fractionLength(1))) : "--",
                    subsubsubtitle: "g",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2),
                    chart: {
                        MacroProgressChart(
                            current: presenter.carbsCurrent,
                            target: presenter.carbsTarget,
                            maxValue: presenter.carbsMax,
                            color: MacroProgressChart.carbsColor
                        )
                    }
                )
                .tappableBackground()
                .anyButton(.press) {
                    presenter.onCarbsPressed()
                }
            }
            .padding(.horizontal)
            .removeListRowFormatting()
        } header: {
            Text("Calories & Macros")
        }
    }
    
    @ViewBuilder
    private func breakdownCard(title: String, metric: NutritionMetric, value: Double?, unit: String, color: Color) -> some View {
        DashboardCard(
            title: title,
            subtitle: "Today",
            subsubtitle: presenter.formatBreakdown(value, unit: unit),
            subsubsubtitle: unit,
            chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2),
            chart: {
                MacroProgressChart(
                    current: value ?? 0,
                    target: nil,
                    maxValue: presenter.breakdownChartMax(current: value, defaultMax: 50),
                    color: color
                )
            }
        )
        .tappableBackground()
        .anyButton(.press) {
            presenter.onBreakdownMetricPressed(metric)
        }
    }
    
    private var carbBreakdownSection: some View {
        Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                breakdownCard(title: "Fiber", metric: .fiber, value: presenter.dailyBreakdown?.fiberGrams, unit: "g", color: MacroProgressChart.carbsColor)
                breakdownCard(title: "Net (Non-fiber)", metric: .netCarbs, value: presenter.dailyBreakdown?.netCarbsGrams, unit: "g", color: MacroProgressChart.carbsColor)
                breakdownCard(title: "Starch", metric: .starch, value: nil, unit: "g", color: MacroProgressChart.carbsColor)
                breakdownCard(title: "Sugars", metric: .sugars, value: presenter.dailyBreakdown?.sugarGrams, unit: "g", color: MacroProgressChart.carbsColor)
                breakdownCard(title: "Sugars Added", metric: .sugarsAdded, value: nil, unit: "g", color: MacroProgressChart.carbsColor)
            }
            .padding(.horizontal)
            .removeListRowFormatting()
        } header: {
            Text("Carb Breakdown")
        }
    }
    
    private var fatBreakdownSection: some View {
        Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                breakdownCard(title: "Monounsaturated", metric: .fatMono, value: presenter.dailyBreakdown?.fatMonounsaturatedGrams, unit: "g", color: MacroProgressChart.fatColor)
                breakdownCard(title: "Polyunsaturated", metric: .fatPoly, value: presenter.dailyBreakdown?.fatPolyunsaturatedGrams, unit: "g", color: MacroProgressChart.fatColor)
                breakdownCard(title: "Omega-3", metric: .omega3, value: nil, unit: "g", color: MacroProgressChart.fatColor)
                breakdownCard(title: "Omega-3 ALA", metric: .omega3ALA, value: nil, unit: "g", color: MacroProgressChart.fatColor)
                breakdownCard(title: "Omega-3 DHA", metric: .omega3DHA, value: nil, unit: "g", color: MacroProgressChart.fatColor)
                breakdownCard(title: "Omega-3 EPA", metric: .omega3EPA, value: nil, unit: "g", color: MacroProgressChart.fatColor)
                breakdownCard(title: "Omega-6", metric: .omega6, value: nil, unit: "g", color: MacroProgressChart.fatColor)
                breakdownCard(title: "Saturated", metric: .fatSaturated, value: presenter.dailyBreakdown?.fatSaturatedGrams, unit: "g", color: MacroProgressChart.fatColor)
                breakdownCard(title: "Trans Fat", metric: .transFat, value: nil, unit: "g", color: MacroProgressChart.fatColor)
            }
            .padding(.horizontal)
            .removeListRowFormatting()
        } header: {
            Text("Fat Breakdown")
        }
    }
    
    private var proteinBreakdownSection: some View {
        Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                breakdownCard(title: "Cysteine", metric: .cysteine, value: nil, unit: "g", color: MacroProgressChart.proteinColor)
                breakdownCard(title: "Histidine", metric: .histidine, value: nil, unit: "g", color: MacroProgressChart.proteinColor)
                breakdownCard(title: "Isoleucine", metric: .isoleucine, value: nil, unit: "g", color: MacroProgressChart.proteinColor)
                breakdownCard(title: "Leucine", metric: .leucine, value: nil, unit: "g", color: MacroProgressChart.proteinColor)
                breakdownCard(title: "Lysine", metric: .lysine, value: nil, unit: "g", color: MacroProgressChart.proteinColor)
                breakdownCard(title: "Methionine", metric: .methionine, value: nil, unit: "g", color: MacroProgressChart.proteinColor)
                breakdownCard(title: "Phenylalanine", metric: .phenylalanine, value: nil, unit: "g", color: MacroProgressChart.proteinColor)
                breakdownCard(title: "Threonine", metric: .threonine, value: nil, unit: "g", color: MacroProgressChart.proteinColor)
                breakdownCard(title: "Tryptophan", metric: .tryptophan, value: nil, unit: "g", color: MacroProgressChart.proteinColor)
                breakdownCard(title: "Tyrosine", metric: .tyrosine, value: nil, unit: "g", color: MacroProgressChart.proteinColor)
                breakdownCard(title: "Valine", metric: .valine, value: nil, unit: "g", color: MacroProgressChart.proteinColor)
            }
            .padding(.horizontal)
            .removeListRowFormatting()
        } header: {
            Text("Protein Breakdown")
        }
    }
    
    private var vitaminBreakdownSection: some View {
        Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
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
            .padding(.horizontal)
            .removeListRowFormatting()
        } header: {
            Text("Vitamin Breakdown")
        }
    }
    
    private var mineralBreakdownSection: some View {
        Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
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
            .padding(.horizontal)
            .removeListRowFormatting()
        } header: {
            Text("Mineral Breakdown")
        }
    }
    
    private var otherBreakdownSection: some View {
        Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                breakdownCard(title: "Alcohol", metric: .alcohol, value: nil, unit: "g", color: MacroProgressChart.otherColor)
                breakdownCard(title: "Caffeine", metric: .caffeine, value: presenter.dailyBreakdown?.caffeineMg, unit: "mg", color: MacroProgressChart.otherColor)
                breakdownCard(title: "Cholesterol", metric: .cholesterol, value: presenter.dailyBreakdown?.cholesterolMg, unit: "mg", color: MacroProgressChart.otherColor)
                breakdownCard(title: "Choline", metric: .choline, value: nil, unit: "mg", color: MacroProgressChart.otherColor)
                breakdownCard(title: "Water", metric: .water, value: nil, unit: "g", color: MacroProgressChart.otherColor)
            }
            .padding(.horizontal)
            .removeListRowFormatting()
        } header: {
            Text("Other Breakdown")
        }
    }
}

extension CoreBuilder {
    
    func nutritionAnalyticsView(router: Router, delegate: NutritionAnalyticsDelegate) -> some View {
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
    .previewEnvironment()
}
