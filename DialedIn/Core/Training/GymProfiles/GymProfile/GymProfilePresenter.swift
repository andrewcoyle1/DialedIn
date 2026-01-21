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
    
    func onEditFreeWeightPressed(freeWeight: Binding<FreeWeights>) {
        router.showEditFreeWeightView(freeWeight: freeWeight)
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
