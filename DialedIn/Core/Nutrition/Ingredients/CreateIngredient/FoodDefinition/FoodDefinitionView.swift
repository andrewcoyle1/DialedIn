import SwiftUI

struct FoodDefinitionDelegate {
    let nutritionDefinitionOption: NutritionDefinitionOption
    var servingWeight: String?
    var portionSize: String?
    var portionName: String?
    
    var portionWeight: String?
    var weightPortionSize: String?
    var weightPortionName: String?
    
    var portionVolume: String?
    var volumePortionSize: String?
    var volumePortionName: String?

    var eventParameters: [String: Any]? {
        nil
    }
}

struct FoodDefinitionView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State var presenter: FoodDefinitionPresenter
    let delegate: FoodDefinitionDelegate
    
    var body: some View {
        List {
            Section {
                Picker("", selection: $presenter.foodDefinitionOption) {
                    ForEach(FoodDefinitionOption.allCases, id: \.self) { option in
                        Text(option.name).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .removeListRowFormatting()
            } header: {
                Text("What will you be entering nutrition information for?")
                    .font(.subheadline)
            }
            
            switch presenter.foodDefinitionOption {
            case .usLabel: Text("US Label")
            case .nonUsLabel: Text("Non-US Label")
            case .foodDetail: foodDetailSection
            }
        }
        .navigationTitle("Create Food")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
        .safeAreaInset(edge: .bottom) {
            VStack {
            Text("Create")
                .callToActionButton(isPrimaryAction: false)
                .anyButton(.press) {
                    presenter.onCreatePressed()
                }
            Text("Create & Add")
                .callToActionButton(isPrimaryAction: true)
                .anyButton(.press) {
                    presenter.onCreateAndAddPressed()
                }
        }
        .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private var foodDetailSection: some View {
        Section {
            caloriesAndMacrosSection
            carbsSection
            fatsSection
            proteinSection
            vitaminsSection
            mineralsSection
            otherSection
        } header: {
            Text("Provide nutrition facts for \(delegate.nutritionDefinitionOption.name.lowercased())")
            
        }
    }
    
    private var caloriesAndMacrosSection: some View {
        DisclosureGroup(isExpanded: $presenter.isShowingMacros) {
            Group {
                LabeledTextFieldWithUnitPicker<EnergyUnit>(
                    label: "Energy",
                    text: .constant(""),
                    unit: $presenter.energyUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Protein",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Carbs",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Fats",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
            }
            .padding(.bottom)
            .listRowSeparator(.hidden)
            .listRowInsets(.vertical, 0)
            .listRowInsets(.leading, 0)
        } label: {
            Text("Calories & Macros")
                .font(.headline)
        }
    }
    
    private var carbsSection: some View {
        DisclosureGroup(isExpanded: $presenter.isShowingCarbs) {
            Group {
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Fiber",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Starch",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Sugars",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Sugars (Added)",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
            }
            .padding(.bottom)
            .listRowSeparator(.hidden)
            .listRowInsets(.vertical, 0)
            .listRowInsets(.leading, 0)
        } label: {
            Text("Carbs Breakdown")
                .font(.headline)
        }
    }
    
    private var fatsSection: some View {
        DisclosureGroup(isExpanded: $presenter.isShowingFats) {
            Group {
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Monounsaturated Fat",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Polyunsaturated Fat",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Omega-3",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Omega-3 ALA",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Omega-3 DHA",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Omega-3 EPA",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Omega-6",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Saturated Fat",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Trans Fat",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
            }
            .padding(.bottom)
            .listRowSeparator(.hidden)
            .listRowInsets(.vertical, 0)
            .listRowInsets(.leading, 0)
        } label: {
            Text("Fats Breakdown")
                .font(.headline)
        }
    }
    
    private var proteinSection: some View {
        DisclosureGroup(isExpanded: $presenter.isShowingProtein) {
            Group {
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Cysteine",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Histidine",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Isoleucine",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Leucine",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Lysine",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Methionine",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Phenylalanine",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Threonine",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Tryptophan",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Tyrosene",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Tyrosine",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Valine",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
            }
            .padding(.bottom)
            .listRowSeparator(.hidden)
            .listRowInsets(.vertical, 0)
            .listRowInsets(.leading, 0)
        } label: {
            Text("Protein Breakdown")
                .font(.headline)
        }
    }
    
    private var vitaminsSection: some View {
        DisclosureGroup(isExpanded: $presenter.isShowingVitamins) {
            Group {
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "B1, Thiamine",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "B2, Riboflavin",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "B3, Niacin",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "B5, Pantothenic Acid",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "B6, Pyridoxine",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "B12, Cobalamin",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Folate",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnitPicker<NutritionWeightUnit>(
                    label: "Vitamin A",
                    text: .constant(""),
                    unit: $presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Vitamin C",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnitPicker<NutritionWeightUnit>(
                    label: "Vitamin D",
                    text: .constant(""),
                    unit: $presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnitPicker<NutritionWeightUnit>(
                    label: "Vitamin E",
                    text: .constant(""),
                    unit: $presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Vitamin K",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)

            }
            .padding(.bottom)
            .listRowSeparator(.hidden)
            .listRowInsets(.vertical, 0)
            .listRowInsets(.leading, 0)
        } label: {
            Text("Vitamins Breakdown")
                .font(.headline)
        }
    }
    
    private var mineralsSection: some View {
        DisclosureGroup(isExpanded: $presenter.isShowingMinerals) {
            Group {
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Calcium",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Copper",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Iron",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Magnesium",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Manganese",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Phosphorus",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Potassium",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Selenium",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnitPicker<NutritionWeightUnit>(
                    label: "Sodium",
                    text: .constant(""),
                    unit: $presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Zinc",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
            }
            .padding(.bottom)
            .listRowSeparator(.hidden)
            .listRowInsets(.vertical, 0)
            .listRowInsets(.leading, 0)
        } label: {
            Text("Minerals Breakdown")
                .font(.headline)
        }
    }
    private var otherSection: some View {
        DisclosureGroup(isExpanded: $presenter.isShowingOther) {
            Group {
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Alcohol",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Caffeine",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Cholesterol",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
                LabeledTextFieldWithUnit<NutritionWeightUnit>(
                    label: "Water",
                    text: .constant(""),
                    unit: presenter.nutritionWeightUnit)
            }
            .padding(.bottom)
            .listRowSeparator(.hidden)
            .listRowInsets(.vertical, 0)
            .listRowInsets(.leading, 0)
        } label: {
            Text("Other")
                .font(.headline)
        }
    }
}

enum FoodDefinitionOption: CaseIterable {
    case usLabel
    case nonUsLabel// (preferredWeightUnit: NutritionWeightUnit)
    case foodDetail
    
    var name: String {
        switch self {
        case .usLabel:
            return "US Label"
        case .nonUsLabel:
            return "Non-US Label"
        case .foodDetail:
            return "Food Detail"
        }
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = FoodDefinitionDelegate(nutritionDefinitionOption: .serving)
    
    return RouterView { router in
        builder.foodDefinitionView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {
    
    func foodDefinitionView(router: AnyRouter, delegate: FoodDefinitionDelegate) -> some View {
        FoodDefinitionView(
            presenter: FoodDefinitionPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showFoodDefinitionView(delegate: FoodDefinitionDelegate) {
        router.showScreen(.push) { router in
            builder.foodDefinitionView(router: router, delegate: delegate)
        }
    }
    
}
