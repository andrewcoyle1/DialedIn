import SwiftUI

struct EditCableMachineView: View {
    
    @State var presenter: EditCableMachinePresenter
    
    var body: some View {
        List {
            weightsList
        }
        .navigationTitle(presenter.cableMachine.name)
        .navigationBarTitleDisplayMode(.inline)
        .screenAppearAnalytics(name: "EditCableMachineView")
        .toolbar {
            toolbarContent
        }
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
                            Text("\(String(format: "%g", weight.wrappedValue.minWeight)) - \(String(format: "%g", weight.wrappedValue.maxWeight)) \(weight.wrappedValue.unit.abbreviation), \(String(format: "%g", weight.wrappedValue.increment)) \(weight.wrappedValue.unit.abbreviation) increments")
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
        } header: {
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
    
    func editCableMachineView(router: Router, cableMachine: Binding<CableMachine>) -> some View {
        EditCableMachineView(
            presenter: EditCableMachinePresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                cableMachineBinding: cableMachine
            )
        )
    }
}

extension CoreRouter {
    
    func showEditCableMachineView(cableMachine: Binding<CableMachine>) {
        router.showScreen(.sheet) { router in
            builder.editCableMachineView(router: router, cableMachine: cableMachine)
        }
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let cableMachine = CableMachine.mock
    return RouterView { router in
        builder.editCableMachineView(router: router, cableMachine: Binding.constant(cableMachine))
    }
    .previewEnvironment()
}
