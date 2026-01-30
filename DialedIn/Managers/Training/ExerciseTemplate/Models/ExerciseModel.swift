//
//  ExerciseModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/01/2026.
//

import Foundation

struct ExerciseModel: Identifiable, Codable {
    var id: String
    var authorId: String
    var name: String
    var imageUrl: String?
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
    var description: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case authorId = "author_id"
        case name
        case imageUrl = "image_url"
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
        case description
    }

    init(
        id: String = UUID().uuidString,
        authorId: String,
        name: String,
        imageUrl: String? = nil,
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
        description: String
    ) {
        self.id = id
        self.authorId = authorId
        self.name = name
        self.imageUrl = imageUrl
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
        self.description = description
    }

    init(from delegate: ExerciseSaveDelegate, authorId: String) {
        self.id = UUID().uuidString
        self.authorId = authorId
        self.name = delegate.exerciseName
        self.imageUrl = nil
        self.trackableMetrics = [delegate.trackableMetricA, delegate.trackableMetricB].compactMap { $0 }
        self.type = delegate.type
        self.laterality = delegate.laterality
        self.muscleGroups = delegate.targetMuscles
        self.isBodyweight = delegate.isBodyweight
        self.resistanceEquipment = delegate.resistanceEquipment
        self.supportEquipment = delegate.supportEquipment
        self.rangeOfMotion = delegate.rangeOfMotion
        self.stability = delegate.stability
        self.bodyWeightContribution = delegate.bodyweightContribution
        self.alternateNames = delegate.alternativeNames
        self.description = delegate.exerciseDescription
    }

    static var mock: ExerciseModel {
        mocks[0]
    }

    static var mocks: [ExerciseModel] {
        [
            ExerciseModel(
                authorId: "user123",
                name: "Bench Press",
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
                alternateNames: ["Barbell Bench Press", "Flat Bench Press", "Flat Barbell Bench Press"],
                description: "A classic compound lift focusing on the pectorals, triceps, and front deltoids."
            ),
            ExerciseModel(
                authorId: "user234",
                name: "Pull Up",
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
                alternateNames: ["Chin Up", "Wide Grip Pull Up"],
                description: "A bodyweight exercise targeting the upper back, biceps, and shoulders."
            ),
            ExerciseModel(
                authorId: "user345",
                name: "Squat",
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
                alternateNames: ["Barbell Back Squat", "Back Squat"],
                description: "A foundational lower body strength exercise working the quads, glutes, and hamstrings."
            ),
            ExerciseModel(
                authorId: "user456",
                name: "Deadlift",
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
                alternateNames: ["Conventional Deadlift"],
                description: "A compound lift for building powerful hips, back, and hamstrings."
            ),
            ExerciseModel(
                authorId: "user567",
                name: "Plank",
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
                alternateNames: [],
                description: "An isometric core stability exercise emphasizing abdominal endurance."
            ),
            ExerciseModel(
                authorId: "user678",
                name: "Overhead Press",
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
                alternateNames: ["Shoulder Press", "Military Press"],
                description: "A vertical pressing movement to develop shoulder and tricep strength."
            ),
            ExerciseModel(
                authorId: "user789",
                name: "Bulgarian Split Squat",
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
                alternateNames: ["Rear Foot Elevated Split Squat"],
                description: "A single-leg lower body movement for quads and glutes, performed with the back foot elevated."
            ),
            ExerciseModel(
                authorId: "user890",
                name: "Push Up",
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
                alternateNames: ["Press Up"],
                description: "A bodyweight pressing movement targeting the chest, triceps, and shoulders."
            ),
            ExerciseModel(
                authorId: "user901",
                name: "Lat Pulldown",
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
                alternateNames: ["Pulldown"],
                description: "A machine exercise designed to build the latissimus dorsi and biceps."
            ),
            ExerciseModel(
                authorId: "user012",
                name: "Calf Raise",
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
                alternateNames: ["Standing Calf Raise", "Heel Raise"],
                description: "Exercise to develop lower leg strength and endurance, focusing on calves."
            )
        ]
    }
}
