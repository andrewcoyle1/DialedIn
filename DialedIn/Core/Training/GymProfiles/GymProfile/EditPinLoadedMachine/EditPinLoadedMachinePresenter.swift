import SwiftUI

@Observable
@MainActor
class EditPinLoadedMachinePresenter {
    
    private let interactor: EditPinLoadedMachineInteractor
    private let router: EditPinLoadedMachineRouter
    
    private let pinLoadedMachineBinding: Binding<PinLoadedMachine>
    var selectedUnit: ExerciseWeightUnit
    
    init(interactor: EditPinLoadedMachineInteractor, router: EditPinLoadedMachineRouter, pinLoadedMachineBinding: Binding<PinLoadedMachine>) {
        self.interactor = interactor
        self.router = router
        self.pinLoadedMachineBinding = pinLoadedMachineBinding
        self.selectedUnit = pinLoadedMachineBinding.wrappedValue.defaultRange?.unit ?? .kilograms
    }

    var pinLoadedMachine: PinLoadedMachine {
        get { pinLoadedMachineBinding.wrappedValue }
        set { pinLoadedMachineBinding.wrappedValue = newValue }
    }

    func filteredWeightIDs(for unit: ExerciseWeightUnit) -> [String] {
        pinLoadedMachine.ranges
            .filter { $0.unit == unit }
            .map { $0.id }
    }

    func bindingForWeight(id: String, fallbackUnit: ExerciseWeightUnit) -> Binding<PinLoadedMachineRange> {
        Binding(
            get: {
                guard let index = self.pinLoadedMachine.ranges.firstIndex(where: { $0.id == id }) else {
                    return PinLoadedMachineRange(
                        id: id,
                        minWeight: 0,
                        maxWeight: 150,
                        increment: 2.5,
                        unit: fallbackUnit,
                        isActive: false
                    )
                }
                return self.pinLoadedMachine.ranges[index]
            },
            set: { updated in
                guard let index = self.pinLoadedMachine.ranges.firstIndex(where: { $0.id == id }) else {
                    return
                }
                self.pinLoadedMachine.ranges[index] = updated
            }
        )
    }

    func deleteWeights(at offsets: IndexSet, weightIDs: [String]) {
        let idsToDelete = offsets.compactMap { offset in
            weightIDs.indices.contains(offset) ? weightIDs[offset] : nil
        }
        guard !idsToDelete.isEmpty else { return }

        var updated = pinLoadedMachine
        updated.ranges.removeAll { idsToDelete.contains($0.id) }
        pinLoadedMachine = updated
    }
    
    func onEditRangePressed(range: Binding<PinLoadedMachineRange>) {
        router.showEditWeightRangeView(delegate: EditWeightRangeDelegate(equipmentName: pinLoadedMachine.name, range: range))
    }
    
    func onDismissPressed() {
        router.dismissScreen()
    }
}
