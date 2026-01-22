import SwiftUI

struct AddBodyWeightDelegate {
    var bodyWeight: Binding<BodyWeights>
    var unit: ExerciseWeightUnit
}

struct AddBodyWeightView: View {
    
    @State var presenter: AddBodyWeightPresenter
    
    var body: some View {
        List {
            Section {
                weightSection
            }
            .listSectionMargins(.vertical, 0)
        }
        .navigationTitle("Add")
        .navigationSubtitle(presenter.bodyWeight.wrappedValue.name)
        .navigationBarTitleDisplayMode(.inline)
        .screenAppearAnalytics(name: "AddBodyWeightView")
        .toolbar {
            toolbarContent
        }
    }
        
    private var weightSection: some View {
        VStack(alignment: .leading) {
            Text("Weight")
                .font(.headline)
            ZStack(alignment: .trailing) {
                TextField("", value: $presenter.bodyWeightAvailable.availableWeights, format: .number, prompt: Text(""))
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
    
    func addBodyWeightView(router: Router, delegate: AddBodyWeightDelegate) -> some View {
        AddBodyWeightView(
            presenter: AddBodyWeightPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                delegate: delegate
            )
        )
    }

}

extension CoreRouter {
    
    func showAddBodyWeightView(delegate: AddBodyWeightDelegate) {
        router.showScreen(.sheetConfig(config: ResizableSheetConfig(detents: [.fraction(0.2)]))) { router in
            builder.addBodyWeightView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    @Previewable @State var bodyWeight: BodyWeights = BodyWeights.mock
    let unit: ExerciseWeightUnit = .kilograms
    let container = DevPreview.shared.container
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = AddBodyWeightDelegate(bodyWeight: $bodyWeight, unit: unit)
    
    return RouterView { router in
        builder.addBodyWeightView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
