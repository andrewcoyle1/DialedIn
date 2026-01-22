import SwiftUI

struct EditPlateLoadedMachineView: View {
    
    @State var presenter: EditPlateLoadedMachinePresenter
    
    var body: some View {
        List {
            pickerSection
            weightsList
        }
        .navigationTitle(presenter.plateLoadedMachine.name)
        .navigationBarTitleDisplayMode(.inline)
        .screenAppearAnalytics(name: "EditPlateLoadedMachineView")
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
                        Text("\(String(format: "%g", weight.wrappedValue.baseWeight)) \(weight.wrappedValue.unit.abbreviation)")
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
    
    func editPlateLoadedMachineView(router: Router, plateLoadedMachine: Binding<PlateLoadedMachine>) -> some View {
        EditPlateLoadedMachineView(
            presenter: EditPlateLoadedMachinePresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                plateLoadedMachineBinding: plateLoadedMachine
            )
        )
    }
}

extension CoreRouter {
    
    func showEditPlateLoadedMachineView(plateLoadedMachine: Binding<PlateLoadedMachine>) {
        router.showScreen(.sheet) { router in
            builder.editPlateLoadedMachineView(router: router, plateLoadedMachine: plateLoadedMachine)
        }
    }
}

#Preview {
    let container = DevPreview.shared.container
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let plateLoadedMachine = PlateLoadedMachine.mock
    return RouterView { router in
        builder.editPlateLoadedMachineView(router: router, plateLoadedMachine: Binding.constant(plateLoadedMachine))
    }
    .previewEnvironment()
}
