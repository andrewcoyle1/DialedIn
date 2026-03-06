//
//  WorkoutExerciseEquipmentSheetPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 19/02/2026.
//

import Foundation

@Observable
@MainActor
class WorkoutExerciseEquipmentSheetPresenter {
    
    private let interactor: WorkoutExerciseEquipmentSheetInteractor
    private let router: WorkoutExerciseEquipmentSheetRouter
    
    var chosenResistance: [EquipmentRef] = []
    var chosenSupport: [EquipmentRef] = []
    private(set) var choosableResistance: [AnyEquipment] = []
    private(set) var choosableSupport: [AnyEquipment] = []
    private(set) var isLoading = true
    private(set) var loadError: String?
    
    var userId: String? {
        interactor.userId
    }
    
    var allExercises: [ExerciseModel] {
        interactor.allExercises
    }
    
    init(
        interactor: WorkoutExerciseEquipmentSheetInteractor,
        router: WorkoutExerciseEquipmentSheetRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func toggleResistance(ref: EquipmentRef) {
        if let idx = chosenResistance.firstIndex(of: ref) {
            chosenResistance.remove(at: idx)
        } else {
            chosenResistance.append(ref)
        }
    }

    func toggleSupport(ref: EquipmentRef) {
        if let idx = chosenSupport.firstIndex(of: ref) {
            chosenSupport.remove(at: idx)
        } else {
            chosenSupport.append(ref)
        }
    }

    func loadChoosableEquipment(exerciseModelId: String) async {
        guard let template = allExercises.first(where: { $0.id == exerciseModelId }) else { return }
        guard let uid = userId else { return }
        isLoading = true
        loadError = nil
        defer { isLoading = false }
        guard let gym = interactor.workoutGymProfile else {
            loadError = "Set a favourite gym profile to choose equipment."
            return
        }
        let resistanceRefs = template.resistanceEquipment
        let supportRefs = template.supportEquipment
        // Fall back to default equipment when the user's gym doesn't have a ref (e.g. older gym or subset)
        
        let fallbackGym = GymProfileModel(authorId: uid)
        choosableResistance = resistanceRefs.compactMap { gym.equipment(for: $0) ?? fallbackGym.equipment(for: $0) }.filter(\.isActive)
        choosableSupport = supportRefs.compactMap { gym.equipment(for: $0) ?? fallbackGym.equipment(for: $0) }.filter(\.isActive)
    }

    func onCancelPressed() {
        dismissScreen()
    }
    
    func onDonePressed(onSelect: @escaping ([EquipmentRef], [EquipmentRef]) -> Void) {
        onSelect(chosenResistance, chosenSupport)
        dismissScreen()
    }
    
    private func dismissScreen() {
        router.dismissScreen()
    }

}
