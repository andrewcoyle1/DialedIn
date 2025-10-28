//
//  ExerciseTemplateModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import Foundation

struct ExerciseTemplateModel: @MainActor TemplateModel {
    var id: String {
        exerciseId
    }
    
    let exerciseId: String
    let authorId: String?
    let name: String
    let description: String?
    let instructions: [String]
    let type: ExerciseCategory
    let muscleGroups: [MuscleGroup]
    private(set) var imageURL: String?
    let isSystemExercise: Bool
    let dateCreated: Date
    let dateModified: Date
    let clickCount: Int?
    let bookmarkCount: Int?
    let favouriteCount: Int?
    
    init(
        exerciseId: String,
        authorId: String? = nil,
        name: String,
        description: String? = nil,
        instructions: [String] = [],
        type: ExerciseCategory = .none,
        muscleGroups: [MuscleGroup] = [],
        imageURL: String? = nil,
        isSystemExercise: Bool = false,
        dateCreated: Date,
        dateModified: Date,
        clickCount: Int? = nil,
        bookmarkCount: Int? = nil,
        favouriteCount: Int? = nil
    ) {
        self.exerciseId = exerciseId
        self.authorId = authorId
        self.name = name
        self.description = description
        self.instructions = instructions
        self.type = type
        self.muscleGroups = muscleGroups
        self.imageURL = imageURL
        self.isSystemExercise = isSystemExercise
        self.dateCreated = dateCreated
        self.dateModified = dateModified
        self.clickCount = clickCount
        self.bookmarkCount = bookmarkCount
        self.favouriteCount = favouriteCount
    }
    
    mutating func updateImageURL(imageUrl: String) {
        self.imageURL = imageUrl
    }
    
    enum CodingKeys: String, CodingKey {
        case exerciseId = "exercise_id"
        case authorId = "author_id"
        case name
        case description
        case instructions
        case type
        case muscleGroups = "muscle_groups"
        case imageURL = "image_url"
        case isSystemExercise = "is_system_exercise"
        case dateCreated = "date_created"
        case dateModified = "date_modified"
        case clickCount = "click_count"
        case bookmarkCount = "bookmark_count"
        case favouriteCount = "favourite_count"
    }

    // Make decoding tolerant for legacy documents missing some fields
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.exerciseId = try container.decodeIfPresent(String.self, forKey: .exerciseId) ?? UUID().uuidString
        self.authorId = try container.decodeIfPresent(String.self, forKey: .authorId)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.instructions = try container.decodeIfPresent([String].self, forKey: .instructions) ?? []
        self.type = try container.decodeIfPresent(ExerciseCategory.self, forKey: .type) ?? .none
        self.muscleGroups = try container.decodeIfPresent([MuscleGroup].self, forKey: .muscleGroups) ?? []
        self.imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        self.isSystemExercise = try container.decodeIfPresent(Bool.self, forKey: .isSystemExercise) ?? false
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated) ?? Date()
        self.dateModified = try container.decodeIfPresent(Date.self, forKey: .dateModified) ?? Date()
        self.clickCount = try container.decodeIfPresent(Int.self, forKey: .clickCount) ?? 0
        self.bookmarkCount = try container.decodeIfPresent(Int.self, forKey: .bookmarkCount) ?? 0
        self.favouriteCount = try container.decodeIfPresent(Int.self, forKey: .favouriteCount) ?? 0
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "user_\(CodingKeys.exerciseId.rawValue)": exerciseId,
            "user_\(CodingKeys.authorId.rawValue)": authorId,
            "user_\(CodingKeys.name.rawValue)": name,
            "user_\(CodingKeys.description.rawValue)": description,
            "user_\(CodingKeys.instructions.rawValue)": instructions,
            "user_\(CodingKeys.type.rawValue)": type,
            "user_\(CodingKeys.muscleGroups.rawValue)": muscleGroups,
            "user_\(CodingKeys.imageURL.rawValue)": imageURL,
            "user_\(CodingKeys.dateCreated.rawValue)": dateCreated,
            "user_\(CodingKeys.dateModified.rawValue)": dateModified,
            "user_\(CodingKeys.clickCount.rawValue)": clickCount,
            "user_\(CodingKeys.bookmarkCount.rawValue)": bookmarkCount,
            "user_\(CodingKeys.favouriteCount.rawValue)": favouriteCount
        ]
        return dict.compactMapValues({ $0 })
    }
    
    static func newExerciseTemplate(name: String, authorId: String, description: String? = nil, instructions: [String] = [], type: ExerciseCategory = .none, muscleGroups: [MuscleGroup] = []) -> Self {
        ExerciseTemplateModel(
            exerciseId: UUID().uuidString,
            authorId: authorId,
            name: name,
            description: description,
            instructions: instructions,
            type: type,
            muscleGroups: muscleGroups,
            imageURL: nil,
            dateCreated: .now,
            dateModified: .now,
            clickCount: 0,
            bookmarkCount: 0,
            favouriteCount: 0
        )
    }
    
    static var mock: ExerciseTemplateModel {
        mocks[0]
    }
    
    static var mocks: [ExerciseTemplateModel] {
        [
            ExerciseTemplateModel(
                exerciseId: "1",
                authorId: "1",
                name: "Bench Press",
                description: "Press a barbell up to shoulder height.",
                instructions: ["Lie on your back with a barbell on your chest.", "Push the barbell up to shoulder height.", "Lower the barbell back to your chest."],
                type: .barbell,
                muscleGroups: [.chest, .arms],
                imageURL: Constants.randomImage,
                dateCreated: Date(),
                dateModified: Date(),
                clickCount: 48,
                bookmarkCount: 3,
                favouriteCount: 2
            ),
            ExerciseTemplateModel(
                exerciseId: "2",
                authorId: "2",
                name: "Squat",
                description: "Lower your body by bending your knees and hips, then return to standing.",
                instructions: ["Stand with your feet shoulder-width apart.", "Bend your knees and hips, then return to standing."],
                type: .barbell,
                muscleGroups: [.legs, .core],
                imageURL: nil,
                dateCreated: Date(),
                dateModified: Date(),
                clickCount: 34,
                bookmarkCount: 2,
                favouriteCount: 1
            ),
            ExerciseTemplateModel(
                exerciseId: "3",
                authorId: "3",
                name: "Deadlift",
                description: "Lift a loaded barbell off the ground to hip level.",
                instructions: ["Stand with your feet shoulder-width apart.", "Bend your knees and hips, then return to standing."],
                type: .barbell,
                muscleGroups: [.back, .legs, .core],
                imageURL: Constants.randomImage,
                dateCreated: Date(),
                dateModified: Date(),
                clickCount: 23,
                bookmarkCount: 1,
                favouriteCount: 0
            ),
            ExerciseTemplateModel(
                exerciseId: "4",
                authorId: "4",
                name: "Pull-Up",
                description: "Pull your body up using a bar until your chin is above the bar.",
                instructions: ["Stand with your feet shoulder-width apart.", "Bend your knees and hips, then return to standing."],
                type: .weightedBodyweight,
                muscleGroups: [.back, .arms],
                imageURL: nil,
                dateCreated: Date(),
                dateModified: Date(),
                clickCount: 12,
                bookmarkCount: 7,
                favouriteCount: 0
            ),
            ExerciseTemplateModel(
                exerciseId: "5",
                authorId: "5",
                name: "Push-Up",
                description: "Lower and raise your body using your arms while keeping your body straight.",
                instructions: ["Stand with your feet shoulder-width apart.", "Bend your knees and hips, then return to standing."],
                type: .weightedBodyweight,
                muscleGroups: [.chest, .arms, .core],
                imageURL: Constants.randomImage,
                dateCreated: Date(),
                dateModified: Date(),
                clickCount: 10,
                bookmarkCount: 5,
                favouriteCount: 0
            ),
            ExerciseTemplateModel(
                exerciseId: "6",
                authorId: "6",
                name: "Dumbbell Curl",
                description: "Curl a dumbbell up towards your shoulder.",
                instructions: ["Stand with your feet shoulder-width apart.", "Bend your knees and hips, then return to standing."],
                type: .dumbbell,
                muscleGroups: [.arms],
                imageURL: nil,
                dateCreated: Date(),
                dateModified: Date(),
                clickCount: 8,
                bookmarkCount: 3,
                favouriteCount: 0
            ),
            ExerciseTemplateModel(
                exerciseId: "7",
                authorId: "7",
                name: "Tricep Rope Pushdown",
                description: "Push a cable rope down to work your triceps.",
                instructions: ["Stand with your feet shoulder-width apart.", "Bend your knees and hips, then return to standing."],
                type: .cable,
                muscleGroups: [.arms],
                imageURL: Constants.randomImage,
                dateCreated: Date(),
                dateModified: Date(),
                clickCount: 6,
                bookmarkCount: 2,
                favouriteCount: 0
            ),
            ExerciseTemplateModel(
                exerciseId: "8",
                authorId: "8",
                name: "Leg Press",
                description: "Push a weighted platform away with your legs.",
                instructions: ["Stand with your feet shoulder-width apart.", "Bend your knees and hips, then return to standing."],
                type: .machine,
                muscleGroups: [.legs],
                imageURL: nil,
                dateCreated: Date(),
                dateModified: Date(),
                clickCount: 4,
                bookmarkCount: 1,
                favouriteCount: 0
            ),
            ExerciseTemplateModel(
                exerciseId: "9",
                authorId: "9",
                name: "Plank",
                description: "Hold your body in a straight line, supported by your forearms and toes.",
                instructions: ["Stand with your feet shoulder-width apart.", "Bend your knees and hips, then return to standing."],
                type: .weightedBodyweight,
                muscleGroups: [.core],
                imageURL: Constants.randomImage,
                dateCreated: Date(),
                dateModified: Date(),
                clickCount: 2,
                bookmarkCount: 1,
                favouriteCount: 0
            ),
            ExerciseTemplateModel(
                exerciseId: "10",
                authorId: "10",
                name: "Treadmill Run",
                description: "Run at a steady pace on a treadmill.",
                instructions: ["Stand with your feet shoulder-width apart.", "Bend your knees and hips, then return to standing."],
                type: .cardio,
                muscleGroups: [.legs, .core],
                imageURL: nil,
                dateCreated: Date(),
                dateModified: Date(),
                clickCount: 0,
                bookmarkCount: 10,
                favouriteCount: 0
            )
        ]
    }
}

extension ExerciseTemplateModel: Sendable {}

extension ExerciseTemplateModel: Hashable {
    nonisolated static func == (lhs: ExerciseTemplateModel, rhs: ExerciseTemplateModel) -> Bool {
        lhs.exerciseId == rhs.exerciseId
    }
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(exerciseId)
    }
}

enum ExerciseCategory: String, Codable, CaseIterable, Sendable {
    case barbell
    case dumbbell
    case kettlebell
    case medicineBall
    case machine
    case cable
    case weightedBodyweight
    case assistedBodyweight
    case repsOnly
    case cardio
    case duration
    case none

    var description: String {
        switch self {
        case .barbell:
            return "Barbell"
        case .dumbbell:
            return "Dumbbell"
        case .kettlebell:
            return "Kettlebell"
        case .medicineBall:
            return "Medicine Ball"
        case .machine:
            return "Machine"
        case .cable:
            return "Cable"
        case .weightedBodyweight:
            return "Weighted Bodyweight"
        case .assistedBodyweight:
            return "Assisted Bodyweight"
        case .repsOnly:
            return "Reps Only"
        case .cardio:
            return "Cardio"
        case .duration:
            return "Duration"
        case .none:
            return "None"
        }
    }
}

enum MuscleGroup: String, Codable, CaseIterable, Sendable {
    case chest
    case shoulders
    case back
    case arms
    case legs
    case core
    case none

    var description: String {
        switch self {
        case .chest:
            return "Chest"
        case .shoulders:
            return "Shoulders"
        case .back:
            return "Back"
        case .arms:
            return "Arms"
        case .legs:
            return "Legs"
        case .core:
            return "Core"
        case .none:
            return "None"
        }
    }
}
