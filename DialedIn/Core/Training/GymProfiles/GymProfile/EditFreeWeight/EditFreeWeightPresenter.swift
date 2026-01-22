import SwiftUI

@Observable
@MainActor
class EditFreeWeightPresenter {
    
    private let interactor: EditFreeWeightInteractor
    private let router: EditFreeWeightRouter
    
    private let freeWeightBinding: Binding<FreeWeights>
    var selectedUnit: ExerciseWeightUnit = .kilograms
    
    init(interactor: EditFreeWeightInteractor, router: EditFreeWeightRouter, freeWeight: Binding<FreeWeights>) {
        self.interactor = interactor
        self.router = router
        self.freeWeightBinding = freeWeight
        
    }

    var freeWeight: FreeWeights {
        get { freeWeightBinding.wrappedValue }
        set { freeWeightBinding.wrappedValue = newValue }
    }

    func filteredWeightIDs(for unit: ExerciseWeightUnit) -> [String] {
        freeWeight.range
            .filter { $0.unit == unit }
            .map { $0.id }
    }

    func bindingForWeight(id: String, fallbackUnit: ExerciseWeightUnit) -> Binding<FreeWeightsAvailable> {
        Binding(
            get: {
                guard let index = self.freeWeight.range.firstIndex(where: { $0.id == id }) else {
                    return FreeWeightsAvailable(
                        id: id,
                        plateColour: nil,
                        availableWeights: 0,
                        unit: fallbackUnit,
                        isActive: false
                    )
                }
                return self.freeWeight.range[index]
            },
            set: { updated in
                guard let index = self.freeWeight.range.firstIndex(where: { $0.id == id }) else {
                    return
                }
                self.freeWeight.range[index] = updated
            }
        )
    }

    func deleteWeights(at offsets: IndexSet, weightIDs: [String]) {
        let idsToDelete = offsets.compactMap { offset in
            weightIDs.indices.contains(offset) ? weightIDs[offset] : nil
        }
        guard !idsToDelete.isEmpty else { return }

        var updated = freeWeight
        updated.range.removeAll { idsToDelete.contains($0.id) }
        freeWeight = updated
    }
    
    func onDismissPressed() {
        router.dismissScreen()
    }
}
