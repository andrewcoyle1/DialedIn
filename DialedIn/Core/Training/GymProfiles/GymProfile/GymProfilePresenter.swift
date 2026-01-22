import SwiftUI

@Observable
@MainActor
class GymProfilePresenter {
    
    private let interactor: GymProfileInteractor
    private let router: GymProfileRouter
    
    var filter: ListFilter = .all
    var gymProfile: GymProfileModel
    var searchQuery: String = ""

    private var trimmedSearchQuery: String {
        searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    init(interactor: GymProfileInteractor, router: GymProfileRouter, gymProfile: GymProfileModel) {
        self.interactor = interactor
        self.router = router
        self.gymProfile = gymProfile
    }

    var filteredFreeWeights: [Binding<FreeWeights>] {
        let query = trimmedSearchQuery
        let indices = gymProfile.freeWeights.indices.filter {
            let item = gymProfile.freeWeights[$0]
            let matchesQuery = query.isEmpty || item.name.localizedCaseInsensitiveContains(query)
            let matchesFilter = filter == .all || item.isActive
            return matchesQuery && matchesFilter
        }
        return indices.map { index in
            Binding(
                get: { self.gymProfile.freeWeights[index] },
                set: { self.gymProfile.freeWeights[index] = $0 }
            )
        }
    }

    var filteredLoadableBars: [Binding<LoadableBars>] {
        let query = trimmedSearchQuery
        let indices = gymProfile.loadableBars.indices.filter {
            let item = gymProfile.loadableBars[$0]
            let matchesQuery = query.isEmpty || item.name.localizedCaseInsensitiveContains(query)
            let matchesFilter = filter == .all || item.isActive
            return matchesQuery && matchesFilter
        }
        return indices.map { index in
            Binding(
                get: { self.gymProfile.loadableBars[index] },
                set: { self.gymProfile.loadableBars[index] = $0 }
            )
        }
    }

    var filteredFixedWeightBars: [Binding<FixedWeightBars>] {
        let query = trimmedSearchQuery
        let indices = gymProfile.fixedWeightBars.indices.filter {
            let item = gymProfile.fixedWeightBars[$0]
            let matchesQuery = query.isEmpty || item.name.localizedCaseInsensitiveContains(query)
            let matchesFilter = filter == .all || item.isActive
            return matchesQuery && matchesFilter
        }
        return indices.map { index in
            Binding(
                get: { self.gymProfile.fixedWeightBars[index] },
                set: { self.gymProfile.fixedWeightBars[index] = $0 }
            )
        }
    }

    var filteredBands: [Binding<Bands>] {
        let query = trimmedSearchQuery
        let indices = gymProfile.bands.indices.filter {
            let item = gymProfile.bands[$0]
            let matchesQuery = query.isEmpty || item.name.localizedCaseInsensitiveContains(query)
            let matchesFilter = filter == .all || item.isActive
            return matchesQuery && matchesFilter
        }
        return indices.map { index in
            Binding(
                get: { self.gymProfile.bands[index] },
                set: { self.gymProfile.bands[index] = $0 }
            )
        }
    }
    
    var filteredBodyWeights: [Binding<BodyWeights>] {
        let query = trimmedSearchQuery
        let indices = gymProfile.bodyWeights.indices.filter {
            let item = gymProfile.bodyWeights[$0]
            let matchesQuery = query.isEmpty || item.name.localizedCaseInsensitiveContains(query)
            let matchesFilter = filter == .all || item.isActive
            return matchesQuery && matchesFilter
        }
        return indices.map { index in
            Binding(
                get: { self.gymProfile.bodyWeights[index] },
                set: { self.gymProfile.bodyWeights[index] = $0 }
            )
        }
    }

    var filteredSupportEquipment: [Binding<SupportEquipment>] {
        let query = trimmedSearchQuery
        let indices = gymProfile.supportEquipment.indices.filter {
            let item = gymProfile.supportEquipment[$0]
            let matchesQuery = query.isEmpty || item.name.localizedCaseInsensitiveContains(query)
            let matchesFilter = filter == .all || item.isActive
            return matchesQuery && matchesFilter
        }
        return indices.map { index in
            Binding(
                get: { self.gymProfile.supportEquipment[index] },
                set: { self.gymProfile.supportEquipment[index] = $0 }
            )
        }
    }

    var filteredAccessoryEquipment: [Binding<AccessoryEquipment>] {
        let query = trimmedSearchQuery
        let indices = gymProfile.accessoryEquipment.indices.filter {
            let item = gymProfile.accessoryEquipment[$0]
            let matchesQuery = query.isEmpty || item.name.localizedCaseInsensitiveContains(query)
            let matchesFilter = filter == .all || item.isActive
            return matchesQuery && matchesFilter
        }
        return indices.map { index in
            Binding(
                get: { self.gymProfile.accessoryEquipment[index] },
                set: { self.gymProfile.accessoryEquipment[index] = $0 }
            )
        }
    }
    
    var filteredLoadableAccessoryEquipment: [Binding<LoadableAccessoryEquipment>] {
        let query = trimmedSearchQuery
        let indices = gymProfile.loadableAccessoryEquipment.indices.filter {
            let item = gymProfile.loadableAccessoryEquipment[$0]
            let matchesQuery = query.isEmpty || item.name.localizedCaseInsensitiveContains(query)
            let matchesFilter = filter == .all || item.isActive
            return matchesQuery && matchesFilter
        }
        return indices.map { index in
            Binding(
                get: { self.gymProfile.loadableAccessoryEquipment[index] },
                set: { self.gymProfile.loadableAccessoryEquipment[index] = $0 }
            )
        }
    }

    var filteredCableMachines: [Binding<CableMachine>] {
        let query = trimmedSearchQuery
        let indices = gymProfile.cableMachines.indices.filter {
            let item = gymProfile.cableMachines[$0]
            let matchesQuery = query.isEmpty || item.name.localizedCaseInsensitiveContains(query)
            let matchesFilter = filter == .all || item.isActive
            return matchesQuery && matchesFilter
        }
        return indices.map { index in
            Binding(
                get: { self.gymProfile.cableMachines[index] },
                set: { self.gymProfile.cableMachines[index] = $0 }
            )
        }
    }

    var filteredPlateLoadedMachines: [Binding<PlateLoadedMachine>] {
        let query = trimmedSearchQuery
        let indices = gymProfile.plateLoadedMachines.indices.filter {
            let item = gymProfile.plateLoadedMachines[$0]
            let matchesQuery = query.isEmpty || item.name.localizedCaseInsensitiveContains(query)
            let matchesFilter = filter == .all || item.isActive
            return matchesQuery && matchesFilter
        }
        return indices.map { index in
            Binding(
                get: { self.gymProfile.plateLoadedMachines[index] },
                set: { self.gymProfile.plateLoadedMachines[index] = $0 }
            )
        }
    }

    var filteredPinLoadedMachines: [Binding<PinLoadedMachine>] {
        let query = trimmedSearchQuery
        let indices = gymProfile.pinLoadedMachines.indices.filter {
            let item = gymProfile.pinLoadedMachines[$0]
            let matchesQuery = query.isEmpty || item.name.localizedCaseInsensitiveContains(query)
            let matchesFilter = filter == .all || item.isActive
            return matchesQuery && matchesFilter
        }
        return indices.map { index in
            Binding(
                get: { self.gymProfile.pinLoadedMachines[index] },
                set: { self.gymProfile.pinLoadedMachines[index] = $0 }
            )
        }
    }
    
    func onBackButtonPressed() {
        Task {
            do {
                interactor.trackEvent(event: Event.saveGymProfileStart)
                guard !gymProfile.name.isEmpty else {
                    router.showAlert(
                        title: "Discard Gym Profile",
                        subtitle: "To save the gym profile, you must give it a name.",
                        buttons: {
                            AnyView(
                                Button(role: .destructive) {
                                    self.router.dismissScreen()
                                }
                            )
                        }
                    )
                    return
                }
                gymProfile.dateModified = .now
                try await interactor.updateGymProfile(profile: gymProfile)
                interactor.trackEvent(event: Event.saveGymProfileSuccess)
                router.dismissScreen()
            } catch {
                interactor.trackEvent(event: Event.saveGymProfileFail(error: error))
            }
        }
    }
        
    func onEditFreeWeightPressed(freeWeight: Binding<FreeWeights>) {
        router.showEditFreeWeightView(freeWeight: freeWeight)
    }

    func onEditLoadableBarPressed(loadableBar: Binding<LoadableBars>) {
        router.showEditLoadableBarView(loadableBar: loadableBar)
    }

    func onEditFixedWeightBarPressed(fixedWeightBar: Binding<FixedWeightBars>) {
        router.showEditFixedWeightBarView(fixedWeightBar: fixedWeightBar)
    }

    func onEditBandPressed(band: Binding<Bands>) {
        router.showEditBandView(band: band)
    }
    
    func onEditBodyWeightPressed(bodyWeight: Binding<BodyWeights>) {
        router.showEditBodyWeightView(bodyWeight: bodyWeight)
    }

    func onEditLoadableAccessoryEquipmentPressed(loadableAccessoryEquipment: Binding<LoadableAccessoryEquipment>) {
        router.showEditLoadableAccessoryView(loadableAccessory: loadableAccessoryEquipment)
    }

    func onEditCableMachinePressed(cableMachine: Binding<CableMachine>) {
        router.showEditCableMachineView(cableMachine: cableMachine)
    }

    func onEditPlateLoadedMachinePressed(plateLoadedMachine: Binding<PlateLoadedMachine>) {
        router.showEditPlateLoadedMachineView(plateLoadedMachine: plateLoadedMachine)
    }

    func onEditPinLoadedMachinePressed(pinLoadedMachine: Binding<PinLoadedMachine>) {
        router.showEditPinLoadedMachineView(pinLoadedMachine: pinLoadedMachine)
    }

    enum Event: LoggableEvent {
        case saveGymProfileStart
        case saveGymProfileSuccess
        case saveGymProfileFail(error: Error)
        
        var eventName: String {
            switch self {
            case .saveGymProfileStart:      return "GymProfileView_Save_Start"
            case .saveGymProfileSuccess:    return "GymProfileView_Save_Success"
            case .saveGymProfileFail:       return "GymProfileView_Save_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .saveGymProfileFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .saveGymProfileFail:
                return .severe
            default:
                return .analytic
            }
        }
    }

}

enum ListFilter: CaseIterable {
    case all
    case selected
    
    var description: String {
        switch self {
        case .all:
            return "All"
        case .selected:
            return "Selected"
        }
    }
}
