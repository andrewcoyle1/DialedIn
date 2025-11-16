//
//  TrainingProgramBuilder.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/31/25.
//

import Foundation

struct TrainingProgramBuilder: Sendable, Hashable {
    var experienceLevel: DifficultyLevel?
    var targetDaysPerWeek: Int?
    var splitType: TrainingSplitType?
    var weeklySchedule: Set<Int> // Set of weekday numbers (1=Sunday, 2=Monday, ..., 7=Saturday)
    var availableEquipment: Set<EquipmentType>
    var startDate: Date
    
    init(
        experienceLevel: DifficultyLevel? = nil,
        targetDaysPerWeek: Int? = nil,
        splitType: TrainingSplitType? = nil,
        weeklySchedule: Set<Int> = [],
        availableEquipment: Set<EquipmentType> = [],
        startDate: Date = .now
    ) {
        self.experienceLevel = experienceLevel
        self.targetDaysPerWeek = targetDaysPerWeek
        self.splitType = splitType
        self.weeklySchedule = weeklySchedule
        self.availableEquipment = availableEquipment
        self.startDate = startDate
    }
    
    var eventParameters: [String: Any] {
        [
            "experienceLevel": experienceLevel?.rawValue as Any,
            "targetDaysPerWeek": targetDaysPerWeek as Any,
            "splitType": splitType?.rawValue as Any,
            "weeklyScheduleCount": weeklySchedule.count as Any,
            "equipmentCount": availableEquipment.count as Any
        ]
    }
    
    var isValid: Bool {
        experienceLevel != nil &&
        targetDaysPerWeek != nil &&
        splitType != nil &&
        !weeklySchedule.isEmpty &&
        !availableEquipment.isEmpty
    }
    
    var programPreference: ProgramPreference {
        ProgramPreference(
            experienceLevel: experienceLevel ?? .beginner,
            targetDaysPerWeek: targetDaysPerWeek ?? 3,
            splitType: splitType ?? .fullBody,
            availableEquipment: availableEquipment
        )
    }
    
    mutating func setExperienceLevel(_ level: DifficultyLevel) {
        self.experienceLevel = level
    }
    
    mutating func setTargetDaysPerWeek(_ days: Int) {
        self.targetDaysPerWeek = days
    }
    
    mutating func setSplitType(_ split: TrainingSplitType) {
        self.splitType = split
    }
    
    mutating func setWeeklySchedule(_ schedule: Set<Int>) {
        self.weeklySchedule = schedule
    }
    
    mutating func setAvailableEquipment(_ equipment: Set<EquipmentType>) {
        self.availableEquipment = equipment
    }
}

struct ProgramPreference: Sendable {
    let experienceLevel: DifficultyLevel
    let targetDaysPerWeek: Int
    let splitType: TrainingSplitType
    let availableEquipment: Set<EquipmentType>
}

enum TrainingSplitType: String, CaseIterable, Identifiable, Sendable, Codable {
    case fullBody
    case upperLower
    case pushPullLegs
    case bodyPartSplit
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .fullBody:
            return "Full Body"
        case .upperLower:
            return "Upper/Lower"
        case .pushPullLegs:
            return "Push/Pull/Legs"
        case .bodyPartSplit:
            return "Body Part Split"
        }
    }
    
    var detailedDescription: String {
        switch self {
        case .fullBody:
            return "Train your entire body in each workout. Great for beginners and those training 3-4 days per week."
        case .upperLower:
            return "Alternate between upper body and lower body workouts. Ideal for 4-day training schedules."
        case .pushPullLegs:
            return "Focus on push muscles (chest, shoulders, triceps), pull muscles (back, biceps), and legs. Best for 6-day training schedules."
        case .bodyPartSplit:
            return "Dedicate each day to specific muscle groups. Requires 5-6 days per week."
        }
    }
    
    var typicalDaysPerWeek: Int {
        switch self {
        case .fullBody:
            return 3
        case .upperLower:
            return 4
        case .pushPullLegs:
            return 6
        case .bodyPartSplit:
            return 5
        }
    }
}

enum EquipmentType: String, CaseIterable, Identifiable, Sendable, Codable, Hashable {
    case barbell
    case dumbbell
    case kettlebell
    case machine
    case cable
    case bodyweight
    case resistanceBands
    case cardio
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .barbell:
            return "Barbell"
        case .dumbbell:
            return "Dumbbells"
        case .kettlebell:
            return "Kettlebells"
        case .machine:
            return "Machines"
        case .cable:
            return "Cable Machine"
        case .bodyweight:
            return "Bodyweight"
        case .resistanceBands:
            return "Resistance Bands"
        case .cardio:
            return "Cardio Equipment"
        }
    }
    
    var systemImage: String {
        switch self {
        case .barbell:
            return "dumbbell.fill"
        case .dumbbell:
            return "dumbbell.fill"
        case .kettlebell:
            return "figure.strengthtraining.traditional"
        case .machine:
            return "figure.strengthtraining.traditional"
        case .cable:
            return "cable.connector"
        case .bodyweight:
            return "figure.walk"
        case .resistanceBands:
            return "bandage.fill"
        case .cardio:
            return "figure.run"
        }
    }
}

