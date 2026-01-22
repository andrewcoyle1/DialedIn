import SwiftUI

struct AddFixedWeightBarDelegate {
    var fixedWeightBar: Binding<FixedWeightBars>
    var unit: ExerciseWeightUnit
}

struct AddFixedWeightBarView: View {
    
    @State var presenter: AddFixedWeightBarPresenter
    
    var body: some View {
        List {
            Section {
                weightSection
            }
            .listSectionMargins(.vertical, 0)
        }
        .navigationTitle("Add")
        .navigationSubtitle(presenter.fixedWeightBar.wrappedValue.name)
        .navigationBarTitleDisplayMode(.inline)
        .screenAppearAnalytics(name: "AddFixedWeightBarView")
        .toolbar {
            toolbarContent
        }
    }
        
    private var weightSection: some View {
        VStack(alignment: .leading) {
            Text("Weight")
                .font(.headline)
            ZStack(alignment: .trailing) {
                TextField("", value: $presenter.fixedWeightBarBaseWeight.baseWeight, format: .number, prompt: Text(""))
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
    
    func addFixedWeightBarView(router: Router, delegate: AddFixedWeightBarDelegate) -> some View {
        AddFixedWeightBarView(
            presenter: AddFixedWeightBarPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                delegate: delegate
            )
        )
    }

}

extension CoreRouter {
    
    func showAddFixedWeightBarView(delegate: AddFixedWeightBarDelegate) {
        router.showScreen(.sheetConfig(config: ResizableSheetConfig(detents: [.fraction(0.3)]))) { router in
            builder.addFixedWeightBarView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    @Previewable @State var fixedWeightBar: FixedWeightBars = FixedWeightBars.mock
    let unit: ExerciseWeightUnit = .kilograms
    let container = DevPreview.shared.container
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = AddFixedWeightBarDelegate(fixedWeightBar: $fixedWeightBar, unit: unit)
    
    return RouterView { router in
        builder.addFixedWeightBarView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
