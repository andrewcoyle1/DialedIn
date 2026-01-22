import SwiftUI

@Observable
@MainActor
class EditLoadableBarPresenter {
    
    private let interactor: EditLoadableBarInteractor
    private let router: EditLoadableBarRouter
    
    private let loadableBarBinding: Binding<LoadableBars>
    var selectedUnit: ExerciseWeightUnit
    
    init(interactor: EditLoadableBarInteractor, router: EditLoadableBarRouter, loadableBarBinding: Binding<LoadableBars>) {
        self.interactor = interactor
        self.router = router
        self.loadableBarBinding = loadableBarBinding
        self.selectedUnit = loadableBarBinding.wrappedValue.defaultBaseWeight?.unit ?? .kilograms
    }

    var loadableBar: LoadableBars {
        get { loadableBarBinding.wrappedValue }
        set { loadableBarBinding.wrappedValue = newValue }
    }

    func filteredWeightIDs(for unit: ExerciseWeightUnit) -> [String] {
        loadableBar.baseWeights
            .filter { $0.unit == unit }
            .map { $0.id }
    }

    func bindingForWeight(id: String, fallbackUnit: ExerciseWeightUnit) -> Binding<LoadableBarsBaseWeight> {
        Binding(
            get: {
                guard let index = self.loadableBar.baseWeights.firstIndex(where: { $0.id == id }) else {
                    return LoadableBarsBaseWeight(
                        id: id,
                        baseWeight: 0,
                        unit: fallbackUnit,
                        isActive: false
                    )
                }
                return self.loadableBar.baseWeights[index]
            },
            set: { updated in
                guard let index = self.loadableBar.baseWeights.firstIndex(where: { $0.id == id }) else {
                    return
                }
                self.loadableBar.baseWeights[index] = updated
            }
        )
    }

    func deleteWeights(at offsets: IndexSet, weightIDs: [String]) {
        let idsToDelete = offsets.compactMap { offset in
            weightIDs.indices.contains(offset) ? weightIDs[offset] : nil
        }
        guard !idsToDelete.isEmpty else { return }

        var updated = loadableBar
        updated.baseWeights.removeAll { idsToDelete.contains($0.id) }
        loadableBar = updated
    }
    
    func onDismissPressed() {
        router.dismissScreen()
    }
}
