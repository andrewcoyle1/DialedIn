import SwiftUI
import PhotosUI

struct GymProfileView: View {
    
    @State var presenter: GymProfilePresenter
    
    var body: some View {
        List {
            imageHeader

            equipmentHeader
            if !presenter.filteredFreeWeights.isEmpty {
                freeWeightsSection
            }

            if !presenter.filteredLoadableBars.isEmpty {
                loadableBarsSection
            }

            if !presenter.filteredFixedWeightBars.isEmpty {
                fixedWeightBarsSection
            }

            if !presenter.filteredBands.isEmpty {
                bandsSection
            }
            
            if !presenter.filteredBodyWeights.isEmpty {
                bodyWeightsSection
            }
            
            if !presenter.filteredSupportEquipment.isEmpty {
                benchesAndRacksSection
            }

            if !presenter.filteredAccessoryEquipment.isEmpty {
                accessoriesSection
            }

            if !presenter.filteredLoadableAccessoryEquipment.isEmpty {
                loadableAccessoriesSection
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
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .screenAppearAnalytics(name: "GymProfileView")
        .searchable(text: $presenter.searchQuery, prompt: "Filter equipment by name")
        .toolbar {
            toolbarContent
        }
        .photosPicker(isPresented: $presenter.isImagePickerPresented, selection: $presenter.selectedPhotoItem, matching: .images)
        .onChange(of: presenter.selectedPhotoItem) {
            guard let newItem = presenter.selectedPhotoItem else { return }

            Task {
                await presenter.onImageSelectorChanged(newItem)
            }
        }

    }
    
    private var imageHeader: some View {
        Section {
            ImageLoaderView(urlString: presenter.gymProfile.imageUrl ?? Constants.randomImage, resizingMode: .fill)
                .frame(height: 300)
                .removeListRowFormatting()
        }
        .listSectionMargins(.top, 0)
        .listSectionMargins(.horizontal, 0)
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
                        if let imageName = freeWeight.imageName {
                            ImageLoaderView(urlString: imageName)
                                .frame(width: 40, height: 40)
                        } else {
                            Rectangle()
                                .foregroundStyle(.secondary.opacity(0.2))
                                .frame(width: 40, height: 40)
                                .cornerRadius(8)
                        }

                        VStack(alignment: .leading) {
                            Text(freeWeight.name)
                            Text(activeSortedWeightSubtitle(
                                items: freeWeight.range,
                                isActive: { $0.isActive },
                                value: { $0.availableWeights },
                                unit: { $0.unit },
                                formatter: { "\(String(format: "%g", $0.availableWeights)) \($0.unit.abbreviation)" },
                                separator: ", "
                            ))
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
                    if let imageName = loadableBar.imageName {
                        ImageLoaderView(urlString: imageName)
                            .frame(width: 40, height: 40)
                    } else {
                        Rectangle()
                            .foregroundStyle(.secondary.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .cornerRadius(8)
                    }
                    VStack(alignment: .leading) {
                        Text(loadableBar.name)
                        Text(activeSortedWeightSubtitle(
                            items: loadableBar.baseWeights,
                            isActive: { $0.isActive },
                            value: { $0.baseWeight },
                            unit: { $0.unit },
                            formatter: { "\(String(format: "%g", $0.baseWeight)) \($0.unit.abbreviation)" },
                            separator: ", "
                        ))
                            .font(.caption)
                            .lineLimit(2)
                        Text("Edit Weights")
                            .underline()
                            .font(.caption.bold())
                            .anyButton {
                                presenter.onEditLoadableBarPressed(loadableBar: $loadableBar)
                            }

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

    private var fixedWeightBarsSection: some View {
        Section {
            ForEach(presenter.filteredFixedWeightBars) { $fixedWeightBar in
                HStack {
                    if let imageName = fixedWeightBar.imageName {
                        ImageLoaderView(urlString: imageName)
                            .frame(width: 40, height: 40)
                    } else {
                        Rectangle()
                            .foregroundStyle(.secondary.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .cornerRadius(8)
                    }

                    VStack(alignment: .leading) {
                        Text(fixedWeightBar.name)
                        Text(activeSortedWeightSubtitle(
                            items: fixedWeightBar.baseWeights,
                            isActive: { $0.isActive },
                            value: { $0.baseWeight },
                            unit: { $0.unit },
                            formatter: { "\(String(format: "%g", $0.baseWeight)) \($0.unit.abbreviation)" },
                            separator: ", "
                        ))
                            .font(.caption)
                            .lineLimit(2)
                        Text("Edit Weights")
                            .underline()
                            .font(.caption.bold())
                            .anyButton {
                                presenter.onEditFixedWeightBarPressed(fixedWeightBar: $fixedWeightBar)
                            }

                    }
                    Spacer()
                    Toggle("", isOn: $fixedWeightBar.isActive)
                        .labelsHidden()
                }
            }
        } header: {
            Text("Fixed Weight Bars")
        }
    }

    private var bandsSection: some View {
        Section {
            ForEach(presenter.filteredBands) { $band in
                HStack {
                    if let imageName = band.imageName {
                        ImageLoaderView(urlString: imageName)
                            .frame(width: 40, height: 40)
                    } else {
                        Rectangle()
                            .foregroundStyle(.secondary.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .cornerRadius(8)
                    }

                    VStack(alignment: .leading) {
                        Text(band.name)
                        Text(activeSortedWeightSubtitle(
                            items: band.range,
                            isActive: { $0.isActive },
                            value: { $0.availableResistance },
                            unit: { $0.unit },
                            formatter: { "\(String(format: "%g", $0.availableResistance)) \($0.unit.abbreviation)" },
                            separator: ", "
                        ))
                            .font(.caption)
                            .lineLimit(2)
                        Text("Edit Inventory")
                            .underline()
                            .font(.caption.bold())
                            .anyButton {
                                presenter.onEditBandPressed(band: $band)
                            }

                    }
                    Spacer()
                    Toggle("", isOn: $band.isActive)
                        .labelsHidden()
                }
            }
        } header: {
            Text("Bands")
        }
    }
    
    private var bodyWeightsSection: some View {
        Section {
            if presenter.filteredBodyWeights.isEmpty {
                ContentUnavailableView("No Weights", image: "dumbbell", description: Text("There are no weights added to this gym."))
            } else {
                ForEach(presenter.filteredBodyWeights) { $bodyWeight in
                    HStack {
                        if let imageName = bodyWeight.imageName {
                            ImageLoaderView(urlString: imageName)
                                .frame(width: 40, height: 40)
                        } else {
                            Rectangle()
                                .foregroundStyle(.secondary.opacity(0.2))
                                .frame(width: 40, height: 40)
                                .cornerRadius(8)
                        }

                        VStack(alignment: .leading) {
                            Text(bodyWeight.name)
                            Text(activeSortedWeightSubtitle(
                                items: bodyWeight.range,
                                isActive: { $0.isActive },
                                value: { $0.availableWeights },
                                unit: { $0.unit },
                                formatter: { "\(String(format: "%g", $0.availableWeights)) \($0.unit.abbreviation)" },
                                separator: ", "
                            ))
                                .font(.caption)
                                .lineLimit(2)
                            Text("Edit Weights")
                                .underline()
                                .font(.caption.bold())
                                .anyButton {
                                    presenter.onEditBodyWeightPressed(bodyWeight: $bodyWeight)
                                }
                        }
                        Spacer()
                        Toggle("", isOn: $bodyWeight.isActive)
                            .labelsHidden()
                    }
                }
            }
        } header: {
            Text("Body Weights")
        }
        .listSectionMargins(.top, 0)
    }

    private var benchesAndRacksSection: some View {
        Section {
            ForEach(presenter.filteredSupportEquipment) { $supportEquipment in
                HStack {
                    if let imageName = supportEquipment.imageName {
                        ImageLoaderView(urlString: imageName)
                            .frame(width: 40, height: 40)
                    } else {
                        Rectangle()
                            .foregroundStyle(.secondary.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .cornerRadius(8)
                    }

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

    private var accessoriesSection: some View {
        Section {
            ForEach(presenter.filteredAccessoryEquipment) { $accessoryEquipment in
                HStack {
                    if let imageName = accessoryEquipment.imageName {
                        ImageLoaderView(urlString: imageName)
                            .frame(width: 40, height: 40)
                    } else {
                        Rectangle()
                            .foregroundStyle(.secondary.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .cornerRadius(8)
                    }

                    VStack(alignment: .leading) {
                        Text(accessoryEquipment.name)
                    }
                    Spacer()
                    Toggle("", isOn: $accessoryEquipment.isActive)
                        .labelsHidden()
                }
            }
        } header: {
            Text("Accessories")
        }
    }

    private var loadableAccessoriesSection: some View {
        Section {
            ForEach(presenter.filteredLoadableAccessoryEquipment) { $loadableAccessoryEquipment in
                HStack {
                    if let imageName = loadableAccessoryEquipment.imageName {
                        ImageLoaderView(urlString: imageName)
                            .frame(width: 40, height: 40)
                    } else {
                        Rectangle()
                            .foregroundStyle(.secondary.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .cornerRadius(8)
                    }

                    VStack(alignment: .leading) {
                        Text(loadableAccessoryEquipment.name)
                        Text("\(String(format: "%g", loadableAccessoryEquipment.baseWeight)) \(loadableAccessoryEquipment.unit.abbreviation)")
                            .font(.caption)
                            .lineLimit(2)
                        Text("Edit Base Weights")
                            .underline()
                            .font(.caption.bold())
                            .anyButton {
                                presenter.onEditLoadableAccessoryEquipmentPressed(loadableAccessoryEquipment: $loadableAccessoryEquipment)
                            }

                    }
                    Spacer()
                    Toggle("", isOn: $loadableAccessoryEquipment.isActive)
                        .labelsHidden()
                }
            }
        } header: {
            Text("Loadable Accessories")
        }
    }

    private var cableMachinesSection: some View {
        Section {
            ForEach(presenter.filteredCableMachines) { $cableMachines in
                HStack {
                    if let imageName = cableMachines.imageName {
                        ImageLoaderView(urlString: imageName)
                            .frame(width: 40, height: 40)
                    } else {
                        Rectangle()
                            .foregroundStyle(.secondary.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .cornerRadius(8)
                    }

                    VStack(alignment: .leading) {
                        Text(cableMachines.name)
                        Text(activeSortedWeightSubtitle(
                            items: cableMachines.ranges,
                            isActive: { $0.isActive },
                            value: { $0.minWeight },
                            unit: { $0.unit },
                            formatter: {
                                "\(String(format: "%g", $0.minWeight)) - \(String(format: "%g", $0.maxWeight)) \($0.unit.abbreviation), \(String(format: "%g", $0.increment)) \($0.unit.abbreviation) increments"
                            },
                            separator: "\n"
                        ))
                            .font(.caption)
                            .lineLimit(2)
                        Text("Edit Machine")
                            .underline()
                            .font(.caption.bold())
                            .anyButton {
                                presenter.onEditCableMachinePressed(cableMachine: $cableMachines)
                            }

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
                    if let imageName = plateLoadedMachines.imageName {
                        ImageLoaderView(urlString: imageName)
                            .frame(width: 40, height: 40)
                    } else {
                        Rectangle()
                            .foregroundStyle(.secondary.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .cornerRadius(8)
                    }
                    VStack(alignment: .leading) {
                        Text(plateLoadedMachines.name)
                        Text("\(String(format: "%g", plateLoadedMachines.baseWeight)) \(plateLoadedMachines.unit.abbreviation)")
                            .font(.caption)
                            .lineLimit(2)
                        Text("Edit Base Weight")
                            .underline()
                            .font(.caption.bold())
                            .anyButton {
                                presenter.onEditPlateLoadedMachinePressed(plateLoadedMachine: $plateLoadedMachines)
                            }

                    }
                    Spacer()
                    Toggle("", isOn: $plateLoadedMachines.isActive)
                        .labelsHidden()
                }
            }
        } header: {
            Text("Plate Loaded Machines")
        }
    }
    
    private var pinLoadedMachineSection: some View {
        Section {
            ForEach(presenter.filteredPinLoadedMachines) { $pinLoadedMachines in
                HStack {
                    if let imageName = pinLoadedMachines.imageName {
                        ImageLoaderView(urlString: imageName)
                            .frame(width: 40, height: 40)
                    } else {
                        Rectangle()
                            .foregroundStyle(.secondary.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .cornerRadius(8)
                    }
                    VStack(alignment: .leading) {
                        Text(pinLoadedMachines.name)
                        Text(activeSortedWeightSubtitle(
                            items: pinLoadedMachines.ranges,
                            isActive: { $0.isActive },
                            value: { $0.minWeight },
                            unit: { $0.unit },
                            formatter: {
                                "\(String(format: "%g", $0.minWeight)) - \(String(format: "%g", $0.maxWeight)) \($0.unit.abbreviation), \(String(format: "%g", $0.increment)) \($0.unit.abbreviation) increments"
                            },
                            separator: "\n"
                        ))
                            .font(.caption)
                            .lineLimit(2)
                        Text("Edit Machine")
                            .underline()
                            .font(.caption.bold())
                            .anyButton {
                                presenter.onEditPinLoadedMachinePressed(pinLoadedMachine: $pinLoadedMachines)
                            }

                    }
                    Spacer()
                    Toggle("", isOn: $pinLoadedMachines.isActive)
                        .labelsHidden()
                }
            }
        } header: {
            Text("Pin Loaded Machines")
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .title) {
            TextField(text: $presenter.gymProfile.name) {
                Text("Untitled Gym Profile")
            }
        }
        
        ToolbarItem(placement: .cancellationAction) {
            Button {
                presenter.onBackButtonPressed()
            } label: {
                Image(systemName: "chevron.left")
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.onAddImagePressed()
            } label: {
                Image(systemName: presenter.gymProfile.imageUrl == nil ? "photo.badge.plus" : "photo.badge.checkmark")
            }
        }
    }

    private func activeSortedWeightSubtitle<T>(
        items: [T],
        isActive: (T) -> Bool,
        value: (T) -> Double,
        unit: (T) -> ExerciseWeightUnit,
        formatter: (T) -> String,
        separator: String
    ) -> String {
        let sortedItems = items
            .filter(isActive)
            .enumerated()
            .sorted { lhs, rhs in
                let lhsValue = UnitConversion.convertWeightToKg(value(lhs.element), from: unit(lhs.element))
                let rhsValue = UnitConversion.convertWeightToKg(value(rhs.element), from: unit(rhs.element))
                if lhsValue == rhsValue {
                    return lhs.offset < rhs.offset
                }
                return lhsValue < rhsValue
            }
            .map { $0.element }
        return sortedItems.map(formatter).joined(separator: separator)
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
