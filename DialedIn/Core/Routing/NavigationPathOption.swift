//
//  NavigationPathOption.swift
//  DialedIn
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
    case workoutSessionDetail(session: WorkoutSessionModel)
}

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
    
    /// A view builder that the split view uses to show a view for the selected navigation option.
    @MainActor @ViewBuilder func viewForPage(container: DependencyContainer) -> some View {
        switch self {
        case .dashboard: DashboardView(viewModel: DashboardViewModel(interactor: CoreInteractor(container: container)))
        case .nutrition: NutritionView(viewModel: NutritionViewModel(interactor: CoreInteractor(container: container)))
        case .training: TrainingView(viewModel: TrainingViewModel(interactor: CoreInteractor(container: container)))
        case .profile: ProfileView(viewModel: ProfileViewModel(interactor: CoreInteractor(container: container)))
        case .search: SearchView()
        }
    }
}

struct NavDestinationForCoreModuleViewModifier: ViewModifier {
    
    @Environment(DependencyContainer.self) private var container
    let path: Binding<[NavigationPathOption]>
    
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: NavigationPathOption.self) { newValue in
                switch newValue {
                case .exerciseTemplate(exerciseTemplate: let exerciseTemplate):
                    ExerciseTemplateDetailView(viewModel: ExerciseTemplateDetailViewModel(interactor: CoreInteractor(container: container)), exerciseTemplate: exerciseTemplate)
                case .workoutTemplateList:
                    WorkoutTemplateListView(viewModel: WorkoutTemplateListViewModel(interactor: CoreInteractor(container: container)))
                case .workoutTemplateDetail(template: let template):
                    WorkoutTemplateDetailView(viewModel: WorkoutTemplateDetailViewModel(interactor: CoreInteractor(container: container)), workoutTemplate: template)
                case .ingredientTemplateDetail(template: let template):
                    IngredientDetailView(viewModel: IngredientDetailViewModel(interactor: CoreInteractor(container: container), ingredientTemplate: template))
                case .recipeTemplateDetail(template: let template):
                    RecipeDetailView(viewModel: RecipeDetailViewModel(interactor: CoreInteractor(container: container), recipeTemplate: template))
                case .workoutSessionDetail(session: let session):
                    WorkoutSessionDetailView(viewModel: WorkoutSessionDetailViewModel(interactor: CoreInteractor(container: container), session: session))
                }
            }
    }
}

extension View {
    
    func navigationDestinationForCoreModule(path: Binding<[NavigationPathOption]>) -> some View {
        modifier(NavDestinationForCoreModuleViewModifier(path: path))
    }
}
