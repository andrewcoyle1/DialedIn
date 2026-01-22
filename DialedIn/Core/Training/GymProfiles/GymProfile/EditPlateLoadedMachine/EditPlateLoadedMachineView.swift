import SwiftUI

struct EditPlateLoadedMachineView: View {
    
    @State var presenter: EditPlateLoadedMachinePresenter
    
    var body: some View {
        List {
            pickerSection
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
            VStack(alignment: .leading) {
                Text("Weights")
                    .font(.headline)

                HStack {
                    TextField("", value: $presenter.plateLoadedMachine.baseWeight, format: .number)
                        .textFieldStyle(.roundedBorder)
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
        .listSectionMargins(.vertical, 0)
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
        router.showScreen(.sheetConfig(config: ResizableSheetConfig(detents: [.fraction(0.2)]))) { router in
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
