import SwiftUI

struct EditLoadableBarView: View {
    
    @State var presenter: EditLoadableBarPresenter
    
    var body: some View {
        @Bindable var presenter = presenter
        List {
            pickerSection
            weightsList
        }
        .navigationTitle(presenter.loadableBar.name)
        .navigationBarTitleDisplayMode(.inline)
        .screenAppearAnalytics(name: "EditLoadableBarView")
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
                .sorted { presenter.weightValue(for: $0) < presenter.weightValue(for: $1) }
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
    
    func editLoadableBarView(router: Router, loadableBar: Binding<LoadableBars>) -> some View {
        EditLoadableBarView(
            presenter: EditLoadableBarPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                loadableBarBinding: loadableBar
            )
        )
    }
}

extension CoreRouter {
    
    func showEditLoadableBarView(loadableBar: Binding<LoadableBars>) {
        router.showScreen(.sheet) { router in
            builder.editLoadableBarView(router: router, loadableBar: loadableBar)
        }
    }
}

#Preview {
    let container = DevPreview.shared.container
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let loadableBar = LoadableBars.mock
    return RouterView { router in
        builder.editLoadableBarView(router: router, loadableBar: Binding.constant(loadableBar))
    }
    .previewEnvironment()
}
