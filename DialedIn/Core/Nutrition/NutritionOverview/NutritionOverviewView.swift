import SwiftUI

struct NutritionOverviewDelegate {
    var dayKey: String = Date().dayKey
    var eventParameters: [String: Any]? { nil }
}

struct NutritionOverviewView: View {

    @State var presenter: NutritionOverviewPresenter
    let delegate: NutritionOverviewDelegate

    var body: some View {
        List {
            caloriesSection
            contributorsSection
            macrosSection
            carbsSection
            fatsSection
            vitaminsSection
            mineralsSection
            otherSection
        }
        .navigationTitle("Nutrition Overview")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
    }

    // MARK: - Calories

    private var caloriesSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(Int(presenter.totals.calories)) kcal consumed")
                        .font(.headline)
                    Spacer()
                    if let target = presenter.target {
                        Text("/ \(Int(target.calories)) kcal")
                            .foregroundStyle(.secondary)
                    }
                }
                ProgressView(value: presenter.caloriesProgress)
                    .tint(.orange)
            }
            .padding(.vertical, 4)
        } header: {
            HStack {
                Text("Calories")
                Spacer()
                Toggle(isOn: $presenter.showsContributors) {
                    Text("Contributors")
                        .lineLimit(1)
                        .font(.subheadline)
                }
                .frame(width: 160)
            }
        }
    }

    // MARK: - Contributors

    @ViewBuilder
    private var contributorsSection: some View {
        if presenter.showsContributors && !presenter.topContributors.isEmpty {
            Section("Top Contributors") {
                ForEach(presenter.topContributors) { contributor in
                    contributorRow(contributor)
                }
            }
        }
    }

    private func contributorRow(_ contributor: MealItemContributor) -> some View {
        HStack {
            Text(contributor.displayName)
                .lineLimit(1)
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(contributor.calories)) kcal")
                    .font(.subheadline)
                HStack(spacing: 6) {
                    Text(String(format: "%.1f P", contributor.proteinGrams))
                    Text(String(format: "%.1f F", contributor.fatGrams))
                    Text(String(format: "%.1f C", contributor.carbGrams))
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }

    // MARK: - Macros

    private var macrosSection: some View {
        Section {
            macroRow(label: "Protein", grams: presenter.totals.proteinGrams, target: presenter.target?.proteinGrams, progress: presenter.proteinProgress, color: .blue)
            macroRow(label: "Carbs", grams: presenter.totals.carbGrams, target: presenter.target?.carbGrams, progress: presenter.carbsProgress, color: .green)
            macroRow(label: "Fat", grams: presenter.totals.fatGrams, target: presenter.target?.fatGrams, progress: presenter.fatProgress, color: .yellow)
        } header: {
            Text("Macros")
        }
    }

    private func macroRow(label: String, grams: Double, target: Double?, progress: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                Spacer()
                Text(grams > 0 ? "\(formatted(grams))g" : "—")
                    .foregroundStyle(.secondary)
                if let target {
                    Text("/ \(formatted(target))g")
                        .foregroundStyle(.tertiary)
                        .font(.caption)
                }
            }
            ProgressView(value: progress)
                .tint(color)
        }
        .padding(.vertical, 2)
    }

    // MARK: - Carb Breakdown

    @ViewBuilder
    private var carbsSection: some View {
        let breakdown = presenter.breakdown
        let items: [NutrientAmount] = [
            NutrientAmount(name: "Fiber", value: breakdown.fiberGrams, unit: "g"),
            NutrientAmount(name: "Sugar", value: breakdown.sugarGrams, unit: "g"),
            NutrientAmount(name: "Net Carbs", value: breakdown.netCarbsGrams, unit: "g")
        ]
        let available = items.filter { $0.value != nil }
        if !available.isEmpty {
            Section("Carb Breakdown") {
                ForEach(available, id: \.name) { nutrient in
                    nutrientRow(nutrient)
                }
            }
        }
    }

    // MARK: - Fat Breakdown

    @ViewBuilder
    private var fatsSection: some View {
        let breakdown = presenter.breakdown
        let items: [NutrientAmount] = [
            NutrientAmount(name: "Saturated", value: breakdown.fatSaturatedGrams, unit: "g"),
            NutrientAmount(name: "Monounsaturated", value: breakdown.fatMonounsaturatedGrams, unit: "g"),
            NutrientAmount(name: "Polyunsaturated", value: breakdown.fatPolyunsaturatedGrams, unit: "g")
        ]
        let available = items.filter { $0.value != nil }
        if !available.isEmpty {
            Section("Fat Breakdown") {
                ForEach(available, id: \.name) { nutrient in
                    nutrientRow(nutrient)
                }
            }
        }
    }

    // MARK: - Vitamins

    @ViewBuilder
    private var vitaminsSection: some View {
        let breakdown = presenter.breakdown
        let items: [NutrientAmount] = [
            NutrientAmount(name: "Vitamin A", value: breakdown.vitaminAMcg, unit: "mcg"),
            NutrientAmount(name: "Vitamin B6", value: breakdown.vitaminB6Mg, unit: "mg"),
            NutrientAmount(name: "Vitamin B12", value: breakdown.vitaminB12Mcg, unit: "mcg"),
            NutrientAmount(name: "Vitamin C", value: breakdown.vitaminCMg, unit: "mg"),
            NutrientAmount(name: "Vitamin D", value: breakdown.vitaminDMcg, unit: "mcg"),
            NutrientAmount(name: "Vitamin E", value: breakdown.vitaminEMg, unit: "mg"),
            NutrientAmount(name: "Vitamin K", value: breakdown.vitaminKMcg, unit: "mcg"),
            NutrientAmount(name: "Thiamin", value: breakdown.thiaminMg, unit: "mg"),
            NutrientAmount(name: "Riboflavin", value: breakdown.riboflavinMg, unit: "mg"),
            NutrientAmount(name: "Niacin", value: breakdown.niacinMg, unit: "mg"),
            NutrientAmount(name: "Pantothenic Acid", value: breakdown.pantothenicAcidMg, unit: "mg"),
            NutrientAmount(name: "Folate", value: breakdown.folateMcg, unit: "mcg")
        ]
        let available = items.filter { $0.value != nil }
        if !available.isEmpty {
            Section("Vitamins") {
                ForEach(available, id: \.name) { nutrient in
                    nutrientRow(nutrient)
                }
            }
        }
    }

    // MARK: - Minerals

    @ViewBuilder
    private var mineralsSection: some View {
        let breakdown = presenter.breakdown
        let items: [NutrientAmount] = [
            NutrientAmount(name: "Sodium", value: breakdown.sodiumMg, unit: "mg"),
            NutrientAmount(name: "Potassium", value: breakdown.potassiumMg, unit: "mg"),
            NutrientAmount(name: "Calcium", value: breakdown.calciumMg, unit: "mg"),
            NutrientAmount(name: "Iron", value: breakdown.ironMg, unit: "mg"),
            NutrientAmount(name: "Magnesium", value: breakdown.magnesiumMg, unit: "mg"),
            NutrientAmount(name: "Zinc", value: breakdown.zincMg, unit: "mg"),
            NutrientAmount(name: "Copper", value: breakdown.copperMg, unit: "mg"),
            NutrientAmount(name: "Manganese", value: breakdown.manganeseMg, unit: "mg"),
            NutrientAmount(name: "Phosphorus", value: breakdown.phosphorusMg, unit: "mg"),
            NutrientAmount(name: "Selenium", value: breakdown.seleniumMcg, unit: "mcg")
        ]
        let available = items.filter { $0.value != nil }
        if !available.isEmpty {
            Section("Minerals") {
                ForEach(available, id: \.name) { nutrient in
                    nutrientRow(nutrient)
                }
            }
        }
    }

    // MARK: - Other

    @ViewBuilder
    private var otherSection: some View {
        let breakdown = presenter.breakdown
        let items: [NutrientAmount] = [
            NutrientAmount(name: "Cholesterol", value: breakdown.cholesterolMg, unit: "mg"),
            NutrientAmount(name: "Caffeine", value: breakdown.caffeineMg, unit: "mg")
        ]
        let available = items.filter { $0.value != nil }
        if !available.isEmpty {
            Section("Other") {
                ForEach(available, id: \.name) { nutrient in
                    nutrientRow(nutrient)
                }
            }
        }
    }

    // MARK: - Helpers

    private func nutrientRow(_ nutrient: NutrientAmount) -> some View {
        HStack {
            Text(nutrient.name)
            Spacer()
            Text("\(formatted(nutrient.value ?? 0)) \(nutrient.unit)")
                .foregroundStyle(.secondary)
        }
    }

    /// Accepts an optional so `NutrientAmount.value` can be passed straight through;
    /// non-optional call sites are unaffected.
    private func formatted(_ value: Double?) -> String {
        guard let value else { return "–" }
        return value.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(value))
            : String(format: "%.1f", value)
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = NutritionOverviewDelegate()

    return RouterView { router in
        builder.nutritionOverviewView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {

    func nutritionOverviewView(router: AnyRouter, delegate: NutritionOverviewDelegate) -> some View {
        NutritionOverviewView(
            presenter: NutritionOverviewPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }

}

struct NutrientAmount {
    let name: String
    let value: Double?
    let unit: String
}
extension CoreRouter {

    func showNutritionOverviewView(delegate: NutritionOverviewDelegate) {
        router.showScreen(.push) { router in
            builder.nutritionOverviewView(router: router, delegate: delegate)
        }
    }

}
