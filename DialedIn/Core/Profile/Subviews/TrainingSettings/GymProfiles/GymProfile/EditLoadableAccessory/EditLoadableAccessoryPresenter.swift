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
        self.selectedUnit = loadableAccessoryBinding.wrappedValue.unit
    }

    var loadableAccessory: LoadableAccessoryEquipment {
        get { loadableAccessoryBinding.wrappedValue }
        set { loadableAccessoryBinding.wrappedValue = newValue }
    }
    
    func onDismissPressed() {
        router.dismissScreen()
    }
}
