import SwiftUI

@Observable
@MainActor
class AddBodyWeightPresenter {
    
    private let interactor: AddBodyWeightInteractor
    private let router: AddBodyWeightRouter
    
    var bodyWeight: Binding<BodyWeights>
    
    var bodyWeightAvailable: BodyWeightsAvailable
    let unit: ExerciseWeightUnit
        
    init(interactor: AddBodyWeightInteractor, router: AddBodyWeightRouter, delegate: AddBodyWeightDelegate) {
        self.interactor = interactor
        self.router = router
        self.bodyWeight = delegate.bodyWeight
        self.bodyWeightAvailable = BodyWeightsAvailable(
            id: UUID().uuidString,
            availableWeights: 0,
            unit: delegate.unit,
            isActive: true
        )
        self.unit = delegate.unit
    }
        
    func onDismissPressed() {
        router.dismissScreen()
    }
    
    func onSavePressed() {
        guard bodyWeight.wrappedValue.range.contains(where: {
            $0.availableWeights == bodyWeightAvailable.availableWeights && $0.unit == bodyWeightAvailable.unit
        }) == false else {
            router.showSimpleAlert(title: "Unable to add", subtitle: "This weight is already added.")
            return 
        }
        self.bodyWeight.wrappedValue.range.append(self.bodyWeightAvailable)
        router.dismissScreen()
    }
}
