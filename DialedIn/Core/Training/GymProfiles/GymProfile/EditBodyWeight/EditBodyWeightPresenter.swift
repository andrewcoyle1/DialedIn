import SwiftUI

@Observable
@MainActor
class EditBodyWeightPresenter {
    
    private let interactor: EditBodyWeightInteractor
    private let router: EditBodyWeightRouter
    
    private let bodyWeightBinding: Binding<BodyWeights>
    var selectedUnit: ExerciseWeightUnit = .kilograms
    
    init(interactor: EditBodyWeightInteractor, router: EditBodyWeightRouter, bodyWeight: Binding<BodyWeights>) {
        self.interactor = interactor
        self.router = router
        self.bodyWeightBinding = bodyWeight
    }

    var bodyWeight: BodyWeights {
        get { bodyWeightBinding.wrappedValue }
        set { bodyWeightBinding.wrappedValue = newValue }
    }

    func filteredWeightIDs(for unit: ExerciseWeightUnit) -> [String] {
        bodyWeight.range
            .filter { $0.unit == unit }
            .map { $0.id }
    }

    func bindingForWeight(id: String, fallbackUnit: ExerciseWeightUnit) -> Binding<BodyWeightsAvailable> {
        Binding(
            get: {
                guard let index = self.bodyWeight.range.firstIndex(where: { $0.id == id }) else {
                    return BodyWeightsAvailable(
                        id: id,
                        plateColour: nil,
                        availableWeights: 0,
                        unit: fallbackUnit,
                        isActive: false
                    )
                }
                return self.bodyWeight.range[index]
            },
            set: { updated in
                guard let index = self.bodyWeight.range.firstIndex(where: { $0.id == id }) else {
                    return
                }
                self.bodyWeight.range[index] = updated
            }
        )
    }

    func deleteWeights(at offsets: IndexSet, weightIDs: [String]) {
        let idsToDelete = offsets.compactMap { offset in
            weightIDs.indices.contains(offset) ? weightIDs[offset] : nil
        }
        guard !idsToDelete.isEmpty else { return }

        var updated = bodyWeight
        updated.range.removeAll { idsToDelete.contains($0.id) }
        bodyWeight = updated
    }
    
    func onDismissPressed() {
        router.dismissScreen()
    }
}
