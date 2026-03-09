//
//  ExerciseModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/01/2026.
//

import Foundation

struct ExerciseModel: DataSyncModelProtocol, SearchListItem, Hashable {
    var id: String
    var authorId: String
    var name: String
    var description: String?
    var imageURL: String?
    var trackableMetrics: [TrackableExerciseMetric]
    var type: ExerciseType?
    var laterality: Laterality?
    var muscleGroups: [Muscles: Bool]
    var isBodyweight: Bool
    var resistanceEquipment: [EquipmentRef]
    var supportEquipment: [EquipmentRef]
    var rangeOfMotion: Int
    var stability: Int
    var bodyWeightContribution: Int
    var alternateNames: [String]
    var isSystemExercise: Bool
    var dateCreated: Date
    var dateModified: Date
    var clickCount: Int?
    var bookmarkCount: Int?
    var favouriteCount: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case authorId = "author_id"
        case name
        case description
        case imageURL = "image_url"
        case trackableMetrics = "trackable_metrics"
        case type
        case laterality
        case muscleGroups = "muscle_groups"
        case isBodyweight = "is_bodyweight"
        case resistanceEquipment = "resistance_equipment"
        case supportEquipment = "support_equipment"
        case rangeOfMotion = "range_of_motion"
        case stability = "stability"
        case bodyWeightContribution = "body_weight_contribution"
        case alternateNames = "alternate_names"
        case isSystemExercise = "is_system_exercise"
        case dateCreated = "date_created"
        case dateModified = "date_modified"
        case clickCount = "click_count"
        case bookmarkCount = "bookmark_count"
        case favouriteCount = "favourite_count"
    }

    init(
        id: String = UUID().uuidString,
        authorId: String,
        name: String,
        description: String? = nil,
        imageURL: String? = nil,
        trackableMetrics: [TrackableExerciseMetric],
        type: ExerciseType?,
        laterality: Laterality?,
        muscleGroups: [Muscles: Bool],
        isBodyweight: Bool,
        resistanceEquipment: [EquipmentRef],
        supportEquipment: [EquipmentRef],
        rangeOfMotion: Int,
        stability: Int,
        bodyWeightContribution: Int,
        alternateNames: [String],
        isSystemExercise: Bool = false,
        dateCreated: Date = .now,
        dateModified: Date = .now,
        clickCount: Int? = 0,
        bookmarkCount: Int? = 0,
        favouriteCount: Int? = 0
    ) {
        self.id = id
        self.authorId = authorId
        self.name = name
        self.description = description
        self.imageURL = imageURL
        self.trackableMetrics = trackableMetrics
        self.type = type
        self.laterality = laterality
        self.muscleGroups = muscleGroups
        self.isBodyweight = isBodyweight
        self.resistanceEquipment = resistanceEquipment
        self.supportEquipment = supportEquipment
        self.rangeOfMotion = rangeOfMotion
        self.stability = stability
        self.bodyWeightContribution = bodyWeightContribution
        self.alternateNames = alternateNames
        self.isSystemExercise = isSystemExercise
        self.dateCreated = dateCreated
        self.dateModified = dateModified
        self.clickCount = clickCount
        self.bookmarkCount = bookmarkCount
        self.favouriteCount = favouriteCount
    }

    mutating func updateImageURL(imageUrl: String) {
        imageURL = imageUrl
    }

    static var mock: ExerciseModel {
        mocks[0]
    }

    static var mocks: [ExerciseModel] {
        [
            ExerciseModel(
                authorId: "user123",
                name: "Bench Press",
                description: "A classic compound lift focusing on the pectorals, triceps, and front deltoids.",
                trackableMetrics: [.reps, .weight],
                type: .compoundUpper,
                laterality: .bilateral,
                muscleGroups: [
                    .chest: false,
                    .triceps: true,
                    .frontDelts: true
                ],
                isBodyweight: false,
                resistanceEquipment: [
                    EquipmentRef(kind: .loadableBar, id: "barbell")
                ],
                supportEquipment: [
                    EquipmentRef(kind: .supportEquipment, id: "flat_bench")
                ],
                rangeOfMotion: 4,
                stability: 5,
                bodyWeightContribution: 10,
                alternateNames: ["Barbell Bench Press", "Flat Bench Press", "Flat Barbell Bench Press"]
            ),
            ExerciseModel(
                authorId: "user234",
                name: "Pull Up",
                description: "A bodyweight exercise targeting the upper back, biceps, and shoulders.",
                trackableMetrics: [.reps],
                type: .compoundUpper,
                laterality: .bilateral,
                muscleGroups: [
                    .forearms: true,
                    .biceps: true,
                    .lats: false
                ],
                isBodyweight: true,
                resistanceEquipment: [],
                supportEquipment: [
                    EquipmentRef(kind: .accessoryEquipment, id: "pull_up_bar")
                ],
                rangeOfMotion: 5,
                stability: 4,
                bodyWeightContribution: 100,
                alternateNames: ["Chin Up", "Wide Grip Pull Up"]
            ),
            ExerciseModel(
                authorId: "user345",
                name: "Squat",
                description: "A foundational lower body strength exercise working the quads, glutes, and hamstrings.",
                trackableMetrics: [.reps, .weight],
                type: .compoundLower,
                laterality: .bilateral,
                muscleGroups: [
                    .quads: false,
                    .glutes: false,
                    .hamstrings: false
                ],
                isBodyweight: false,
                resistanceEquipment: [
                    EquipmentRef(kind: .loadableBar, id: "barbell")
                ],
                supportEquipment: [
                    EquipmentRef(kind: .supportEquipment, id: "power_rack")
                ],
                rangeOfMotion: 5,
                stability: 3,
                bodyWeightContribution: 0,
                alternateNames: ["Barbell Back Squat", "Back Squat"]
            ),
            ExerciseModel(
                authorId: "user456",
                name: "Deadlift",
                description: "A compound lift for building powerful hips, back, and hamstrings.",
                trackableMetrics: [.reps, .weight],
                type: .compoundLower,
                laterality: .bilateral,
                muscleGroups: [
                    .hamstrings: false,
                    .glutes: true,
                    .upperTraps: true,
                    .lowerBack: false
                ],
                isBodyweight: false,
                resistanceEquipment: [
                    EquipmentRef(kind: .loadableBar, id: "barbell")
                ],
                supportEquipment: [],
                rangeOfMotion: 4,
                stability: 4,
                bodyWeightContribution: 0,
                alternateNames: ["Conventional Deadlift"]
            ),
            ExerciseModel(
                authorId: "user567",
                name: "Plank",
                description: "An isometric core stability exercise emphasizing abdominal endurance.",
                trackableMetrics: [.duration],
                type: .core,
                laterality: .bilateral,
                muscleGroups: [
                    .abs: false,
                    .frontDelts: true
                ],
                isBodyweight: true,
                resistanceEquipment: [],
                supportEquipment: [],
                rangeOfMotion: 1,
                stability: 5,
                bodyWeightContribution: 100,
                alternateNames: []
            ),
            ExerciseModel(
                authorId: "user678",
                name: "Overhead Press",
                description: "A vertical pressing movement to develop shoulder and tricep strength.",
                trackableMetrics: [.reps, .weight],
                type: .compoundUpper,
                laterality: .bilateral,
                muscleGroups: [
                    .upperTraps: false,
                    .triceps: true,
                    .chest: true
                ],
                isBodyweight: false,
                resistanceEquipment: [
                    EquipmentRef(kind: .loadableBar, id: "barbell")
                ],
                supportEquipment: [],
                rangeOfMotion: 3,
                stability: 3,
                bodyWeightContribution: 0,
                alternateNames: ["Shoulder Press", "Military Press"]
            ),
            ExerciseModel(
                authorId: "user789",
                name: "Bulgarian Split Squat",
                description: "A single-leg lower body movement for quads and glutes, performed with the back foot elevated.",
                trackableMetrics: [.reps, .weight],
                type: .compoundLower,
                laterality: .unilateral,
                muscleGroups: [
                    .quads: true,
                    .glutes: true,
                    .hamstrings: false
                ],
                isBodyweight: false,
                resistanceEquipment: [
                    EquipmentRef(kind: .freeWeight, id: "dumbbells")
                ],
                supportEquipment: [
                    EquipmentRef(kind: .supportEquipment, id: "flat_bench")
                ],
                rangeOfMotion: 4,
                stability: 2,
                bodyWeightContribution: 0,
                alternateNames: ["Rear Foot Elevated Split Squat"]
            ),
            ExerciseModel(
                authorId: "user890",
                name: "Push Up",
                description: "A bodyweight pressing movement targeting the chest, triceps, and shoulders.",
                trackableMetrics: [.reps],
                type: .compoundUpper,
                laterality: .bilateral,
                muscleGroups: [
                    .chest: true,
                    .triceps: true,
                    .frontDelts: false
                ],
                isBodyweight: true,
                resistanceEquipment: [],
                supportEquipment: [],
                rangeOfMotion: 4,
                stability: 3,
                bodyWeightContribution: 100,
                alternateNames: ["Press Up"]
            ),
            ExerciseModel(
                authorId: "user901",
                name: "Lat Pulldown",
                description: "A machine exercise designed to build the latissimus dorsi and biceps.",
                trackableMetrics: [.reps, .weight],
                type: .compoundUpper,
                laterality: .bilateral,
                muscleGroups: [
                    .lats: false,
                    .biceps: true
                ],
                isBodyweight: false,
                resistanceEquipment: [
                    EquipmentRef(kind: .cableMachine, id: "cable_lat_pulldown_machine")
                ],
                supportEquipment: [],
                rangeOfMotion: 5,
                stability: 4,
                bodyWeightContribution: 0,
                alternateNames: ["Pulldown"]
            ),
            ExerciseModel(
                authorId: "user012",
                name: "Calf Raise",
                description: "Exercise to develop lower leg strength and endurance, focusing on calves.",
                trackableMetrics: [.reps, .weight],
                type: .isolationLower,
                laterality: .bilateral,
                muscleGroups: [
                    .calves: true
                ],
                isBodyweight: true,
                resistanceEquipment: [],
                supportEquipment: [
                    EquipmentRef(kind: .accessoryEquipment, id: "calf_raise_block")
                ],
                rangeOfMotion: 3,
                stability: 4,
                bodyWeightContribution: 100,
                alternateNames: ["Standing Calf Raise", "Heel Raise"]
            )
        ]
    }
}

extension ExerciseModel: Sendable {}
