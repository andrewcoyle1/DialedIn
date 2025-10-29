//
//  TemplatePickerConfiguration.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/10/2025.
//

import Foundation

/// Configuration for template picker display and behavior
struct TemplatePickerConfiguration<Template: TemplateModel> {
    let title: String
    let userSectionTitle: String
    let officialSectionTitle: String
    let emptyStateMessage: String
    let extractAuthorId: (Template) -> String?
    
    init(
        title: String,
        userSectionTitle: String,
        officialSectionTitle: String,
        emptyStateMessage: String,
        extractAuthorId: @escaping (Template) -> String?
    ) {
        self.title = title
        self.userSectionTitle = userSectionTitle
        self.officialSectionTitle = officialSectionTitle
        self.emptyStateMessage = emptyStateMessage
        self.extractAuthorId = extractAuthorId
    }
}

// MARK: - Predefined Configurations

extension TemplatePickerConfiguration where Template == WorkoutTemplateModel {
    static var workout: TemplatePickerConfiguration<WorkoutTemplateModel> {
        TemplatePickerConfiguration(
            title: "Select Workout",
            userSectionTitle: "Your Workouts",
            officialSectionTitle: "Official Workouts",
            emptyStateMessage: "No workouts found",
            extractAuthorId: { $0.authorId }
        )
    }
}

extension TemplatePickerConfiguration where Template == ExerciseTemplateModel {
    static var exercise: TemplatePickerConfiguration<ExerciseTemplateModel> {
        TemplatePickerConfiguration(
            title: "Select Exercise",
            userSectionTitle: "Your Exercises",
            officialSectionTitle: "Official Exercises",
            emptyStateMessage: "No exercises found",
            extractAuthorId: { $0.authorId }
        )
    }
}

extension TemplatePickerConfiguration where Template == IngredientTemplateModel {
    static var ingredient: TemplatePickerConfiguration<IngredientTemplateModel> {
        TemplatePickerConfiguration(
            title: "Select Ingredient",
            userSectionTitle: "Your Ingredients",
            officialSectionTitle: "Official Ingredients",
            emptyStateMessage: "No ingredients found",
            extractAuthorId: { $0.authorId }
        )
    }
}

extension TemplatePickerConfiguration where Template == RecipeTemplateModel {
    static var recipe: TemplatePickerConfiguration<RecipeTemplateModel> {
        TemplatePickerConfiguration(
            title: "Select Recipe",
            userSectionTitle: "Your Recipes",
            officialSectionTitle: "Official Recipes",
            emptyStateMessage: "No recipes found",
            extractAuthorId: { $0.authorId }
        )
    }
}
