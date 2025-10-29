//
//  NavigationPathOption.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/12/24.
//

import Foundation

enum NavigationPathOption: Hashable, Sendable {
    case exerciseTemplate(exerciseTemplate: ExerciseTemplateModel)
    case workoutTemplateList
    case workoutTemplateDetail(template: WorkoutTemplateModel)
    case ingredientTemplateDetail(template: IngredientTemplateModel)
    case recipeTemplateDetail(template: RecipeTemplateModel)
    case workoutSessionDetail(session: WorkoutSessionModel)
    case mealDetail(meal: MealLogModel)
}
//
// extension NavigationPathOption: Equatable {
//    static func == (lhs: NavigationPathOption, rhs: NavigationPathOption) -> Bool {
//        switch (lhs, rhs) {
//        case let (.exerciseTemplate(a), .exerciseTemplate(b)):
//            return a == b
//        case (.workoutTemplateList, .workoutTemplateList):
//            return true
//        case let (.workoutTemplateDetail(a), .workoutTemplateDetail(b)):
//            return a == b
//        case let (.ingredientTemplateDetail(a), .ingredientTemplateDetail(b)):
//            return a == b
//        case let (.recipeTemplateDetail(a), .recipeTemplateDetail(b)):
//            return a == b
//        case let (.workoutSessionDetail(a), .workoutSessionDetail(b)):
//            return a == b
//        default:
//            return false
//        }
//    }
// }

enum NavigationOptions: Equatable, Hashable, Identifiable {
    case dashboard
    case nutrition
    case training
    case profile
    case search
    
    static let mainPages: [NavigationOptions] = [.dashboard, .nutrition, .training, .profile]
    var id: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .nutrition: return "Nutrition"
        case .training: return "Training"
        case .profile: return "Profile"
        case .search: return "Search"
        }
    }
    
    var name: LocalizedStringResource {
        switch self {
        case .dashboard: LocalizedStringResource("Dashboard", comment: "Title for the Dashboard tab, shown in the sidebar.")
        case .nutrition: LocalizedStringResource("Nutrition", comment: "Title for the Nutrition tab, shown in the sidebar.")
        case .training: LocalizedStringResource("Training", comment: "Title for the Training tab, shown in the sidebar.")
        case .profile: LocalizedStringResource("Profile", comment: "Title for the Profile tab, shown in the sidebar.")
        case .search: LocalizedStringResource("Search", comment: "Title for the Search tab, shown in the sidebar.")
        }
    }
    
    var symbolName: String {
        switch self {
        case .dashboard: "house"
        case .nutrition: "dumbbell"
        case .training: "carrot"
        case .profile: "person.fill"
        case .search: "magnifyingglass"
        }
    }
}
