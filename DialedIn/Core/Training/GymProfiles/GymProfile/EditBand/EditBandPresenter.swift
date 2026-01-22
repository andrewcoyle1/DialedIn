import SwiftUI

@Observable
@MainActor
class EditBandPresenter {
    
    private let interactor: EditBandInteractor
    private let router: EditBandRouter
    
    private let bandBinding: Binding<Bands>
    var selectedUnit: ExerciseWeightUnit = .kilograms
    
    init(interactor: EditBandInteractor, router: EditBandRouter, bandBinding: Binding<Bands>) {
        self.interactor = interactor
        self.router = router
        self.bandBinding = bandBinding
    }

    var band: Bands {
        get { bandBinding.wrappedValue }
        set { bandBinding.wrappedValue = newValue }
    }

    func filteredWeightIDs(for unit: ExerciseWeightUnit) -> [String] {
        band.range
            .filter { $0.unit == unit }
            .map { $0.id }
    }

    func bindingForWeight(id: String, fallbackUnit: ExerciseWeightUnit) -> Binding<BandsAvailable> {
        Binding(
            get: {
                guard let index = self.band.range.firstIndex(where: { $0.id == id }) else {
                    return BandsAvailable(
                        id: id,
                        name: "",
                        bandColour: Color.red.asHex(),
                        availableResistance: 0,
                        unit: fallbackUnit,
                        isActive: false
                    )
                }
                return self.band.range[index]
            },
            set: { updated in
                guard let index = self.band.range.firstIndex(where: { $0.id == id }) else {
                    return
                }
                self.band.range[index] = updated
            }
        )
    }

    func deleteWeights(at offsets: IndexSet, weightIDs: [String]) {
        let idsToDelete = offsets.compactMap { offset in
            weightIDs.indices.contains(offset) ? weightIDs[offset] : nil
        }
        guard !idsToDelete.isEmpty else { return }

        var updated = band
        updated.range.removeAll { idsToDelete.contains($0.id) }
        band = updated
    }
    
    func onDismissPressed() {
        router.dismissScreen()
    }
}
