import SwiftUI

@Observable
@MainActor
class EditPlateLoadedMachinePresenter {
    
    private let interactor: EditPlateLoadedMachineInteractor
    private let router: EditPlateLoadedMachineRouter
    
    private let plateLoadedMachineBinding: Binding<PlateLoadedMachine>
    var selectedUnit: ExerciseWeightUnit
    
    init(interactor: EditPlateLoadedMachineInteractor, router: EditPlateLoadedMachineRouter, plateLoadedMachineBinding: Binding<PlateLoadedMachine>) {
        self.interactor = interactor
        self.router = router
        self.plateLoadedMachineBinding = plateLoadedMachineBinding
        self.selectedUnit = plateLoadedMachineBinding.wrappedValue.defaultBaseWeight?.unit ?? .kilograms
    }

    var plateLoadedMachine: PlateLoadedMachine {
        get { plateLoadedMachineBinding.wrappedValue }
        set { plateLoadedMachineBinding.wrappedValue = newValue }
    }

    func filteredWeightIDs(for unit: ExerciseWeightUnit) -> [String] {
        plateLoadedMachine.baseWeights
            .filter { $0.unit == unit }
            .map { $0.id }
    }

    func bindingForWeight(id: String, fallbackUnit: ExerciseWeightUnit) -> Binding<PlateLoadedMachineRange> {
        Binding(
            get: {
                guard let index = self.plateLoadedMachine.baseWeights.firstIndex(where: { $0.id == id }) else {
                    return PlateLoadedMachineRange(
                        id: id,
                        baseWeight: 0,
                        unit: fallbackUnit,
                        isActive: false
                    )
                }
                return self.plateLoadedMachine.baseWeights[index]
            },
            set: { updated in
                guard let index = self.plateLoadedMachine.baseWeights.firstIndex(where: { $0.id == id }) else {
                    return
                }
                self.plateLoadedMachine.baseWeights[index] = updated
            }
        )
    }

    func deleteWeights(at offsets: IndexSet, weightIDs: [String]) {
        let idsToDelete = offsets.compactMap { offset in
            weightIDs.indices.contains(offset) ? weightIDs[offset] : nil
        }
        guard !idsToDelete.isEmpty else { return }

        var updated = plateLoadedMachine
        updated.baseWeights.removeAll { idsToDelete.contains($0.id) }
        plateLoadedMachine = updated
    }
    
    func onDismissPressed() {
        router.dismissScreen()
    }
}
