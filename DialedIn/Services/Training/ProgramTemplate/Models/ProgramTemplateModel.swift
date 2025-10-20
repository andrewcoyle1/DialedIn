//
//  ProgramTemplateModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import Foundation

struct ProgramTemplateModel: Sendable, Codable, Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let description: String
    let duration: Int // weeks
    let difficulty: DifficultyLevel
    let focusAreas: [FocusArea]
    let weekTemplates: [WeekTemplate]
    let isPublic: Bool
    let authorId: String?
    let createdAt: Date
    let modifiedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case duration
        case difficulty
        case focusAreas = "focus_areas"
        case weekTemplates = "week_templates"
        case isPublic = "is_public"
        case authorId = "author_id"
        case createdAt = "created_at"
        case modifiedAt = "modified_at"
    }
    
    init(
        id: String,
        name: String,
        description: String,
        duration: Int,
        difficulty: DifficultyLevel,
        focusAreas: [FocusArea],
        weekTemplates: [WeekTemplate],
        isPublic: Bool = false,
        authorId: String? = nil,
        createdAt: Date = .now,
        modifiedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.duration = duration
        self.difficulty = difficulty
        self.focusAreas = focusAreas
        self.weekTemplates = weekTemplates
        self.isPublic = isPublic
        self.authorId = authorId
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
    
    struct TemplateConfig {
        let name: String
        let description: String
        let duration: Int
        let difficulty: DifficultyLevel
        var focusAreas: [FocusArea] = []
        var authorId: String?
    }
    
    static func newTemplate(config: TemplateConfig) -> ProgramTemplateModel {
        ProgramTemplateModel(
            id: UUID().uuidString,
            name: config.name,
            description: config.description,
            duration: config.duration,
            difficulty: config.difficulty,
            focusAreas: config.focusAreas,
            weekTemplates: [],
            isPublic: false,
            authorId: config.authorId
        )
    }
    
    // Built-in templates
    static var pushPullLegs: ProgramTemplateModel {
        ProgramTemplateModel(
            id: "template-ppl",
            name: "Push/Pull/Legs",
            description: "Classic 6-day split focusing on push muscles, pull muscles, and legs",
            duration: 8,
            difficulty: .intermediate,
            focusAreas: [.strength, .hypertrophy],
            weekTemplates: WeekTemplate.pushPullLegsWeeks,
            isPublic: true,
            authorId: nil
        )
    }
    
    static var fullBodyBeginner: ProgramTemplateModel {
        ProgramTemplateModel(
            id: "template-full-body",
            name: "Full Body Beginner",
            description: "3-day full body program for beginners",
            duration: 6,
            difficulty: .beginner,
            focusAreas: [.strength, .technique],
            weekTemplates: WeekTemplate.fullBodyWeeks,
            isPublic: true,
            authorId: nil
        )
    }
    
    static var upperLowerSplit: ProgramTemplateModel {
        ProgramTemplateModel(
            id: "template-upper-lower",
            name: "Upper/Lower Split",
            description: "4-day split alternating upper and lower body",
            duration: 8,
            difficulty: .intermediate,
            focusAreas: [.strength, .hypertrophy],
            weekTemplates: WeekTemplate.upperLowerWeeks,
            isPublic: true,
            authorId: nil
        )
    }
    
    static var builtInTemplates: [ProgramTemplateModel] {
        [pushPullLegs, fullBodyBeginner, upperLowerSplit]
    }
    
    static var mock: ProgramTemplateModel {
        pushPullLegs
    }
}

struct WeekTemplate: Sendable, Codable, Equatable, Identifiable, Hashable {
    var id: Int { weekNumber }
    
    let weekNumber: Int
    let workoutSchedule: [DayWorkoutMapping]
    let notes: String?
    let isDeloadWeek: Bool
    
    enum CodingKeys: String, CodingKey {
        case weekNumber = "week_number"
        case workoutSchedule = "workout_schedule"
        case notes
        case isDeloadWeek = "is_deload_week"
    }
    
    init(
        weekNumber: Int,
        workoutSchedule: [DayWorkoutMapping],
        notes: String? = nil,
        isDeloadWeek: Bool = false
    ) {
        self.weekNumber = weekNumber
        self.workoutSchedule = workoutSchedule
        self.notes = notes
        self.isDeloadWeek = isDeloadWeek
    }
    
    // Push/Pull/Legs template (6 workouts per week)
    static var pushPullLegsWeeks: [WeekTemplate] {
        let schedule = [
            DayWorkoutMapping(dayOfWeek: 2, workoutTemplateId: "workout-push-1", workoutName: "Push Day 1"),
            DayWorkoutMapping(dayOfWeek: 3, workoutTemplateId: "workout-pull-1", workoutName: "Pull Day 1"),
            DayWorkoutMapping(dayOfWeek: 4, workoutTemplateId: "workout-legs-1", workoutName: "Leg Day 1"),
            DayWorkoutMapping(dayOfWeek: 5, workoutTemplateId: "workout-push-2", workoutName: "Push Day 2"),
            DayWorkoutMapping(dayOfWeek: 6, workoutTemplateId: "workout-pull-2", workoutName: "Pull Day 2"),
            DayWorkoutMapping(dayOfWeek: 7, workoutTemplateId: "workout-legs-2", workoutName: "Leg Day 2")
        ]
        
        return (1...8).map { weekNum in
            WeekTemplate(
                weekNumber: weekNum,
                workoutSchedule: schedule,
                notes: weekNum == 4 || weekNum == 8 ? "Deload week" : nil,
                isDeloadWeek: weekNum == 4 || weekNum == 8
            )
        }
    }
    
    // Full Body template (3 workouts per week)
    static var fullBodyWeeks: [WeekTemplate] {
        let schedule = [
            DayWorkoutMapping(dayOfWeek: 2, workoutTemplateId: "workout-full-body-1", workoutName: "Full Body A"),
            DayWorkoutMapping(dayOfWeek: 4, workoutTemplateId: "workout-full-body-2", workoutName: "Full Body B"),
            DayWorkoutMapping(dayOfWeek: 6, workoutTemplateId: "workout-full-body-3", workoutName: "Full Body C")
        ]
        
        return (1...6).map { weekNum in
            WeekTemplate(
                weekNumber: weekNum,
                workoutSchedule: schedule,
                notes: weekNum == 6 ? "Test week" : nil
            )
        }
    }
    
    // Upper/Lower template (4 workouts per week)
    static var upperLowerWeeks: [WeekTemplate] {
        let schedule = [
            DayWorkoutMapping(dayOfWeek: 2, workoutTemplateId: "workout-upper-1", workoutName: "Upper Body A"),
            DayWorkoutMapping(dayOfWeek: 3, workoutTemplateId: "workout-lower-1", workoutName: "Lower Body A"),
            DayWorkoutMapping(dayOfWeek: 5, workoutTemplateId: "workout-upper-2", workoutName: "Upper Body B"),
            DayWorkoutMapping(dayOfWeek: 6, workoutTemplateId: "workout-lower-2", workoutName: "Lower Body B")
        ]
        
        return (1...8).map { weekNum in
            WeekTemplate(
                weekNumber: weekNum,
                workoutSchedule: schedule,
                notes: weekNum == 4 || weekNum == 8 ? "Deload week" : nil,
                isDeloadWeek: weekNum == 4 || weekNum == 8
            )
        }
    }
}

struct DayWorkoutMapping: Sendable, Codable, Equatable, Identifiable, Hashable {
    var id: String { "\(dayOfWeek)-\(workoutTemplateId)" }
    
    let dayOfWeek: Int // 1 = Sunday, 2 = Monday, ..., 7 = Saturday
    let workoutTemplateId: String
    let workoutName: String?
    
    enum CodingKeys: String, CodingKey {
        case dayOfWeek = "day_of_week"
        case workoutTemplateId = "workout_template_id"
        case workoutName = "workout_name"
    }
    
    init(dayOfWeek: Int, workoutTemplateId: String, workoutName: String? = nil) {
        self.dayOfWeek = dayOfWeek
        self.workoutTemplateId = workoutTemplateId
        self.workoutName = workoutName
    }
}

enum DifficultyLevel: String, Codable, CaseIterable, Sendable {
    case beginner
    case intermediate
    case advanced
    
    var description: String {
        switch self {
        case .beginner:
            return "Beginner"
        case .intermediate:
            return "Intermediate"
        case .advanced:
            return "Advanced"
        }
    }
    
    var systemImage: String {
        switch self {
        case .beginner:
            return "1.circle.fill"
        case .intermediate:
            return "2.circle.fill"
        case .advanced:
            return "3.circle.fill"
        }
    }
}

enum FocusArea: String, Codable, CaseIterable, Sendable {
    case strength
    case hypertrophy
    case endurance
    case technique
    case powerlifting
    case bodybuilding
    case athleticism
    case generalFitness
    
    var description: String {
        switch self {
        case .strength:
            return "Strength"
        case .hypertrophy:
            return "Hypertrophy"
        case .endurance:
            return "Endurance"
        case .technique:
            return "Technique"
        case .powerlifting:
            return "Powerlifting"
        case .bodybuilding:
            return "Bodybuilding"
        case .athleticism:
            return "Athleticism"
        case .generalFitness:
            return "General Fitness"
        }
    }
    
    var systemImage: String {
        switch self {
        case .strength:
            return "bolt.fill"
        case .hypertrophy:
            return "figure.strengthtraining.traditional"
        case .endurance:
            return "figure.run"
        case .technique:
            return "hand.raised.fill"
        case .powerlifting:
            return "dumbbell.fill"
        case .bodybuilding:
            return "figure.arms.open"
        case .athleticism:
            return "sportscourt.fill"
        case .generalFitness:
            return "heart.fill"
        }
    }
}
