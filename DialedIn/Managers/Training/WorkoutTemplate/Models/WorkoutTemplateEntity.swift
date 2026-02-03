//
//  WorkoutTemplateEntity.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import Foundation
import SwiftUI
import SwiftData

@Model
class WorkoutTemplateEntity {
    @Attribute(.unique) var workoutTemplateId: String
    var authorId: String?
    var name: String
    var workoutDescription: String?
    var imageURL: String?
    var isSystemWorkout: Bool
    var dateCreated: Date
    var dateModified: Date
    var exercises: [String]
    var exercisesData: Data?
    var clickCount: Int?
    var bookmarkCount: Int?
    var favouriteCount: Int?
    
    init(from model: WorkoutTemplateModel) {
        self.workoutTemplateId = model.workoutId
        self.authorId = model.authorId
        self.name = model.name
        self.workoutDescription = model.description
        self.imageURL = model.imageURL
        self.isSystemWorkout = model.isSystemWorkout
        self.dateCreated = model.dateCreated
        self.dateModified = model.dateModified
        self.exercises = model.exercises.map(\.exercise.id)
        self.exercisesData = try? JSONEncoder().encode(model.exercises)
        self.clickCount = model.clickCount
        self.bookmarkCount = model.bookmarkCount
        self.favouriteCount = model.favouriteCount
    }
    
    @MainActor
    func toModel(exerciseManager: ExerciseTemplateManager? = nil) -> WorkoutTemplateModel {
        // Fetch actual exercises if manager is provided
        var exerciseTemplates: [WorkoutTemplateExercise] = []
        if let exercisesData,
           let decoded = try? JSONDecoder().decode([WorkoutTemplateExercise].self, from: exercisesData) {
            exerciseTemplates = decoded
        } else if let exerciseManager = exerciseManager {
            for exerciseId in exercises {
                if let exercise = try? exerciseManager.getLocalExerciseTemplate(id: exerciseId) {
                    let workoutExercise = WorkoutTemplateExercise(exercise: exercise, setRestTimers: false)
                    exerciseTemplates.append(workoutExercise)
                }
            }
        }
        
        return WorkoutTemplateModel(
            id: workoutTemplateId,
            authorId: authorId ?? "",
            name: name,
            description: workoutDescription,
            imageURL: imageURL,
            isSystemWorkout: isSystemWorkout,
            dateCreated: dateCreated,
            dateModified: dateModified,
            exercises: exerciseTemplates,
            clickCount: clickCount,
            bookmarkCount: bookmarkCount,
            favouriteCount: favouriteCount
        )
    }
}
