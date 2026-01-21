import SwiftUI

struct GymProfileView: View {
    
    @State var presenter: GymProfilePresenter
    
    var body: some View {
        List {
            equipmentHeader
            if !presenter.filteredFreeWeights.isEmpty {
                freeWeightsSection
            }
            if !presenter.filteredLoadableBars.isEmpty {
                loadableBarsSection
            }
            if !presenter.filteredSupportEquipment.isEmpty {
                benchesAndRacksSection
            }
            if !presenter.filteredCableMachines.isEmpty {
                cableMachinesSection
            }
            if !presenter.filteredPlateLoadedMachines.isEmpty {
                plateLoadedMachineSection
            }
            if !presenter.filteredPinLoadedMachines.isEmpty {
                pinLoadedMachineSection
            }
        }
        .scrollIndicators(.hidden)
        .navigationTitle(presenter.gymProfile.name)
        .navigationBarTitleDisplayMode(.inline)
        .screenAppearAnalytics(name: "GymProfileView")
        .searchable(text: $presenter.searchQuery, prompt: "Filter equipment by name")
    }
    
    private var equipmentHeader: some View {
        Section {
            HStack {
                Text("Equipment")
                    .font(.headline)
                Spacer()
                Picker("", selection: $presenter.filter) {
                    ForEach(ListFilter.allCases, id: \.self) { option in
                        Text(option.description)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 160)
            }
            .removeListRowFormatting()
        }
        .listSectionMargins(.vertical, 0)

    }
    
    private var freeWeightsSection: some View {
        Section {
            if presenter.filteredFreeWeights.isEmpty {
                ContentUnavailableView("No Weights", image: "dumbbell", description: Text("There are no weights added to this gym."))
            } else {
                ForEach(presenter.filteredFreeWeights) { $freeWeight in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(freeWeight.name)
                            Text(freeWeight.range.map { "\(String(format: "%g", $0.availableWeights)) \($0.unit.abbreviation)" }.joined(separator: ", "))
                                .font(.caption)
                                .lineLimit(2)
                            Text("Edit Weights")
                                .underline()
                                .font(.caption.bold())
                                .anyButton {
                                    presenter.onEditFreeWeightPressed(freeWeight: $freeWeight)
                                }
                        }
                        Spacer()
                        Toggle("", isOn: $freeWeight.isActive)
                            .labelsHidden()
                    }
                }
            }
        } header: {
            Text("Free Weights")
        }
        .listSectionMargins(.top, 0)
    }
    
    private var loadableBarsSection: some View {
        Section {
            ForEach(presenter.filteredLoadableBars) { $loadableBar in
                HStack {
                    VStack(alignment: .leading) {
                        Text(loadableBar.name)
                        Text(loadableBar.baseWeights.map { "\(String(format: "%g", $0.baseWeight)) \($0.unit.abbreviation)" }.joined(separator: ", "))
                            .font(.caption)
                            .lineLimit(2)
                    }
                    Spacer()
                    Toggle("", isOn: $loadableBar.isActive)
                        .labelsHidden()
                }
            }
        } header: {
            Text("Loadable Bars")
        }
    }
    
    private var benchesAndRacksSection: some View {
        Section {
            ForEach(presenter.filteredSupportEquipment) { $supportEquipment in
                HStack {
                    VStack(alignment: .leading) {
                        Text(supportEquipment.name)
                    }
                    Spacer()
                    Toggle("", isOn: $supportEquipment.isActive)
                        .labelsHidden()
                }
            }
        } header: {
            Text("Benches & Racks")
        }
    }
    
    private var cableMachinesSection: some View {
        Section {
            ForEach(presenter.filteredCableMachines) { $cableMachines in
                HStack {
                    VStack(alignment: .leading) {
                        Text(cableMachines.name)
                        Text(cableMachines.ranges.map { "\(String(format: "%g", $0.minWeight)) - \(String(format: "%g", $0.maxWeight)) \($0.unit.abbreviation), \(String(format: "%g", $0.increment)) \($0.unit.abbreviation) increments" }.joined(separator: "\n"))
                            .font(.caption)
                            .lineLimit(2)
                    }
                    Spacer()
                    Toggle("", isOn: $cableMachines.isActive)
                        .labelsHidden()
                }
            }
        } header: {
            Text("Cable Machines")
        }
    }
    
    private var plateLoadedMachineSection: some View {
        Section {
            ForEach(presenter.filteredPlateLoadedMachines) { $plateLoadedMachines in
                HStack {
                    VStack(alignment: .leading) {
                        Text(plateLoadedMachines.name)
                        Text(plateLoadedMachines.baseWeights.map { "\(String(format: "%g", $0.baseWeight)) \($0.unit.abbreviation)" }.joined(separator: ", "))
                            .font(.caption)
                            .lineLimit(2)

                    }
                    Spacer()
                    Toggle("", isOn: $plateLoadedMachines.isActive)
                        .labelsHidden()
                }
            }
        } header: {
            Text("Cable Machines")
        }
    }
    
    private var pinLoadedMachineSection: some View {
        Section {
            ForEach(presenter.filteredPinLoadedMachines) { $pinLoadedMachines in
                HStack {
                    VStack(alignment: .leading) {
                        Text(pinLoadedMachines.name)
                        Text(pinLoadedMachines.ranges.map { "\(String(format: "%g", $0.minWeight)) - \(String(format: "%g", $0.maxWeight)) \($0.unit.abbreviation), \(String(format: "%g", $0.increment)) \($0.unit.abbreviation) increments" }.joined(separator: "\n"))
                            .font(.caption)
                            .lineLimit(2)

                    }
                    Spacer()
                    Toggle("", isOn: $pinLoadedMachines.isActive)
                        .labelsHidden()
                }
            }
        } header: {
            Text("Cable Machines")
        }
    }
}

extension CoreBuilder {
    
    func gymProfileView(router: Router, gymProfile: GymProfileModel) -> some View {
        GymProfileView(
            presenter: GymProfilePresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                gymProfile: gymProfile
            )
        )
    }
    
}

extension CoreRouter {
    
    func showGymProfileView(gymProfile: GymProfileModel) {
        router.showScreen(.push) { router in
            builder.gymProfileView(router: router, gymProfile: gymProfile)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return RouterView { router in
        builder.gymProfileView(router: router, gymProfile: GymProfileModel.mock)
    }
    .previewEnvironment()
}
