import SwiftUI

struct EditBodyWeightView: View {
    
    @State var presenter: EditBodyWeightPresenter
    
    var body: some View {
        List {
            pickerSection
            weightsList
        }
        .navigationTitle(presenter.bodyWeight.name)
        .navigationBarTitleDisplayMode(.inline)
        .screenAppearAnalytics(name: "EditBodyWeightView")
        .toolbar {
            toolbarContent
        }
    }
    
    private var pickerSection: some View {
        Section {
            HStack {
                Text("Weights")
                Spacer()
                Picker("", selection: $presenter.selectedUnit) {
                    ForEach(ExerciseWeightUnit.allCases, id: \.self) { unit in
                        Text(unit.abbreviation)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 160)
            }
            .removeListRowFormatting()
        }
        .listSectionMargins(.vertical, 0)
    }
    
    private var weightsList: some View {
        Section {
            let unit = presenter.selectedUnit
            let weightIDs = presenter.filteredWeightIDs(for: unit)
            if weightIDs.isEmpty {
                ContentUnavailableView(
                    "No \(presenter.selectedUnit.displayName) weights",
                    systemImage: "dumbbell",
                    description: Text("There are no weights for the selected unit.")
                )
            } else {
                ForEach(weightIDs, id: \.self) { weightID in
                    let weight = presenter.bindingForWeight(id: weightID, fallbackUnit: unit)
                    HStack {
                        if let colour = weight.wrappedValue.plateColour {
                            Circle()
                                .frame(maxHeight: 20)
                                .foregroundStyle(Color(hex: colour))
                        }
                        Text("\(String(format: "%g", weight.wrappedValue.availableWeights)) \(weight.wrappedValue.unit.abbreviation)")
                        Spacer()
                        Toggle("", isOn: weight.isActive)
                            .labelsHidden()
                    }
                }
                .onDelete { offsets in
                    presenter.deleteWeights(at: offsets, weightIDs: weightIDs)
                }
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                presenter.onDismissPressed()
            } label: {
                Image(systemName: "xmark")
            }
        }
    }
}

extension CoreBuilder {
    
    func editBodyWeightView(router: Router, bodyWeight: Binding<BodyWeights>) -> some View {
        EditBodyWeightView(
            presenter: EditBodyWeightPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                bodyWeight: bodyWeight
            )
        )
    }
    
}

extension CoreRouter {
    
    func showEditBodyWeightView(bodyWeight: Binding<BodyWeights>) {
        router.showScreen(.sheet) { router in
            builder.editBodyWeightView(router: router, bodyWeight: bodyWeight)
        }
    }
    
}

#Preview("Dumbbells") {
    let container = DevPreview.shared.container
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let bodyWeight = BodyWeights(
        id: UUID().uuidString,
        name: "Dumbbells",
        description: nil,
        range: [
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 1,
                unit: .kilograms,
                isActive: true
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 2,
                unit: .kilograms,
                isActive: true
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 3,
                unit: .kilograms,
                isActive: true
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 4,
                unit: .kilograms,
                isActive: true
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 5,
                unit: .kilograms,
                isActive: true
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 6,
                unit: .kilograms,
                isActive: true
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 6,
                unit: .kilograms,
                isActive: true
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 7,
                unit: .kilograms,
                isActive: true
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 8,
                unit: .kilograms,
                isActive: true
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 9,
                unit: .kilograms,
                isActive: true
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 10,
                unit: .kilograms,
                isActive: true
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 12,
                unit: .kilograms,
                isActive: false
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 12.5,
                unit: .kilograms,
                isActive: true
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 14,
                unit: .kilograms,
                isActive: false
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 15,
                unit: .kilograms,
                isActive: true
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 16,
                unit: .kilograms,
                isActive: false
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 17.5,
                unit: .kilograms,
                isActive: true
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 18,
                unit: .kilograms,
                isActive: false
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 20,
                unit: .kilograms,
                isActive: true
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 22,
                unit: .kilograms,
                isActive: false
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 22.5,
                unit: .kilograms,
                isActive: true
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 24,
                unit: .kilograms,
                isActive: false
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 25,
                unit: .kilograms,
                isActive: true
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 26,
                unit: .kilograms,
                isActive: false
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 27.5,
                unit: .kilograms,
                isActive: true
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 28,
                unit: .kilograms,
                isActive: false
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 30,
                unit: .kilograms,
                isActive: true
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 32,
                unit: .kilograms,
                isActive: false
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 32.5,
                unit: .kilograms,
                isActive: true
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 34,
                unit: .kilograms,
                isActive: false
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 36,
                unit: .kilograms,
                isActive: false
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 37.5,
                unit: .kilograms,
                isActive: true
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 38,
                unit: .kilograms,
                isActive: false
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 40,
                unit: .kilograms,
                isActive: true
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 42,
                unit: .kilograms,
                isActive: false
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 42.5,
                unit: .kilograms,
                isActive: true
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 44,
                unit: .kilograms,
                isActive: false
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 45,
                unit: .kilograms,
                isActive: true
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 46,
                unit: .kilograms,
                isActive: false
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 47.5,
                unit: .kilograms,
                isActive: true
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 48,
                unit: .kilograms,
                isActive: false
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 50,
                unit: .kilograms,
                isActive: true
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                availableWeights: 57.5,
                unit: .kilograms,
                isActive: true
            )
        ],
        isActive: true
    )
    return RouterView { router in
        builder.editBodyWeightView(router: router, bodyWeight: Binding.constant(bodyWeight))
    }
    .previewEnvironment()
}

#Preview("Weight Plates") {
    @Previewable @State var bodyWeight = BodyWeights(
        id: UUID().uuidString,
        name: "Weight Plates",
        description: nil,
        range: [
            BodyWeightsAvailable(
                id: UUID().uuidString,
                plateColour: Color.green.asHex(),
                availableWeights: 1.25,
                unit: .kilograms,
                isActive: true
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                plateColour: Color.blue.asHex(),
                availableWeights: 2.5,
                unit: .kilograms,
                isActive: true
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                plateColour: Color.gray.asHex(),
                availableWeights: 10,
                unit: .pounds,
                isActive: false
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                plateColour: Color.gray.asHex(),
                availableWeights: 5,
                unit: .kilograms,
                isActive: true
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                plateColour: Color.green.asHex(),
                availableWeights: 10,
                unit: .kilograms,
                isActive: true
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                plateColour: Color.green.asHex(),
                availableWeights: 25,
                unit: .pounds,
                isActive: false
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                plateColour: Color.yellow.asHex(),
                availableWeights: 15,
                unit: .kilograms,
                isActive: true
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                plateColour: Color.yellow.asHex(),
                availableWeights: 35,
                unit: .pounds,
                isActive: false
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                plateColour: Color.blue.asHex(),
                availableWeights: 20,
                unit: .kilograms,
                isActive: true
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                plateColour: Color.blue.asHex(),
                availableWeights: 45,
                unit: .pounds,
                isActive: false
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                plateColour: Color.red.asHex(),
                availableWeights: 25,
                unit: .kilograms,
                isActive: true
            ),
            BodyWeightsAvailable(
                id: UUID().uuidString,
                plateColour: Color.red.asHex(),
                availableWeights: 55,
                unit: .pounds,
                isActive: false
            )
        ],
        isActive: true
    )
    let container = DevPreview.shared.container
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return RouterView { router in
        builder.editBodyWeightView(router: router, bodyWeight: $bodyWeight)
    }
    .previewEnvironment()
}
