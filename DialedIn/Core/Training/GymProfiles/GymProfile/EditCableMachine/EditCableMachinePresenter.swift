import SwiftUI

@Observable
@MainActor
class EditCableMachinePresenter {
    
    private let interactor: EditCableMachineInteractor
    private let router: EditCableMachineRouter
    
    private let cableMachineBinding: Binding<CableMachine>
    var selectedUnit: ExerciseWeightUnit
    var cableMachine: CableMachine {
        didSet {
            cableMachineBinding.wrappedValue = cableMachine
        }
    }
    
    init(interactor: EditCableMachineInteractor, router: EditCableMachineRouter, cableMachineBinding: Binding<CableMachine>) {
        self.interactor = interactor
        self.router = router
        self.cableMachineBinding = cableMachineBinding
        self.cableMachine = cableMachineBinding.wrappedValue
        self.selectedUnit = cableMachineBinding.wrappedValue.defaultRange?.unit ?? .kilograms
    }

    func filteredWeightIDs(for unit: ExerciseWeightUnit) -> [String] {
        cableMachine.ranges
            .filter { $0.unit == unit }
            .map { $0.id }
    }

    func bindingForWeight(id: String, fallbackUnit: ExerciseWeightUnit) -> Binding<CableMachineRange> {
        Binding(
            get: {
                guard let index = self.cableMachine.ranges.firstIndex(where: { $0.id == id }) else {
                    return CableMachineRange(
                        id: id,
                        minWeight: 0,
                        maxWeight: 120,
                        increment: 2.5,
                        unit: fallbackUnit,
                        isActive: false
                    )
                }
                return self.cableMachine.ranges[index]
            },
            set: { updated in
                guard let index = self.cableMachine.ranges.firstIndex(where: { $0.id == id }) else {
                    return
                }
                var updatedMachine = self.cableMachine
                updatedMachine.ranges[index] = updated
                self.cableMachine = updatedMachine
            }
        )
    }

    func deleteWeights(at offsets: IndexSet, weightIDs: [String]) {
        let idsToDelete = offsets.compactMap { offset in
            weightIDs.indices.contains(offset) ? weightIDs[offset] : nil
        }
        guard !idsToDelete.isEmpty else { return }

        var updated = cableMachine
        updated.ranges.removeAll { idsToDelete.contains($0.id) }
        cableMachine = updated
    }
    
    func onEditRangePressed(range: Binding<CableMachineRange>) {
        router.showEditWeightRangeView(delegate: EditWeightRangeDelegate(equipmentName: cableMachine.name, range: range))
    }
    
    func onDismissPressed() {
        router.dismissScreen()
    }
}
