import SwiftUI

@Observable
@MainActor
class ExerciseEquipmentPresenter {
    
    private let interactor: ExerciseEquipmentInteractor
    private let router: ExerciseEquipmentRouter
    
    var favouriteGymProfile: GymProfileModel? {
        interactor.favouriteGymProfile
    }
    
    init(interactor: ExerciseEquipmentInteractor, router: ExerciseEquipmentRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }
    
    func onViewDisappear() {
        interactor.trackEvent(event: Event.onDisappear)
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
        guard let gymProfile = favouriteGymProfile else { return }

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
    }
    
    func onAddSupportPressed() {
        guard let gymProfile = favouriteGymProfile else { return }
        
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
    }
    
    private func name(for equipmentRef: EquipmentRef) -> String {
        equipmentIndex[equipmentRef]?.name ?? equipmentRef.equipmentId
    }
    
}

extension ExerciseEquipmentPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case onDisappear
        
        var eventName: String {
            switch self {
            case .onAppear: return "ExerciseEquipmentView_Appear"
            case .onDisappear: return "ExerciseEquipmentView_Disappear"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
    }
}
