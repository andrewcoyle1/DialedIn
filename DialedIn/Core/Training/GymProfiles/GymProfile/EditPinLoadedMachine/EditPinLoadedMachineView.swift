import SwiftUI

struct EditPinLoadedMachineView: View {
    
    @State var presenter: EditPinLoadedMachinePresenter
    
    var body: some View {
        @Bindable var presenter = presenter
        List {
            pickerSection
            weightsList
        }
        .navigationTitle(presenter.pinLoadedMachine.name)
        .navigationBarTitleDisplayMode(.inline)
        .screenAppearAnalytics(name: "EditPinLoadedMachineView")
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
                        VStack(alignment: .leading) {
                            Text(weight.wrappedValue.name)
                            Text("\(String(format: "%g", weight.wrappedValue.minWeight)) - \(String(format: "%g", weight.wrappedValue.maxWeight)) \(weight.wrappedValue.unit.abbreviation), \(String(format: "%g", weight.wrappedValue.increment)) \(weight.wrappedValue.unit.abbreviation) increment")
                                .font(.caption)

                            Text("Edit Range")
                                .underline()
                                .font(.caption.bold())
                                .anyButton {
                                    presenter.onEditRangePressed(range: weight)
                                }
                            
                        }
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
        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onDismissPressed()
            } label: {
                Image(systemName: "xmark")
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.onAddPressed()
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}

extension CoreBuilder {
    
    func editPinLoadedMachineView(router: Router, pinLoadedMachine: Binding<PinLoadedMachine>) -> some View {
        EditPinLoadedMachineView(
            presenter: EditPinLoadedMachinePresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                pinLoadedMachineBinding: pinLoadedMachine
            )
        )
    }
}

extension CoreRouter {
    
    func showEditPinLoadedMachineView(pinLoadedMachine: Binding<PinLoadedMachine>) {
        router.showScreen(.sheet) { router in
            builder.editPinLoadedMachineView(router: router, pinLoadedMachine: pinLoadedMachine)
        }
    }
}

#Preview {
    let container = DevPreview.shared.container
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let pinLoadedMachine = PinLoadedMachine.mock
    return RouterView { router in
        builder.editPinLoadedMachineView(router: router, pinLoadedMachine: Binding.constant(pinLoadedMachine))
    }
    .previewEnvironment()
}
