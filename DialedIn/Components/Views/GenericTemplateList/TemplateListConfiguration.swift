//
//  TemplateListConfiguration.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

/// Configuration for template list display and behavior
struct TemplateListConfiguration<Template: TemplateModel> {
    let title: String
    let emptyStateTitle: String
    let emptyStateIcon: String
    let emptyStateDescription: String
    let errorTitle: String
    let errorSubtitle: String
    let navigationDestination: (Template) -> Void

    init(
        title: String,
        emptyStateTitle: String,
        emptyStateIcon: String,
        emptyStateDescription: String,
        errorTitle: String = "Unable to Load",
        errorSubtitle: String = "Please check your internet connection and try again.",
        navigationDestination: @escaping (Template) -> Void
    ) {
        self.title = title
        self.emptyStateTitle = emptyStateTitle
        self.emptyStateIcon = emptyStateIcon
        self.emptyStateDescription = emptyStateDescription
        self.errorTitle = errorTitle
        self.errorSubtitle = errorSubtitle
        self.navigationDestination = navigationDestination
    }
    func with(navigationDestination: @escaping (Template) -> Void) -> TemplateListConfiguration<Template> {
        TemplateListConfiguration(
            title: title,
            emptyStateTitle: emptyStateTitle,
            emptyStateIcon: emptyStateIcon,
            emptyStateDescription: emptyStateDescription,
            errorTitle: errorTitle,
            errorSubtitle: errorSubtitle,
            navigationDestination: navigationDestination
        )
    }
}

// MARK: - Predefined Configurations

extension TemplateListConfiguration where Template == ExerciseModel {
    static var exercise: TemplateListConfiguration<ExerciseModel> {
        TemplateListConfiguration(
            title: "My Exercises",
            emptyStateTitle: "No Exercises",
            emptyStateIcon: "figure.strengthtraining.traditional",
            emptyStateDescription: "You haven't created any exercise templates yet.",
            errorTitle: "Unable to load exercises",
            navigationDestination: { _ in
                
            }
        )
    }
    
    static func exercise(customTitle: String?) -> TemplateListConfiguration<ExerciseModel> {
        TemplateListConfiguration(
            title: customTitle ?? "Exercise Templates",
            emptyStateTitle: "No Exercises",
            emptyStateIcon: "figure.strengthtraining.traditional",
            emptyStateDescription: "You haven't created any exercise templates yet.",
            errorTitle: "Unable to load exercises",
            navigationDestination: { _ in

            }
        )
    }
}

extension TemplateListConfiguration where Template == WorkoutTemplateModel {
    static var workout: TemplateListConfiguration<WorkoutTemplateModel> {
        TemplateListConfiguration(
            title: "My Workouts",
            emptyStateTitle: "No Workouts",
            emptyStateIcon: "figure.run",
            emptyStateDescription: "You haven't created any workout templates yet.",
            errorTitle: "Unable to Load Workouts",
            errorSubtitle: "Please try again later.",
            navigationDestination: { _ in

            }
        )
    }
    
    static func workout(customTitle: String?, customEmptyDescription: String?) -> TemplateListConfiguration<WorkoutTemplateModel> {
        TemplateListConfiguration(
            title: customTitle ?? "Workout Templates",
            emptyStateTitle: "No Workouts",
            emptyStateIcon: "figure.run",
            emptyStateDescription: customEmptyDescription ?? "No workout templates available.",
            errorTitle: "Unable to Load Workouts",
            errorSubtitle: "Please try again later.",
            navigationDestination: { _ in

            }
        )
    }
}

extension TemplateListConfiguration where Template == IngredientTemplateModel {
    static var ingredient: TemplateListConfiguration<IngredientTemplateModel> {
        TemplateListConfiguration(
            title: "My Ingredients",
            emptyStateTitle: "No Ingredients",
            emptyStateIcon: "carrot",
            emptyStateDescription: "You haven't created any ingredient templates yet.",
            errorTitle: "Unable to load ingredients",
            navigationDestination: { _ in

            }
        )
    }
}

extension TemplateListConfiguration where Template == RecipeTemplateModel {
    static var recipe: TemplateListConfiguration<RecipeTemplateModel> {
        TemplateListConfiguration(
            title: "My Recipes",
            emptyStateTitle: "No Recipes",
            emptyStateIcon: "fork.knife",
            emptyStateDescription: "You haven't created any recipe templates yet.",
            errorTitle: "Unable to load recipes",
            navigationDestination: { _ in

            }
        )
    }
}
