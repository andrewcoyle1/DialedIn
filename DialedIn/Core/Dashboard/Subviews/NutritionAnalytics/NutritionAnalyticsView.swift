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
    }
    
    private var caloriesAndMacrosSection: some View {
        Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                DashboardCard(
                    title: "Macros",
                    subtitle: "Last 7 Days",
                    subsubtitle: "824",
                    subsubsubtitle: "kcal",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Calories",
                    subtitle: "Today",
                    subsubtitle: "824",
                    subsubsubtitle: "kcal",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Protein",
                    subtitle: "Today",
                    subsubtitle: "48.3",
                    subsubsubtitle: "g",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Calories",
                    subtitle: "Today",
                    subsubtitle: "29.2",
                    subsubsubtitle: "g",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Calories",
                    subtitle: "Today",
                    subsubtitle: "91.5",
                    subsubsubtitle: "g",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
            }
            .padding(.horizontal)
            .removeListRowFormatting()
        } header: {
            Text("Calories & Macros")
        }
    }
    
    private var carbBreakdownSection: some View {
        Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                DashboardCard(
                    title: "Fiber",
                    subtitle: "Today",
                    subsubtitle: "11.2",
                    subsubsubtitle: "g",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Net (Non-fiber)",
                    subtitle: "Today",
                    subsubtitle: "80.3",
                    subsubsubtitle: "g",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Starch",
                    subtitle: "Today",
                    subsubtitle: "0",
                    subsubsubtitle: "g",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Sugars",
                    subtitle: "Today",
                    subsubtitle: "7.7",
                    subsubsubtitle: "g",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Sugars Added",
                    subtitle: "Today",
                    subsubtitle: "0.6",
                    subsubsubtitle: "g",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
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
                DashboardCard(
                    title: "Monounsaturated",
                    subtitle: "Today",
                    subsubtitle: "1.2",
                    subsubsubtitle: "g",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Polyunsaturated",
                    subtitle: "Today",
                    subsubtitle: "1.4",
                    subsubsubtitle: "g",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Omega-3",
                    subtitle: "Today",
                    subsubtitle: "0.1",
                    subsubsubtitle: "g",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Omega-3 ALA",
                    subtitle: "Today",
                    subsubtitle: "0.1",
                    subsubsubtitle: "g",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Omega-3 DHA",
                    subtitle: "Today",
                    subsubtitle: "0",
                    subsubsubtitle: "g",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Omega-3 EPA",
                    subtitle: "Today",
                    subsubtitle: "0",
                    subsubsubtitle: "g",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Omega-6",
                    subtitle: "Today",
                    subsubtitle: "1.3",
                    subsubsubtitle: "g",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Saturated",
                    subtitle: "Today",
                    subsubtitle: "0.7",
                    subsubsubtitle: "g",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Trans Fat",
                    subtitle: "Today",
                    subsubtitle: "0",
                    subsubsubtitle: "g",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
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
                DashboardCard(
                    title: "Cysteine",
                    subtitle: "Today",
                    subsubtitle: "0.1",
                    subsubsubtitle: "g",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Histidine",
                    subtitle: "Today",
                    subsubtitle: "0.2",
                    subsubsubtitle: "g",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Isoleucine",
                    subtitle: "Today",
                    subsubtitle: "0.3",
                    subsubsubtitle: "g",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Leucine",
                    subtitle: "Today",
                    subsubtitle: "0.5",
                    subsubsubtitle: "g",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Lysine",
                    subtitle: "Today",
                    subsubtitle: "0.4",
                    subsubsubtitle: "g",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Methionine",
                    subtitle: "Today",
                    subsubtitle: "0.1",
                    subsubsubtitle: "g",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Phenylaninine",
                    subtitle: "Today",
                    subsubtitle: "0.3",
                    subsubsubtitle: "g",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Threonine",
                    subtitle: "Today",
                    subsubtitle: "0.3",
                    subsubsubtitle: "g",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Tryptophan",
                    subtitle: "Today",
                    subsubtitle: "0.1",
                    subsubsubtitle: "g",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Tyrosine",
                    subtitle: "Today",
                    subsubtitle: "0.2",
                    subsubsubtitle: "g",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Valine",
                    subtitle: "Today",
                    subsubtitle: "0.4",
                    subsubsubtitle: "g",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
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
                DashboardCard(
                    title: "B1, Thiamine",
                    subtitle: "Today",
                    subsubtitle: "0.2",
                    subsubsubtitle: "mg",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "B2, Riboflavin",
                    subtitle: "Today",
                    subsubtitle: "0.3",
                    subsubsubtitle: "mg",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "B3, Niacin",
                    subtitle: "Today",
                    subsubtitle: "2.2",
                    subsubsubtitle: "mg",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "B5, Pantothenic Acid",
                    subtitle: "Today",
                    subsubtitle: "0.4",
                    subsubsubtitle: "mg",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "B6, Pyridoxine",
                    subtitle: "Today",
                    subsubtitle: "0.2",
                    subsubsubtitle: "mg",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "B12, Cobalamin",
                    subtitle: "Today",
                    subsubtitle: "0",
                    subsubsubtitle: "mcg",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Folate",
                    subtitle: "Today",
                    subsubtitle: "55.4",
                    subsubsubtitle: "mcg",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Vitamin A",
                    subtitle: "Today",
                    subsubtitle: "451.1",
                    subsubsubtitle: "mcg",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Vitamin C",
                    subtitle: "Today",
                    subsubtitle: "11",
                    subsubsubtitle: "mg",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Vitamin D",
                    subtitle: "Today",
                    subsubtitle: "0",
                    subsubsubtitle: "mcg",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Vitamin E",
                    subtitle: "Today",
                    subsubtitle: "1",
                    subsubsubtitle: "mg",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Vitamin K",
                    subtitle: "Today",
                    subsubtitle: "96",
                    subsubsubtitle: "mcg",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }

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
                DashboardCard(
                    title: "Calcium",
                    subtitle: "Today",
                    subsubtitle: "71.7",
                    subsubsubtitle: "mg",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Copper",
                    subtitle: "Today",
                    subsubtitle: "0.3",
                    subsubsubtitle: "mg",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Iron",
                    subtitle: "Today",
                    subsubtitle: "2.3",
                    subsubsubtitle: "mg",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Magnesium",
                    subtitle: "Today",
                    subsubtitle: "65.8",
                    subsubsubtitle: "mg",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Manganese",
                    subtitle: "Today",
                    subsubtitle: "0.9",
                    subsubsubtitle: "mg",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Phosphorus",
                    subtitle: "Today",
                    subsubtitle: "145",
                    subsubsubtitle: "mg",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Potassium",
                    subtitle: "Today",
                    subsubtitle: "434.8",
                    subsubsubtitle: "mg",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Selenium",
                    subtitle: "Today",
                    subsubtitle: "2.4",
                    subsubsubtitle: "mcg",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Sodium",
                    subtitle: "Today",
                    subsubtitle: "389.5",
                    subsubsubtitle: "mg",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Zinc",
                    subtitle: "Today",
                    subsubtitle: "1.4",
                    subsubsubtitle: "mg",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }

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
                DashboardCard(
                    title: "Alcohol",
                    subtitle: "Today",
                    subsubtitle: "0",
                    subsubsubtitle: "g",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Caffeine",
                    subtitle: "Today",
                    subsubtitle: "0",
                    subsubsubtitle: "mg",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Cholesterol",
                    subtitle: "Today",
                    subsubtitle: "0",
                    subsubsubtitle: "mg",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Choline",
                    subtitle: "Today",
                    subsubtitle: "51.8",
                    subsubsubtitle: "mg",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
                DashboardCard(
                    title: "Water",
                    subtitle: "Today",
                    subsubtitle: "285.1",
                    subsubsubtitle: "g",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                )
                .tappableBackground()
                .anyButton(.press) {
                    
                }
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
        router.showScreen(.push) { router in
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
