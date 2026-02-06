//
//  ExerciseEntity.swift
//  DialedIn
//
//  Created by Andrew Coyle on 30/01/2026.
//

import Foundation
import SwiftData

@Model
class ExerciseEntity {
    @Attribute(.unique) var exerciseId: String
    var authorId: String?
    var name: String
    var exerciseDescription: String?
    var imageURL: String?
    var trackableMetrics: Data
    var typeRaw: String?
    var lateralityRaw: String?
    var muscleGroups: Data
    var isBodyweight: Bool
    var resistanceEquipment: Data
    var supportEquipment: Data
    var rangeOfMotion: Int
    var stability: Int
    var bodyWeightContribution: Int
    var alternateNames: Data
    var isSystemExercise: Bool
    var dateCreated: Date
    var dateModified: Date
    var clickCount: Int?
    var bookmarkCount: Int?
    var favouriteCount: Int?

    init(from model: ExerciseModel) {
        self.exerciseId = model.id
        self.authorId = model.authorId
        self.name = model.name
        self.exerciseDescription = model.description
        self.imageURL = model.imageURL
        self.trackableMetrics = Self.encode(model.trackableMetrics)
        self.typeRaw = model.type?.rawValue
        self.lateralityRaw = model.laterality?.rawValue
        self.muscleGroups = Self.encode(model.muscleGroups)
        self.isBodyweight = model.isBodyweight
        self.resistanceEquipment = Self.encode(model.resistanceEquipment)
        self.supportEquipment = Self.encode(model.supportEquipment)
        self.rangeOfMotion = model.rangeOfMotion
        self.stability = model.stability
        self.bodyWeightContribution = model.bodyWeightContribution
        self.alternateNames = Self.encode(model.alternateNames)
        self.isSystemExercise = model.isSystemExercise
        self.dateCreated = model.dateCreated
        self.dateModified = model.dateModified
        self.clickCount = model.clickCount
        self.bookmarkCount = model.bookmarkCount
        self.favouriteCount = model.favouriteCount
    }

    @MainActor
    func toModel() -> ExerciseModel {
        ExerciseModel(
            id: exerciseId,
            authorId: authorId ?? "",
            name: name,
            description: exerciseDescription,
            imageURL: imageURL,
            trackableMetrics: Self.decode(trackableMetrics, fallback: [TrackableExerciseMetric]()),
            type: typeRaw.flatMap { ExerciseType(rawValue: $0) },
            laterality: lateralityRaw.flatMap { Laterality(rawValue: $0) },
            muscleGroups: Self.decode(muscleGroups, fallback: [Muscles: Bool]()),
            isBodyweight: isBodyweight,
            resistanceEquipment: Self.decode(resistanceEquipment, fallback: [EquipmentRef]()),
            supportEquipment: Self.decode(supportEquipment, fallback: [EquipmentRef]()),
            rangeOfMotion: rangeOfMotion,
            stability: stability,
            bodyWeightContribution: bodyWeightContribution,
            alternateNames: Self.decode(alternateNames, fallback: [String]()),
            isSystemExercise: isSystemExercise,
            dateCreated: dateCreated,
            dateModified: dateModified,
            clickCount: clickCount,
            bookmarkCount: bookmarkCount,
            favouriteCount: favouriteCount
        )
    }

    private static func encode<T: Encodable>(_ value: T) -> Data {
        (try? JSONEncoder().encode(value)) ?? Data()
    }

    private static func decode<T: Decodable>(_ data: Data, fallback: T) -> T {
        (try? JSONDecoder().decode(T.self, from: data)) ?? fallback
    }
}
