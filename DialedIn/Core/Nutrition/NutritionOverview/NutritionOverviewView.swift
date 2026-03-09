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
        let items: [(String, Double?)] = [
            ("Fiber", breakdown.fiberGrams),
            ("Sugar", breakdown.sugarGrams),
            ("Net Carbs", breakdown.netCarbsGrams)
        ]
        let available = items.filter { $0.1 != nil }
        if !available.isEmpty {
            Section("Carb Breakdown") {
                ForEach(available, id: \.0) { name, value in
                    nutrientRow(name, value: value!, unit: "g")
                }
            }
        }
    }

    // MARK: - Fat Breakdown

    @ViewBuilder
    private var fatsSection: some View {
        let breakdown = presenter.breakdown
        let items: [(String, Double?)] = [
            ("Saturated", breakdown.fatSaturatedGrams),
            ("Monounsaturated", breakdown.fatMonounsaturatedGrams),
            ("Polyunsaturated", breakdown.fatPolyunsaturatedGrams)
        ]
        let available = items.filter { $0.1 != nil }
        if !available.isEmpty {
            Section("Fat Breakdown") {
                ForEach(available, id: \.0) { name, value in
                    nutrientRow(name, value: value!, unit: "g")
                }
            }
        }
    }

    // MARK: - Vitamins

    @ViewBuilder
    private var vitaminsSection: some View {
        let breakdown = presenter.breakdown
        let items: [(String, Double?, String)] = [
            ("Vitamin A", breakdown.vitaminAMcg, "mcg"),
            ("Vitamin B6", breakdown.vitaminB6Mg, "mg"),
            ("Vitamin B12", breakdown.vitaminB12Mcg, "mcg"),
            ("Vitamin C", breakdown.vitaminCMg, "mg"),
            ("Vitamin D", breakdown.vitaminDMcg, "mcg"),
            ("Vitamin E", breakdown.vitaminEMg, "mg"),
            ("Vitamin K", breakdown.vitaminKMcg, "mcg"),
            ("Thiamin", breakdown.thiaminMg, "mg"),
            ("Riboflavin", breakdown.riboflavinMg, "mg"),
            ("Niacin", breakdown.niacinMg, "mg"),
            ("Pantothenic Acid", breakdown.pantothenicAcidMg, "mg"),
            ("Folate", breakdown.folateMcg, "mcg")
        ]
        let available = items.filter { $0.1 != nil }
        if !available.isEmpty {
            Section("Vitamins") {
                ForEach(available, id: \.0) { name, value, unit in
                    nutrientRow(name, value: value!, unit: unit)
                }
            }
        }
    }

    // MARK: - Minerals

    @ViewBuilder
    private var mineralsSection: some View {
        let breakdown = presenter.breakdown
        let items: [(String, Double?, String)] = [
            ("Sodium", breakdown.sodiumMg, "mg"),
            ("Potassium", breakdown.potassiumMg, "mg"),
            ("Calcium", breakdown.calciumMg, "mg"),
            ("Iron", breakdown.ironMg, "mg"),
            ("Magnesium", breakdown.magnesiumMg, "mg"),
            ("Zinc", breakdown.zincMg, "mg"),
            ("Copper", breakdown.copperMg, "mg"),
            ("Manganese", breakdown.manganeseMg, "mg"),
            ("Phosphorus", breakdown.phosphorusMg, "mg"),
            ("Selenium", breakdown.seleniumMcg, "mcg")
        ]
        let available = items.filter { $0.1 != nil }
        if !available.isEmpty {
            Section("Minerals") {
                ForEach(available, id: \.0) { name, value, unit in
                    nutrientRow(name, value: value!, unit: unit)
                }
            }
        }
    }

    // MARK: - Other

    @ViewBuilder
    private var otherSection: some View {
        let breakdown = presenter.breakdown
        let items: [(String, Double?, String)] = [
            ("Cholesterol", breakdown.cholesterolMg, "mg"),
            ("Caffeine", breakdown.caffeineMg, "mg")
        ]
        let available = items.filter { $0.1 != nil }
        if !available.isEmpty {
            Section("Other") {
                ForEach(available, id: \.0) { name, value, unit in
                    nutrientRow(name, value: value!, unit: unit)
                }
            }
        }
    }

    // MARK: - Helpers

    private func nutrientRow(_ label: String, value: Double, unit: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text("\(formatted(value)) \(unit)")
                .foregroundStyle(.secondary)
        }
    }

    private func formatted(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
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

extension CoreRouter {

    func showNutritionOverviewView(delegate: NutritionOverviewDelegate) {
        router.showScreen(.push) { router in
            builder.nutritionOverviewView(router: router, delegate: delegate)
        }
    }

}
