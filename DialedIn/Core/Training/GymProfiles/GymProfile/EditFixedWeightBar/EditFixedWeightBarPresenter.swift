import SwiftUI

@Observable
@MainActor
class EditFixedWeightBarPresenter {
    
    private let interactor: EditFixedWeightBarInteractor
    private let router: EditFixedWeightBarRouter
    
    private let fixedWeightBarBinding: Binding<FixedWeightBars>
    var selectedUnit: ExerciseWeightUnit
    
    init(interactor: EditFixedWeightBarInteractor, router: EditFixedWeightBarRouter, fixedWeightBarBinding: Binding<FixedWeightBars>) {
        self.interactor = interactor
        self.router = router
        self.fixedWeightBarBinding = fixedWeightBarBinding
        self.selectedUnit = fixedWeightBarBinding.wrappedValue.defaultBaseWeight?.unit ?? .kilograms
    }

    var fixedWeightBar: FixedWeightBars {
        get { fixedWeightBarBinding.wrappedValue }
        set { fixedWeightBarBinding.wrappedValue = newValue }
    }

    func filteredWeightIDs(for unit: ExerciseWeightUnit) -> [String] {
        fixedWeightBar.baseWeights
            .filter { $0.unit == unit }
            .map { $0.id }
    }

    func bindingForWeight(id: String, fallbackUnit: ExerciseWeightUnit) -> Binding<FixedWeightBarsBaseWeight> {
        Binding(
            get: {
                guard let index = self.fixedWeightBar.baseWeights.firstIndex(where: { $0.id == id }) else {
                    return FixedWeightBarsBaseWeight(
                        id: id,
                        baseWeight: 0,
                        unit: fallbackUnit,
                        isActive: false
                    )
                }
                return self.fixedWeightBar.baseWeights[index]
            },
            set: { updated in
                guard let index = self.fixedWeightBar.baseWeights.firstIndex(where: { $0.id == id }) else {
                    return
                }
                self.fixedWeightBar.baseWeights[index] = updated
            }
        )
    }

    func deleteWeights(at offsets: IndexSet, weightIDs: [String]) {
        let idsToDelete = offsets.compactMap { offset in
            weightIDs.indices.contains(offset) ? weightIDs[offset] : nil
        }
        guard !idsToDelete.isEmpty else { return }

        var updated = fixedWeightBar
        updated.baseWeights.removeAll { idsToDelete.contains($0.id) }
        fixedWeightBar = updated
    }
    
    func onDismissPressed() {
        router.dismissScreen()
    }
}
