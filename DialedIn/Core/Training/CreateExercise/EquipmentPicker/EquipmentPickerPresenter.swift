import SwiftUI

@Observable
@MainActor
class EquipmentPickerPresenter {
    
    private let interactor: EquipmentPickerInteractor
    private let router: EquipmentPickerRouter
    
    init(interactor: EquipmentPickerInteractor, router: EquipmentPickerRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onSelect(item: AnyEquipment, binding: Binding<[EquipmentRef]>) {
        if let index = binding.wrappedValue.firstIndex(of: item.ref) {
            binding.wrappedValue.remove(at: index)
        } else {
            binding.wrappedValue.append(item.ref)
        }
    }
    
    func onDismissPressed() {
        router.dismissScreen()
    }
}
