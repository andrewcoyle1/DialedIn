//
//  BodyMeasurementEntryEntity.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/02/2026.
//

import SwiftUI
import SwiftData

@Model
class BodyMeasurementEntryEntity {
    @Attribute(.unique) var id: String
    var authorId: String
    var weightKg: Double?
    var bodyFatPercentage: Double?
    var neckCircumference: Double?
    var shoulderCircumference: Double?
    var bustCircumference: Double?
    var chestCircumference: Double?
    var waistCircumference: Double?
    var hipCircumference: Double?
    var leftBicepCircumference: Double?
    var rightBicepCircumference: Double?
    var leftForearmCircumference: Double?
    var rightForearmCircumference: Double?
    var leftWristCircumference: Double?
    var rightWristCircumference: Double?
    var leftThighCircumference: Double?
    var rightThighCircumference: Double?
    var leftCalfCircumference: Double?
    var rightCalfCircumference: Double?
    var leftAnkleCircumference: Double?
    var rightAnkleCircumference: Double?
    var progressPhotoURLs: [String]?
    var date: Date
    var source: WeightSource
    var notes: String?
    var dateCreated: Date
    var deletedAt: Date?
    var healthKitUUID: UUID?

    init(from model: BodyMeasurementEntry) {
        self.id = model.id
        self.authorId = model.authorId
        self.weightKg = model.weightKg
        self.bodyFatPercentage = model.bodyFatPercentage
        self.neckCircumference = model.neckCircumference
        self.shoulderCircumference = model.shoulderCircumference
        self.bustCircumference = model.bustCircumference
        self.chestCircumference = model.chestCircumference
        self.waistCircumference = model.waistCircumference
        self.hipCircumference = model.hipCircumference
        self.leftBicepCircumference = model.leftBicepCircumference
        self.rightBicepCircumference = model.rightBicepCircumference
        self.leftForearmCircumference = model.leftForearmCircumference
        self.rightForearmCircumference = model.rightForearmCircumference
        self.leftWristCircumference = model.leftWristCircumference
        self.rightWristCircumference = model.rightWristCircumference
        self.leftThighCircumference = model.leftThighCircumference
        self.rightThighCircumference = model.rightThighCircumference
        self.leftCalfCircumference = model.leftCalfCircumference
        self.rightCalfCircumference = model.rightCalfCircumference
        self.leftAnkleCircumference = model.leftAnkleCircumference
        self.rightAnkleCircumference = model.rightAnkleCircumference
        self.progressPhotoURLs = model.progressPhotoURLs
        self.date = model.date
        self.source = model.source
        self.notes = model.notes
        self.dateCreated = model.dateCreated
        self.deletedAt = model.deletedAt
        self.healthKitUUID = model.healthKitUUID
    }

    @MainActor
    func toModel() -> BodyMeasurementEntry {
        BodyMeasurementEntry(
            id: id,
            authorId: authorId,
            weightKg: weightKg,
            bodyFatPercentage: bodyFatPercentage,
            neckCircumference: neckCircumference,
            shoulderCircumference: shoulderCircumference,
            bustCircumference: bustCircumference,
            chestCircumference: chestCircumference,
            waistCircumference: waistCircumference,
            hipCircumference: hipCircumference,
            leftBicepCircumference: leftBicepCircumference,
            rightBicepCircumference: rightBicepCircumference,
            leftForearmCircumference: leftForearmCircumference,
            rightForearmCircumference: rightForearmCircumference,
            leftWristCircumference: leftWristCircumference,
            rightWristCircumference: rightWristCircumference,
            leftThighCircumference: leftThighCircumference,
            rightThighCircumference: rightThighCircumference,
            leftCalfCircumference: leftCalfCircumference,
            rightCalfCircumference: rightCalfCircumference,
            leftAnkleCircumference: leftAnkleCircumference,
            rightAnkleCircumference: rightAnkleCircumference,
            progressPhotoURLs: progressPhotoURLs,
            date: date,
            source: source,
            notes: notes,
            dateCreated: dateCreated,
            deletedAt: deletedAt,
            healthKitUUID: healthKitUUID
        )
    }
}
