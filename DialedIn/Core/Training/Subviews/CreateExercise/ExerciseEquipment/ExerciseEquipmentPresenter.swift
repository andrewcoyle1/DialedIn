import SwiftUI

@Observable
@MainActor
class ExerciseEquipmentPresenter {
    
    private let interactor: ExerciseEquipmentInteractor
    private let router: ExerciseEquipmentRouter
    
    init(interactor: ExerciseEquipmentInteractor, router: ExerciseEquipmentRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    var bodyweightExercise: Bool = false
    
    var supportEquipment: [EquipmentRef] = []
    
    var chosenResistanceEquipment: [EquipmentRef] = []
    
    private var equipmentIndex: [EquipmentRef: AnyEquipment] = [:]
    
    var canContinue: Bool {
        self.bodyweightExercise || !self.chosenResistanceEquipment.isEmpty
    }

    var resistanceSubtitle: String? {
        let array: [String] = chosenResistanceEquipment.isEmpty
        ? ["Equipment that adds load to the exercise"]
        : chosenResistanceEquipment.map { name(for: $0) }
        
        if !array.isEmpty {
            return "\(array.joined(separator: ", "))"
        } else {
            return nil
        }
    }

    var resistanceSubsubtitle: String? {
        chosenResistanceEquipment.isEmpty ? "Required" : nil
    }
    
    func onNextPressed() {
        
    }
    
    func onAddResistancePressed() {
        Task {
            do {
                let gymProfile = try await interactor.readFavouriteGymProfile()
                equipmentIndex = gymProfile.equipmentIndex
                
                let chosenBinding = Binding<[EquipmentRef]>(
                    get: { self.chosenResistanceEquipment },
                    set: { self.chosenResistanceEquipment = $0 }
                )
                
                let equipmentItems = gymProfile.allEquipment.filter { $0.ref.kind == .freeWeight }
                let delegate = EquipmentPickerDelegate(
                    items: equipmentItems,
                    headerTitle: "Free Weights",
                    chosenItem: chosenBinding
                )
                
                router.showEquipmentPickerView(delegate: delegate)
            } catch {
                router.showSimpleAlert(title: "No Equipment Data", subtitle: "Unable to load gym profile. Please set a favourite gym profile and try again.")
            }
        }
    }
    
    func onAddSupportPressed() {
        
    }
    
    private func name(for equipmentRef: EquipmentRef) -> String {
        equipmentIndex[equipmentRef]?.name ?? equipmentRef.equipmentId
    }
}
