import SwiftUI

@Observable
@MainActor
class AddCableMachineRangePresenter {
    
    private let interactor: AddCableMachineRangeInteractor
    private let router: AddCableMachineRangeRouter
    
    var cableMachine: Binding<CableMachine>
    var range: CableMachineRange
    let unit: ExerciseWeightUnit
    
    init(interactor: AddCableMachineRangeInteractor, router: AddCableMachineRangeRouter, delegate: AddCableMachineRangeDelegate) {
        self.interactor = interactor
        self.router = router
        self.cableMachine = delegate.cableMachine
        self.unit = delegate.unit
        self.range = CableMachineRange(
            id: UUID().uuidString,
            name: "",
            minWeight: 0,
            maxWeight: 150,
            increment: 2.5,
            unit: delegate.unit,
            isActive: true
        )
    }
    
    func onDismissPressed() {
        router.dismissScreen()
    }
    
    func onSavePressed() {
        guard range.minWeight < range.maxWeight else {
            router.showSimpleAlert(title: "Unable to add", subtitle: "The range start must be less than the range end.")
            return
        }
        
        guard range.increment > 0 else {
            router.showSimpleAlert(title: "Unable to add", subtitle: "The increment must be greater than zero.")
            return
        }
        
        let normalizedName = range.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard cableMachine.wrappedValue.ranges.contains(where: {
            $0.name.trimmingCharacters(in: .whitespacesAndNewlines)
                .localizedCaseInsensitiveCompare(normalizedName) == .orderedSame
        }) == false else {
            router.showSimpleAlert(title: "Unable to add", subtitle: "A range with this name already exists.")
            return
        }
        
        guard cableMachine.wrappedValue.ranges.contains(where: {
            $0.minWeight == range.minWeight &&
            $0.maxWeight == range.maxWeight &&
            $0.increment == range.increment &&
            $0.unit == range.unit
        }) == false else {
            router.showSimpleAlert(title: "Unable to add", subtitle: "This range is already added.")
            return
        }
        
        var updatedMachine = cableMachine.wrappedValue
        updatedMachine.ranges.append(range)
        if updatedMachine.defaultRangeId == nil {
            updatedMachine.defaultRangeId = range.id
        }
        cableMachine.wrappedValue = updatedMachine
        router.dismissScreen()
    }
}
