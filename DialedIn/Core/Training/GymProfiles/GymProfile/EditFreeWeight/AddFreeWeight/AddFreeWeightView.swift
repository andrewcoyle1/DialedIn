import SwiftUI

struct AddFreeWeightDelegate {
    var freeWeight: Binding<FreeWeights>
    var unit: ExerciseWeightUnit
}

struct AddFreeWeightView: View {
    
    @State var presenter: AddFreeWeightPresenter
    
    var body: some View {
        List {
            Section {
                if presenter.freeWeight.wrappedValue.needsColour {
                    colourSection
                }
                weightSection
            }
            .listSectionMargins(.vertical, 0)
        }
        .navigationTitle("Add")
        .navigationSubtitle(presenter.freeWeight.wrappedValue.name)
        .navigationBarTitleDisplayMode(.inline)
        .screenAppearAnalytics(name: "AddFreeWeightView")
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
    
    private var weightSection: some View {
        VStack(alignment: .leading) {
            Text("Weight")
                .font(.headline)
            ZStack(alignment: .trailing) {
                TextField("", value: $presenter.freeWeightAvailable.availableWeights, format: .number, prompt: Text(""))
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
    
    func addFreeWeightView(router: Router, delegate: AddFreeWeightDelegate) -> some View {
        AddFreeWeightView(
            presenter: AddFreeWeightPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                delegate: delegate
            )
        )
    }

}

extension CoreRouter {
    
    func showAddFreeWeightView(delegate: AddFreeWeightDelegate) {
        router.showScreen(.sheetConfig(config: ResizableSheetConfig(detents: [.fraction(0.3)]))) { router in
            builder.addFreeWeightView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    @Previewable @State var freeWeight: FreeWeights = FreeWeights.mock
    let unit: ExerciseWeightUnit = .kilograms
    let container = DevPreview.shared.container
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = AddFreeWeightDelegate(freeWeight: $freeWeight, unit: unit)
    
    return RouterView { router in
        builder.addFreeWeightView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
