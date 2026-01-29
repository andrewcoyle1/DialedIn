import SwiftUI

struct AddBandDelegate {
    var band: Binding<Bands>
    var unit: ExerciseWeightUnit
}

struct AddBandView: View {
    
    @State var presenter: AddBandPresenter
    
    var body: some View {
        List {
            Section {
                colourSection
                labelSection
                weightSection
            }
            .listSectionMargins(.vertical, 0)
        }
        .navigationTitle("Add")
        .navigationSubtitle(presenter.band.wrappedValue.name)
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden)
        .screenAppearAnalytics(name: "AddBandView")
        .toolbar {
            toolbarContent
        }
    }
    
    private var colourSection: some View {
        VStack(alignment: .leading) {
            Text("Plate Colour")
                .font(.headline)
            HStack {
                ForEach(presenter.colours, id: \.self) { colour in
                    ZStack {
                        Circle()
                            .opacity(0.3)
                    }
                    .foregroundStyle(colour)
                    .overlay {
                        Circle()
                            .stroke(colour == presenter.selectedColour ? presenter.selectedColour ?? .primary : Color.clear, lineWidth: 4)
                    }
                    .anyButton {
                        presenter.onColourPressed(colour: colour)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var labelSection: some View {
        VStack(alignment: .leading) {
            Text("Label")
                .font(.headline)
            ZStack(alignment: .trailing) {
                TextField(text: $presenter.bandAvailable.name, prompt: Text(""), label: { Text("Label") })
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.default)
            }
        }
    }

    private var weightSection: some View {
        VStack(alignment: .leading) {
            Text("Weight")
                .font(.headline)
            ZStack(alignment: .trailing) {
                TextField("", value: $presenter.bandAvailable.availableResistance, format: .number, prompt: Text(""))
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                Text(presenter.unit.abbreviation)
                    .padding(.trailing)
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
    
    func addBandView(router: Router, delegate: AddBandDelegate) -> some View {
        AddBandView(
            presenter: AddBandPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                delegate: delegate
            )
        )
    }

}

extension CoreRouter {
    
    func showAddBandView(delegate: AddBandDelegate) {
        router.showScreen(.sheetConfig(config: ResizableSheetConfig(detents: [.fraction(0.42)]))) { router in
            builder.addBandView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    @Previewable @State var band: Bands = Bands.mock
    let unit: ExerciseWeightUnit = .kilograms
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = AddBandDelegate(band: $band, unit: unit)
    
    return RouterView { router in
        builder.addBandView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
