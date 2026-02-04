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
     
    var chosenResistanceEquipment: [EquipmentRef] = []
    var chosenSupportEquipment: [EquipmentRef] = []

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

    var supportSubtitle: String? {
        let array: [String] = chosenSupportEquipment.isEmpty ? ["Equipment that assists, stabilize, or makes the movement possible, without adding resistance."] : chosenSupportEquipment.map { name(for: $0)}

        if !array.isEmpty {
            return "\(array.joined(separator: ", "))"
        } else {
            return nil
        }
    }

    var supportSubsubtitle: String? {
        chosenSupportEquipment.isEmpty ? "Optional" : nil
    }

    func onNextPressed(delegate: ExerciseEquipmentDelegate) {
        router.showFinalExerciseDetailsView(
            delegate: FinalExerciseDetailsDelegate(
                name: delegate.name,
                trackableMetricA: delegate.trackableMetricA,
                trackableMetricB: delegate.trackableMetricB,
                exerciseType: delegate.exerciseType,
                laterality: delegate.laterality,
                targetMuscles: delegate.muscleGroups,
                isBodyweight: self.bodyweightExercise,
                resistanceEquipment: self.chosenResistanceEquipment,
                supportEquipment: self.chosenSupportEquipment
            )
        )
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
                
                let equipmentItems = gymProfile.allEquipment.filter {
                    $0.ref.kind != .supportEquipment && $0.ref.kind != .accessoryEquipment
                }
                let delegate = EquipmentPickerDelegate(
                    items: equipmentItems,
                    headerTitle: "Resistance Equipment",
                    chosenItem: chosenBinding
                )
                
                router.showEquipmentPickerView(delegate: delegate)
            } catch {
                router.showSimpleAlert(title: "No Equipment Data", subtitle: "Unable to load gym profile. Please set a favourite gym profile and try again.")
            }
        }
    }
    
    func onAddSupportPressed() {
        Task {
            do {
                let gymProfile = try await interactor.readFavouriteGymProfile()
                equipmentIndex = gymProfile.equipmentIndex

                let chosenBinding = Binding<[EquipmentRef]>(
                    get: { self.chosenSupportEquipment },
                    set: { self.chosenSupportEquipment = $0 }
                )

                let equipmentItems = gymProfile.allEquipment.filter {
                    $0.ref.kind != .supportEquipment || $0.ref.kind != .accessoryEquipment
                }
                let delegate = EquipmentPickerDelegate(
                    items: equipmentItems,
                    headerTitle: "Support Equipment",
                    chosenItem: chosenBinding
                )

                router.showEquipmentPickerView(delegate: delegate)
            } catch {
                router.showSimpleAlert(title: "No Equipment Data", subtitle: "Unable to load gym profile. Please set a favourite gym profile and try again.")
            }
        }
    }
    
    private func name(for equipmentRef: EquipmentRef) -> String {
        equipmentIndex[equipmentRef]?.name ?? equipmentRef.equipmentId
    }
}
