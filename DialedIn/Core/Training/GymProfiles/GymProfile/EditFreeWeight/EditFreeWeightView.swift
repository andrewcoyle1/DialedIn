import SwiftUI

struct EditFreeWeightView: View {
    
    @State var presenter: EditFreeWeightPresenter
    
    var body: some View {
        @Bindable var presenter = presenter
        List {
            pickerSection
            weightsList
        }
        .navigationTitle(presenter.freeWeight.name)
        .navigationBarTitleDisplayMode(.inline)
        .screenAppearAnalytics(name: "EditFreeWeightView")
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
                        if let colour = weight.wrappedValue.plateColour {
                            Circle()
                                .frame(maxHeight: 20)
                                .foregroundStyle(Color(hex: colour))
                        }
                        Text("\(String(format: "%g", weight.wrappedValue.availableWeights)) \(weight.wrappedValue.unit.abbreviation)")
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
    
    func editFreeWeightView(router: Router, freeWeight: Binding<FreeWeights>) -> some View {
        EditFreeWeightView(
            presenter: EditFreeWeightPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                freeWeight: freeWeight
            )
        )
    }
    
}

extension CoreRouter {
    
    func showEditFreeWeightView(freeWeight: Binding<FreeWeights>) {
        router.showScreen(.sheet) { router in
            builder.editFreeWeightView(router: router, freeWeight: freeWeight)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let freeWeight = FreeWeights.mock
    return RouterView { router in
        builder.editFreeWeightView(router: router, freeWeight: Binding.constant(freeWeight))
    }
    .previewEnvironment()
}
