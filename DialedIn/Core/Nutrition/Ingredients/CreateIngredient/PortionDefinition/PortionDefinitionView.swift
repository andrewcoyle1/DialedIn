import SwiftUI

struct PortionDefinitionDelegate {
    
    let name: String
    let brandName: String?
    let barcode: String?
    let image: PlatformImage?
    let productFront: PlatformImage?
    let nutritionPhoto: PlatformImage?
    
    var eventParameters: [String: Any]? {
        nil
    }
}

struct PortionDefinitionView: View {
        
    @State var presenter: PortionDefinitionPresenter
    let delegate: PortionDefinitionDelegate
    
    var body: some View {
        List {
            Section {
                Picker("", selection: $presenter.nutritionDefinitionOption) {
                    ForEach(NutritionDefinitionOption.allCases, id: \.self) { option in
                        Text(option.name).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .removeListRowFormatting()
            } header: {
                Text("What will you be entering nutrition information for?")
                    .font(.subheadline)
            }
            
            switch presenter.nutritionDefinitionOption {
            case .serving: definePortionSection
            case .standardMass: definePortionWeightSection
            case .standardVolume: definePortionVolumeSection
            }
        }
        .navigationTitle("Create Food")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            Button {
                presenter.onNextPressed()

            } label: {
                Text("Next")
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .disabled(!presenter.canSave)
            .padding(.horizontal)
        }
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
    }
    
    private var definePortionSection: some View {
        PortionDefinition<NutritionWeightUnit>(
            headerText: "Describe this serving",
            sizeHeader: "Serving Weight",
            primaryPrompt: "Enter serving weight",
            primaryValue: $presenter.servingWeight,
            unit: .grams,
            secondaryPrompt: "1",
            secondaryValue: $presenter.portionSize,
            tertiaryPrompt: "portion",
            tertiaryValue: $presenter.portionName,
            footerText: "For example, if a serving is 4 pieces, enter 4 for quantity and pieces for serving name",
            alertText: "If you provide the serving weight, all standard units of weight will be available when you log this food"
        )
    }
    
    private var definePortionWeightSection: some View {
        PortionDefinition<NutritionWeightUnit>(
            headerText: "Optionally define a single portion",
            sizeHeader: "Weight of Portion",
            primaryPrompt: "Enter portion weight",
            primaryValue: $presenter.portionWeight,
            unit: .grams,
            secondaryPrompt: "1",
            secondaryValue: $presenter.weightPortionSize,
            tertiaryPrompt: "portion",
            tertiaryValue: $presenter.weightPortionName,
            footerText: "For example, if single portion is 4 pieces, enter 4 for quantity and pieces for portion name",
            alertText: "All standard units of weight will be available when you log this food"
        )
    }
    
    private var definePortionVolumeSection: some View {
        PortionDefinition<NutritionVolumeUnit>(
            headerText: "Optionally define a single portion",
            sizeHeader: "Volume of Portion",
            primaryPrompt: "Enter portion volume",
            primaryValue: $presenter.portionVolume,
            unit: .millileter,
            secondaryPrompt: "1",
            secondaryValue: $presenter.volumePortionSize,
            tertiaryPrompt: "portion",
            tertiaryValue: $presenter.volumePortionName,
            footerText: "For example, if single portion is 1 bottle, enter 1 for quantity and bottle for portion name",
            alertText: "All standard units of volume will be available when you log this food"
        )
    }
}

private struct PortionDefinition<T: PickableUnit>: View {

    @Environment(\.colorScheme) private var colorScheme
    
    let headerText: String
    let sizeHeader: String
    let primaryPrompt: String
    let primaryValue: Binding<String>
    let unit: T
    let secondaryPrompt: String
    let secondaryValue: Binding<String>
    let tertiaryPrompt: String
    let tertiaryValue: Binding<String>
    let footerText: String
    let alertText: String

    var body: some View {
        Section {
            VStack(spacing: 12) {
                
                VStack(alignment: .leading) {
                    Text(sizeHeader)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.leading)
                    TextFieldwUnit<NutritionWeightUnit>(
                        prompt: primaryPrompt,
                        text: primaryValue,
                        unit: NutritionWeightUnit.grams
                    )
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    .background(colorScheme.backgroundPrimary, in: .capsule)
                }
                VStack(alignment: .leading) {
                    Text("Portion Description")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.leading)
                    
                    HStack {
                        TextField(
                            secondaryPrompt,
                            text: secondaryValue
                        )
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 60)
                        TextField(
                            tertiaryPrompt,
                            text: tertiaryValue
                        )
                        .textFieldStyle(.roundedBorder)
                        
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    .background(colorScheme.backgroundPrimary, in: .capsule)
                }
            }
            .removeListRowFormatting()
        } header: {
            Text(headerText)
        } footer: {
            Text(footerText)
        }
        
        Label(alertText, systemImage: "info.circle.fill")
            .font(.caption)
            .foregroundStyle(.secondary)
    }

}

enum NutritionDefinitionOption: CaseIterable {    
    case serving
    case standardMass// (preferredWeightUnit: NutritionWeightUnit)
    case standardVolume
    
    var name: String {
        switch self {
        case .serving:
            return "Serving"
        case .standardMass:
            return "Standard Mass"
        case .standardVolume:
            return "Standard Volume"
        }
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = PortionDefinitionDelegate(
        name: "Coke Zero",
        brandName: "Coca Cola",
        barcode: "5000112633320",
        image: nil,
        productFront: nil,
        nutritionPhoto: nil
    )
    
    return RouterView { router in
        builder.portionDefinitionView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {
    
    func portionDefinitionView(router: AnyRouter, delegate: PortionDefinitionDelegate) -> some View {
        PortionDefinitionView(
            presenter: PortionDefinitionPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showPortionDefinitionView(delegate: PortionDefinitionDelegate) {
        router.showScreen(.push) { router in
            builder.portionDefinitionView(router: router, delegate: delegate)
        }
    }
    
}
