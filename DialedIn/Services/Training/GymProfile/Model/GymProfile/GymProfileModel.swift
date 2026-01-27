//
//  GymProfileModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/01/2026.
//

import SwiftUI

struct GymProfileModel: Identifiable, Codable {
    
    var id: String
    var authorId: String
    var name: String
    private(set) var imageUrl: String?
    var icon: String
    var dateCreated: Date
    var dateModified: Date
    var deletedAt: Date?
    
    var freeWeights: [FreeWeights] = FreeWeights.defaultFreeWeights
    var loadableBars: [LoadableBars] = LoadableBars.defaultLoadableBars
    var fixedWeightBars: [FixedWeightBars] = FixedWeightBars.defaultFixedWeightBars
    var bands: [Bands] = Bands.defaultBands
    var bodyWeights: [BodyWeights] = BodyWeights.defaultBodyWeights
    var supportEquipment: [SupportEquipment] = SupportEquipment.defaultSupportEquipment
    var accessoryEquipment: [AccessoryEquipment] = AccessoryEquipment.defaultAccessoryEquipment
    var loadableAccessoryEquipment: [LoadableAccessoryEquipment] = LoadableAccessoryEquipment.defaultLoadableAccessoryEquipment
    var cableMachines: [CableMachine] = CableMachine.defaultCableMachines
    var plateLoadedMachines: [PlateLoadedMachine] = PlateLoadedMachine.defaultPlateLoadedMachines
    var pinLoadedMachines: [PinLoadedMachine] = PinLoadedMachine.defaultPinLoadedMachines
    
    init(
        id: String = UUID().uuidString,
        authorId: String,
        name: String = "",
        imageUrl: String? = nil,
        icon: String = "dumbell",
        dateCreated: Date = Date.now,
        dateModified: Date = Date.now,
        deletedAt: Date? = nil,
        freeWeights: [FreeWeights] = FreeWeights.defaultFreeWeights,
        loadableBars: [LoadableBars] = LoadableBars.defaultLoadableBars,
        fixedWeightBars: [FixedWeightBars] = FixedWeightBars.defaultFixedWeightBars,
        bands: [Bands] = Bands.defaultBands,
        bodyWeights: [BodyWeights] = BodyWeights.defaultBodyWeights,
        supportEquipment: [SupportEquipment] = SupportEquipment.defaultSupportEquipment,
        accessoryEquipment: [AccessoryEquipment] = AccessoryEquipment.defaultAccessoryEquipment,
        loadableAccessoryEquipment: [LoadableAccessoryEquipment] = LoadableAccessoryEquipment.defaultLoadableAccessoryEquipment,
        cableMachines: [CableMachine] = CableMachine.defaultCableMachines,
        plateLoadedMachines: [PlateLoadedMachine] = PlateLoadedMachine.defaultPlateLoadedMachines,
        pinLoadedMachines: [PinLoadedMachine] = PinLoadedMachine.defaultPinLoadedMachines
    ) {
        self.id = id
        self.authorId = authorId
        self.name = name
        self.imageUrl = imageUrl
        self.icon = icon
        self.dateCreated = dateCreated
        self.dateModified = dateModified
        self.deletedAt = deletedAt
        self.freeWeights = freeWeights
        self.loadableBars = loadableBars
        self.fixedWeightBars = fixedWeightBars
        self.bands = bands
        self.bodyWeights = bodyWeights
        self.supportEquipment = supportEquipment
        self.accessoryEquipment = accessoryEquipment
        self.loadableAccessoryEquipment = loadableAccessoryEquipment
        self.cableMachines = cableMachines
        self.plateLoadedMachines = plateLoadedMachines
        self.pinLoadedMachines = pinLoadedMachines
    }
    
    mutating func updateImageUrl(imageUrl: String) {
        self.imageUrl = imageUrl
        self.dateModified = Date.now
    }

    enum CodingKeys: String, CodingKey {
        case id, name, icon
        case imageUrl = "image_url"
        case authorId = "author_id"
        case dateCreated = "date_created"
        case dateModified = "date_modified"
        case deletedAt = "deleted_at"
        case freeWeights = "free_weights"
        case loadableBars = "loadable_bars"
        case fixedWeightBars = "fixed_weight_bars"
        case bands
        case bodyWeights = "body_weights"
        case supportEquipment = "support_equipment"
        case accessoryEquipment = "accessory_equipment"
        case loadableAccessoryEquipment = "loadable_accessory_equipment"
        case cableMachines = "cable_machines"
        case plateLoadedMachines = "plate_loaded_machines"
        case pinLoadedMachines = "pin_loaded_machines"
    }
    
    static var mock: GymProfileModel {
        mocks[0]
    }
    
    static var mocks: [GymProfileModel] {
        [
            GymProfileModel(
                id: "1",
                authorId: "user123",
                name: "Platinum Gym Malahide",
                icon: "dumbbell",
                dateCreated: Date.now.addingTimeInterval(-86_400),
                dateModified: Date.now,
                deletedAt: nil,
                freeWeights: FreeWeights.mocks,
                loadableBars: LoadableBars.mocks,
                fixedWeightBars: FixedWeightBars.mocks,
                bands: Bands.mocks,
                bodyWeights: BodyWeights.mocks,
                supportEquipment: SupportEquipment.mocks,
                accessoryEquipment: AccessoryEquipment.mocks,
                loadableAccessoryEquipment: LoadableAccessoryEquipment.mocks,
                cableMachines: CableMachine.mocks,
                plateLoadedMachines: PlateLoadedMachine.mocks,
                pinLoadedMachines: PinLoadedMachine.mocks
            )
        ]
    }
}

extension GymProfileModel {
    var activeEquipmentCount: Int {
        freeWeights.filter(\.isActive).count
        + loadableBars.filter(\.isActive).count
        + fixedWeightBars.filter(\.isActive).count
        + bands.filter(\.isActive).count
        + bodyWeights.filter(\.isActive).count
        + supportEquipment.filter(\.isActive).count
        + accessoryEquipment.filter(\.isActive).count
        + loadableAccessoryEquipment.filter(\.isActive).count
        + cableMachines.filter(\.isActive).count
        + plateLoadedMachines.filter(\.isActive).count
        + pinLoadedMachines.filter(\.isActive).count
    }
}
