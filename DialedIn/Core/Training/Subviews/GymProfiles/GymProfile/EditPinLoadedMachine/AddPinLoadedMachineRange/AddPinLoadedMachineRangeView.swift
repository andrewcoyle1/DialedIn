import SwiftUI

struct AddPinLoadedMachineRangeDelegate {
    var pinLoadedMachine: Binding<PinLoadedMachine>
    var unit: ExerciseWeightUnit
}

struct AddPinLoadedMachineRangeView: View {
    
    @State var presenter: AddPinLoadedMachineRangePresenter
    
    var body: some View {
        List {
            Section {
                nameSection
                rangeStartSection
                rangeEndSection
                incrementSection
            }
            .listSectionMargins(.vertical, 0)
        }
        .navigationTitle("Add Range")
        .navigationSubtitle(presenter.pinLoadedMachine.wrappedValue.name)
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden)
        .screenAppearAnalytics(name: "AddPinLoadedMachineRangeView")
        .toolbar {
            toolbarContent
        }
    }
    
    private var nameSection: some View {
        VStack(alignment: .leading) {
            Text("Label")
                .font(.headline)
                .padding(.top, 4)
            TextField(text: $presenter.range.name, prompt: Text(""), label: { Text("")})
                .textFieldStyle(.roundedBorder)
        }
    }

    private var rangeStartSection: some View {
        VStack(alignment: .leading) {
            Text("Range Start")
                .font(.headline)
                .padding(.top, 4)
            ZStack(alignment: .trailing) {
                TextField("", value: $presenter.range.minWeight, format: .number, prompt: Text(""))
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                Text(presenter.unit.abbreviation)
                    .padding(.trailing)
            }
        }
    }
    
    private var rangeEndSection: some View {
        VStack(alignment: .leading) {
            Text("Range End")
                .font(.headline)
            ZStack(alignment: .trailing) {
                TextField("", value: $presenter.range.maxWeight, format: .number, prompt: Text(""))
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                Text(presenter.unit.abbreviation)
                    .padding(.trailing)
            }
        }
    }
    
    private var incrementSection: some View {
        VStack(alignment: .leading) {
            Text("Increment")
                .font(.headline)
            ZStack(alignment: .trailing) {
                TextField("", value: $presenter.range.increment, format: .number, prompt: Text(""))
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                Text(presenter.unit.abbreviation)
                    .padding(.trailing)
            }
            .padding(.bottom, 4)
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
        
        ToolbarItem(placement: .confirmationAction) {
            Button {
                presenter.onSavePressed()
            } label: {
                Image(systemName: "checkmark")
            }
            .buttonStyle(.glassProminent)
        }
    }
}

extension CoreBuilder {
    
    func addPinLoadedMachineRangeView(router: Router, delegate: AddPinLoadedMachineRangeDelegate) -> some View {
        AddPinLoadedMachineRangeView(
            presenter: AddPinLoadedMachineRangePresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                delegate: delegate
            )
        )
    }
    
}

extension CoreRouter {
    
    func showAddPinLoadedMachineRangeView(delegate: AddPinLoadedMachineRangeDelegate) {
        router.showScreen(.sheetConfig(config: ResizableSheetConfig(detents: [.fraction(0.53)]))) { router in
            builder.addPinLoadedMachineRangeView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    @Previewable @State var pinLoadedMachine: PinLoadedMachine = PinLoadedMachine.mock
    let unit: ExerciseWeightUnit = .kilograms
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = AddPinLoadedMachineRangeDelegate(pinLoadedMachine: $pinLoadedMachine, unit: unit)
    
    return RouterView { router in
        builder.addPinLoadedMachineRangeView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
