import SwiftUI

@Observable
@MainActor
class AddLoadableBarPresenter {
    
    private let interactor: AddLoadableBarInteractor
    private let router: AddLoadableBarRouter
    
    var loadableBar: Binding<LoadableBars>
    
    var loadableBarBaseWeight: LoadableBarsBaseWeight
    let unit: ExerciseWeightUnit
    
    init(interactor: AddLoadableBarInteractor, router: AddLoadableBarRouter, delegate: AddLoadableBarDelegate) {
        self.interactor = interactor
        self.router = router
        self.loadableBar = delegate.loadableBar
        self.loadableBarBaseWeight = LoadableBarsBaseWeight(
            id: UUID().uuidString,
            baseWeight: 0,
            unit: delegate.unit,
            isActive: true
        )
        self.unit = delegate.unit
    }
        
    func onDismissPressed() {
        router.dismissScreen()
    }
    
    func onSavePressed() {
        guard loadableBar.wrappedValue.baseWeights.contains(where: {
            $0.baseWeight == loadableBarBaseWeight.baseWeight && $0.unit == loadableBarBaseWeight.unit
        }) == false else {
            router.showSimpleAlert(title: "Unable to add", subtitle: "This weight is already added.")
            return 
        }
        self.loadableBar.wrappedValue.baseWeights.append(self.loadableBarBaseWeight)
        router.dismissScreen()
    }
}
