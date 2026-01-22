import SwiftUI

@Observable
@MainActor
class EditLoadableAccessoryPresenter {
    
    private let interactor: EditLoadableAccessoryInteractor
    private let router: EditLoadableAccessoryRouter
    
    private let loadableAccessoryBinding: Binding<LoadableAccessoryEquipment>
    var selectedUnit: ExerciseWeightUnit
    
    init(interactor: EditLoadableAccessoryInteractor, router: EditLoadableAccessoryRouter, loadableAccessoryBinding: Binding<LoadableAccessoryEquipment>) {
        self.interactor = interactor
        self.router = router
        self.loadableAccessoryBinding = loadableAccessoryBinding
        self.selectedUnit = loadableAccessoryBinding.wrappedValue.defaultBaseWeight?.unit ?? .kilograms
    }

    var loadableAccessory: LoadableAccessoryEquipment {
        get { loadableAccessoryBinding.wrappedValue }
        set { loadableAccessoryBinding.wrappedValue = newValue }
    }

    func filteredWeightIDs(for unit: ExerciseWeightUnit) -> [String] {
        loadableAccessory.baseWeights
            .filter { $0.unit == unit }
            .map { $0.id }
    }

    func bindingForWeight(id: String, fallbackUnit: ExerciseWeightUnit) -> Binding<LoadableAccessoryEquipmentRange> {
        Binding(
            get: {
                guard let index = self.loadableAccessory.baseWeights.firstIndex(where: { $0.id == id }) else {
                    return LoadableAccessoryEquipmentRange(
                        id: id,
                        baseWeight: 0,
                        unit: fallbackUnit,
                        isActive: false
                    )
                }
                return self.loadableAccessory.baseWeights[index]
            },
            set: { updated in
                guard let index = self.loadableAccessory.baseWeights.firstIndex(where: { $0.id == id }) else {
                    return
                }
                self.loadableAccessory.baseWeights[index] = updated
            }
        )
    }

    func deleteWeights(at offsets: IndexSet, weightIDs: [String]) {
        let idsToDelete = offsets.compactMap { offset in
            weightIDs.indices.contains(offset) ? weightIDs[offset] : nil
        }
        guard !idsToDelete.isEmpty else { return }

        var updated = loadableAccessory
        updated.baseWeights.removeAll { idsToDelete.contains($0.id) }
        loadableAccessory = updated
    }
    
    func onDismissPressed() {
        router.dismissScreen()
    }
}
