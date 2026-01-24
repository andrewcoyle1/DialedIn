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
    
    func onSelect<Item: ResistanceEquipment>(item: Item, binding: Binding<[Item]>) {
        if let index = binding.wrappedValue.firstIndex(of: item) {
            binding.wrappedValue.remove(at: index)
        } else {
            binding.wrappedValue.append(item)
        }
    }
    
    func onDismissPressed() {
        router.dismissScreen()
    }
}
