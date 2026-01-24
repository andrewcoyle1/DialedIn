import SwiftUI

@Observable
@MainActor
class EnumPickerPresenter {
    
    private let interactor: EnumPickerInteractor
    private let router: EnumPickerRouter
    
    init(interactor: EnumPickerInteractor, router: EnumPickerRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onSelect<Item: PickableItem>(item: Item, binding: Binding<Item?>) {
        binding.wrappedValue = item
        router.dismissScreen()
    }
    
    func onDismissPressed() {
        router.dismissScreen()
    }
    
    func onDeletePressed<Item: PickableItem>(binding: Binding<Item?>) {
        binding.wrappedValue = nil
        router.dismissScreen()
    }

}
