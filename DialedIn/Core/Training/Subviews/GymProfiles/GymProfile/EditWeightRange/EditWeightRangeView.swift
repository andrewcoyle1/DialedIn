import SwiftUI

struct EditWeightRangeDelegate<Range: WeightRange> {
    var equipmentName: String
    var range: Binding<Range>
}

struct EditWeightRangeView<Range: WeightRange>: View {
    
    @State var presenter: EditWeightRangePresenter
    let delegate: EditWeightRangeDelegate<Range>
    
    var body: some View {
        List {
            Section {
                    VStack(alignment: .leading) {
                        Text("Range Start")
                            .font(.headline)
                            .padding(.top, 4)
                        ZStack(alignment: .trailing) {
                            TextField("", value: delegate.range.minWeight, format: .number, prompt: Text(""))
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                            Text(delegate.range.wrappedValue.unit.abbreviation)
                                .padding(.trailing)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Range End")
                            .font(.headline)
                        ZStack(alignment: .trailing) {
                            TextField("", value: delegate.range.maxWeight, format: .number, prompt: Text(""))
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                            Text(delegate.range.wrappedValue.unit.abbreviation)
                                .padding(.trailing)
                        }
                        
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Increment")
                            .font(.headline)
                        ZStack(alignment: .trailing) {
                            TextField("", value: delegate.range.increment, format: .number, prompt: Text(""))
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                            Text(delegate.range.wrappedValue.unit.abbreviation)
                                .padding(.trailing)
                        }
                        .padding(.bottom, 4)

                    }
            }
            .listRowSeparator(.hidden)
            .listRowInsets(.top, 8)
            .listSectionMargins(.vertical, 0)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Edit Range")
        .navigationSubtitle(delegate.equipmentName)
        .navigationBarTitleDisplayMode(.inline)
        .screenAppearAnalytics(name: "EditWeightRangeView")
        .toolbar {
            toolbarContent
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
    }
}

extension CoreBuilder {
    
    func editWeightRangeView<Range: WeightRange>(router: Router, delegate: EditWeightRangeDelegate<Range>) -> some View {
        EditWeightRangeView<Range>(
            presenter: EditWeightRangePresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showEditWeightRangeView<Range: WeightRange>(delegate: EditWeightRangeDelegate<Range>) {
        router.showScreen(.sheetConfig(config: ResizableSheetConfig(detents: [.fraction(0.4)]))) { router in
            builder.editWeightRangeView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    @Previewable @State var machineRange: CableMachineRange = CableMachineRange(id: UUID().uuidString, name: "Preview Range", minWeight: 0, maxWeight: 310, increment: 5, unit: .kilograms, isActive: true)
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    let delegate = EditWeightRangeDelegate(
        equipmentName: "Cable Lat Pulldown Machine",
        range: Binding(
            get: { machineRange },
            set: { newValue in machineRange = newValue }
        )
    )
    
    RouterView { router in
        builder.editWeightRangeView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
