import SwiftUI

struct EditBodyWeightView: View {
    
    @State var presenter: EditBodyWeightPresenter
    
    var body: some View {
        @Bindable var presenter = presenter
        List {
            pickerSection
            weightsList
        }
        .navigationTitle(presenter.bodyWeight.name)
        .navigationBarTitleDisplayMode(.inline)
        .screenAppearAnalytics(name: "EditBodyWeightView")
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
    
    func editBodyWeightView(router: Router, bodyWeight: Binding<BodyWeights>) -> some View {
        EditBodyWeightView(
            presenter: EditBodyWeightPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                bodyWeight: bodyWeight
            )
        )
    }
    
}

extension CoreRouter {
    
    func showEditBodyWeightView(bodyWeight: Binding<BodyWeights>) {
        router.showScreen(.sheet) { router in
            builder.editBodyWeightView(router: router, bodyWeight: bodyWeight)
        }
    }
    
}

#Preview {
    @Previewable @State var bodyWeight: BodyWeights = BodyWeights.mock
    let container = DevPreview.shared.container
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return RouterView { router in
        builder.editBodyWeightView(router: router, bodyWeight: $bodyWeight)
    }
    .previewEnvironment()
}
