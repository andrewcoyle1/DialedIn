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
        self.selectedUnit = plateLoadedMachineBinding.wrappedValue.unit
    }

    var plateLoadedMachine: PlateLoadedMachine {
        get { plateLoadedMachineBinding.wrappedValue }
        set { plateLoadedMachineBinding.wrappedValue = newValue }
    }
    
    func onDismissPressed() {
        router.dismissScreen()
    }
}
