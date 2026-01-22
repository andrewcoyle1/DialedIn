import SwiftUI

struct EditBandView: View {
    
    @State var presenter: EditBandPresenter
    
    var body: some View {
        @Bindable var presenter = presenter
        List {
            pickerSection
            weightsList
        }
        .navigationTitle(presenter.band.name)
        .navigationBarTitleDisplayMode(.inline)
        .screenAppearAnalytics(name: "EditBandView")
        .scrollIndicators(.hidden)
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
                        Circle()
                            .frame(maxHeight: 20)
                            .foregroundStyle(Color(hex: weight.wrappedValue.bandColour))
                        VStack(alignment: .leading) {
                            Text(weight.wrappedValue.name)
                                .fontWeight(.semibold)
                            Text("Up to \(String(format: "%g", weight.wrappedValue.availableResistance)) \(weight.wrappedValue.unit.abbreviation)")
                                .font(.caption)
                        }
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
    
    func editBandView(router: Router, band: Binding<Bands>) -> some View {
        EditBandView(
            presenter: EditBandPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                bandBinding: band
            )
        )
    }
}

extension CoreRouter {
    
    func showEditBandView(band: Binding<Bands>) {
        router.showScreen(.sheet) { router in
            builder.editBandView(router: router, band: band)
        }
    }
}

#Preview {
    let container = DevPreview.shared.container
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let band = Bands.mock
    return RouterView { router in
        builder.editBandView(router: router, band: Binding.constant(band))
    }
    .previewEnvironment()
}
