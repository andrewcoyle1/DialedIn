import SwiftUI

@Observable
@MainActor
class AddFreeWeightPresenter {
    
    private let interactor: AddFreeWeightInteractor
    private let router: AddFreeWeightRouter
    
    var freeWeight: Binding<FreeWeights>
    
    var freeWeightAvailable: FreeWeightsAvailable
    let unit: ExerciseWeightUnit
    static let defaultColours: [Color] = [
        .primary,
        .red,
        .orange,
        .yellow,
        .green,
        .blue,
        .purple
    ]
    
    var colours: [Color] {
        Self.defaultColours
    }
    
    private(set) var selectedColour: Color?
    var selectedColourHex: String? {
        selectedColour?.asHex()
    }
    
    init(interactor: AddFreeWeightInteractor, router: AddFreeWeightRouter, delegate: AddFreeWeightDelegate) {
        self.interactor = interactor
        self.router = router
        self.freeWeight = delegate.freeWeight
        self.freeWeightAvailable = FreeWeightsAvailable(
            id: UUID().uuidString,
            availableWeights: 0,
            unit: delegate.unit,
            isActive: true
        )
        self.unit = delegate.unit
        self.selectedColour = delegate.freeWeight.wrappedValue.needsColour ? Self.defaultColours.first : .accentColor
    }
    
    func onColourPressed(colour: Color) {
        selectedColour = colour
        freeWeightAvailable.plateColour = selectedColourHex
    }
    
    func onDismissPressed() {
        router.dismissScreen()
    }
    
    func onSavePressed() {
        guard freeWeight.wrappedValue.range.contains(where: {
            $0.availableWeights == freeWeightAvailable.availableWeights && $0.unit == freeWeightAvailable.unit
        }) == false else {
            router.showSimpleAlert(title: "Unable to add", subtitle: "This weight is already added.")
            return 
        }
        self.freeWeight.wrappedValue.range.append(self.freeWeightAvailable)
        router.dismissScreen()
    }
}
