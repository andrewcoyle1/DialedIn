import SwiftUI

struct EditFixedWeightBarView: View {
    
    @State var presenter: EditFixedWeightBarPresenter
    
    var body: some View {
        List {
            pickerSection
            weightsList
        }
        .navigationTitle(presenter.fixedWeightBar.name)
        .navigationBarTitleDisplayMode(.inline)
        .screenAppearAnalytics(name: "EditFixedWeightBarView")
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
    
    func editFixedWeightBarView(router: Router, fixedWeightBar: Binding<FixedWeightBars>) -> some View {
        EditFixedWeightBarView(
            presenter: EditFixedWeightBarPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                fixedWeightBarBinding: fixedWeightBar
            )
        )
    }
}

extension CoreRouter {
    
    func showEditFixedWeightBarView(fixedWeightBar: Binding<FixedWeightBars>) {
        router.showScreen(.sheet) { router in
            builder.editFixedWeightBarView(router: router, fixedWeightBar: fixedWeightBar)
        }
    }
}

#Preview {
    let container = DevPreview.shared.container
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let fixedWeightBar = FixedWeightBars.mock
    return RouterView { router in
        builder.editFixedWeightBarView(router: router, fixedWeightBar: Binding.constant(fixedWeightBar))
    }
    .previewEnvironment()
}
