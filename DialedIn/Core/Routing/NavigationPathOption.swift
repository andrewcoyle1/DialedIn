//
//  NavigationPathOption.swift
//  AIChatCourse
//
//  Created by Andrew Coyle on 10/12/24.
//
import SwiftUI
import Foundation

enum NavigationPathOption: Hashable {
    case exerciseTemplate(exerciseTemplate: ExerciseTemplateModel)
    case workoutTemplateList
    case workoutTemplateDetail(template: WorkoutTemplateModel)
    case ingredientTemplateDetail(template: IngredientTemplateModel)
    case recipeTemplateDetail(template: RecipeTemplateModel)
}

enum NavigationOptions: Equatable, Hashable, Identifiable {
    case dashboard
    case nutrition
    case training
    case profile
    
    static let mainPages: [NavigationOptions] = [.dashboard, .nutrition, .training, .profile]
    var id: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .nutrition: return "Nutrition"
        case .training: return "Training"
        case .profile: return "Profile"
        }
    }
    
    var name: LocalizedStringResource {
        switch self {
        case .dashboard: LocalizedStringResource("Dashboard", comment: "Title for the Dashboard tab, shown in the sidebar.")
        case .nutrition: LocalizedStringResource("Nutrition", comment: "Title for the Nutrition tab, shown in the sidebar.")
        case .training: LocalizedStringResource("Training", comment: "Title for the Training tab, shown in the sidebar.")
        case .profile: LocalizedStringResource("Profile", comment: "Title for the Profile tab, shown in the sidebar.")
        }
    }
    
    var symbolName: String {
        switch self {
        case .dashboard: "house"
        case .nutrition: "dumbbell"
        case .training: "carrot"
        case .profile: "person.fill"
        }
    }
    
    /// A view builder that the split view uses to show a view for the selected navigation option.
    @MainActor @ViewBuilder func viewForPage() -> some View {
        switch self {
        case .dashboard: DashboardView()
        case .nutrition: NutritionView()
        case .training: TrainingView()
        case .profile: ProfileView()
        }
    }
}

extension View {
    
    func navigationDestinationForCoreModule(path: Binding<[NavigationPathOption]>) -> some View {
        self
            .navigationDestination(for: NavigationPathOption.self) { newValue in
                switch newValue {
                case .exerciseTemplate(exerciseTemplate: let exerciseTemplate):
                    ExerciseDetailView(exerciseTemplate: exerciseTemplate)
                case .workoutTemplateList:
                    WorkoutTemplateListView()
                case .workoutTemplateDetail(template: let template):
                    WorkoutTemplateDetailView(workoutTemplate: template)
                case .ingredientTemplateDetail(template: let template):
                    IngredientDetailView(ingredientTemplate: template)
                case .recipeTemplateDetail(template: let template):
                    RecipeDetailView(recipeTemplate: template)
                }
            }
    }
}
