import SwiftUI

@Observable
@MainActor
class MuscleGroupPickerPresenter {
    
    private let interactor: MuscleGroupPickerInteractor
    private let router: MuscleGroupPickerRouter
    
    var selectedMuscleGroups: [Muscles: Bool] = [:]
    
    init(interactor: MuscleGroupPickerInteractor, router: MuscleGroupPickerRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    var upperMuscles: [Muscles] {
        Muscles.allCases.filter { $0.bodyRegion == .upperBody }
    }

    var lowerMuscles: [Muscles] {
        Muscles.allCases.filter { $0.bodyRegion == .lowerBody }
    }

    var canSave: Bool {
        true
    }
    
    var primaryCount: Int {
        selectedMuscleGroups.values.filter { !$0 }.count
    }

    var secondaryCount: Int {
        selectedMuscleGroups.values.filter { $0 }.count
    }
    
    func onMuscleGroupPressed(muscle: Muscles) {
        if let isSecondary = selectedMuscleGroups[muscle] {
            if isSecondary {
                selectedMuscleGroups.removeValue(forKey: muscle)
            } else {
                selectedMuscleGroups[muscle] = true
            }
        } else {
            selectedMuscleGroups[muscle] = false
        }
    }
    
    func onNextPressed(delegate: MuscleGroupPickerDelegate) {
        let newDelegate = ExerciseEquipmentDelegate(
            name: delegate.name,
            trackableMetricA: delegate.trackableMetricA,
            trackableMetricB: delegate.trackableMetricB,
            exerciseType: delegate.exerciseType,
            laterality: delegate.laterality,
            muscleGroups: selectedMuscleGroups
        )

        router.showExerciseEquipmentView(delegate: newDelegate)
    }
    
    func onResetPressed() {
        selectedMuscleGroups = [:]
    }
}
