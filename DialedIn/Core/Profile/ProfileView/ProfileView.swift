//
//  ProfileView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 25/09/2025.
//

import SwiftUI

struct ProfileViewDelegate {
    var path: Binding<[TabBarPathOption]>
}

struct ProfileView: View {

    @Environment(\.layoutMode) private var layoutMode

    @State var viewModel: ProfileViewModel

    var delegate: ProfileViewDelegate

    @ViewBuilder var profileHeaderView: (ProfileHeaderViewDelegate) -> AnyView
    @ViewBuilder var profilePhysicalMetricsView: (ProfilePhysicalMetricsViewDelegate) -> AnyView
    @ViewBuilder var profileGoalSection: (ProfileGoalSectionDelegate) -> AnyView
    @ViewBuilder var profileNutritionPlanView: (ProfileNutritionPlanViewDelegate) -> AnyView
    @ViewBuilder var profilePreferencesView: (ProfilePreferencesViewDelegate) -> AnyView
    @ViewBuilder var profileMyTemplatesView: (ProfileMyTemplatesViewDelegate) -> AnyView
    @ViewBuilder var devSettingsView: () -> AnyView
    @ViewBuilder var createAccountView: () -> AnyView
    @ViewBuilder var notificationsView: () -> AnyView
    @ViewBuilder var setGoalFlowView: () -> AnyView

    @ViewBuilder var exerciseTemplateDetailView: (ExerciseTemplateDetailViewDelegate) -> AnyView
    @ViewBuilder var exerciseTemplateListView: (ExerciseTemplateListViewDelegate) -> AnyView
    @ViewBuilder var workoutTemplateListView: (WorkoutTemplateListViewDelegate) -> AnyView
    @ViewBuilder var workoutTemplateDetailView: (WorkoutTemplateDetailViewDelegate) -> AnyView
    @ViewBuilder var ingredientDetailView: (IngredientDetailViewDelegate) -> AnyView
    @ViewBuilder var ingredientTemplateListView: (IngredientTemplateListViewDelegate) -> AnyView
    @ViewBuilder var ingredientAmountView: (IngredientAmountViewDelegate) -> AnyView
    @ViewBuilder var recipeDetailView: (RecipeDetailViewDelegate) -> AnyView
    @ViewBuilder var recipeTemplateListView: (RecipeTemplateListViewDelegate) -> AnyView
    @ViewBuilder var recipeAmountView: (RecipeAmountViewDelegate) -> AnyView
    @ViewBuilder var workoutSessionDetailView: (WorkoutSessionDetailViewDelegate) -> AnyView
    @ViewBuilder var mealDetailView: (MealDetailViewDelegate) -> AnyView
    @ViewBuilder var profileGoalsDetailView: () -> AnyView
    @ViewBuilder var profileEditView: () -> AnyView
    @ViewBuilder var profileNutritionDetailView: () -> AnyView
    @ViewBuilder var profilePhysicalStatsView: () -> AnyView
    @ViewBuilder var settingsView: (SettingsViewDelegate) -> AnyView
    @ViewBuilder var manageSubscriptionView: () -> AnyView
    @ViewBuilder var programPreviewView: (ProgramPreviewViewDelegate) -> AnyView
    @ViewBuilder var customProgramBuilderView: (CustomProgramBuilderViewDelegate) -> AnyView
    @ViewBuilder var programGoalsView: (ProgramGoalsViewDelegate) -> AnyView
    @ViewBuilder var programScheduleView: (ProgramScheduleViewDelegate) -> AnyView

    var body: some View {
        Group {
            if layoutMode == .tabBar {
                NavigationStack(path: delegate.path) {
                    contentView
                }
                .navDestinationForTabBarModule(
                    path: delegate.path,
                    exerciseTemplateDetailView: exerciseTemplateDetailView,
                    exerciseTemplateListView: exerciseTemplateListView,
                    workoutTemplateListView: workoutTemplateListView,
                    workoutTemplateDetailView: workoutTemplateDetailView,
                    ingredientDetailView: ingredientDetailView,
                    ingredientTemplateListView: ingredientTemplateListView,
                    ingredientAmountView: ingredientAmountView,
                    recipeDetailView: recipeDetailView,
                    recipeTemplateListView: recipeTemplateListView,
                    recipeAmountView: recipeAmountView,
                    workoutSessionDetailView: workoutSessionDetailView,
                    mealDetailView: mealDetailView,
                    profileGoalsDetailView: profileGoalsDetailView,
                    profileEditView: profileEditView,
                    profileNutritionDetailView: profileNutritionDetailView,
                    profilePhysicalStatsView: profilePhysicalStatsView,
                    settingsView: settingsView,
                    manageSubscriptionView: manageSubscriptionView,
                    programPreviewView: programPreviewView,
                    customProgramBuilderView: customProgramBuilderView,
                    programGoalsView: programGoalsView,
                    programScheduleView: programScheduleView
                )
            } else {
                contentView
            }
        }
    }
    
    private var contentView: some View {
        List {
            if let user = viewModel.currentUser,
               let firstName = user.firstName, !firstName.isEmpty {
                profileHeaderView(ProfileHeaderViewDelegate(path: delegate.path))
                profilePhysicalMetricsView(ProfilePhysicalMetricsViewDelegate(path: delegate.path))
                profileGoalSection(ProfileGoalSectionDelegate(path: delegate.path))
                profileNutritionPlanView(ProfileNutritionPlanViewDelegate(path: delegate.path))
                profilePreferencesView(ProfilePreferencesViewDelegate(path: delegate.path))
                profileMyTemplatesView(ProfileMyTemplatesViewDelegate(path: delegate.path))
            } else {
                createProfileSection
            }
        }
        .navigationTitle("Profile")
        .navigationSubtitle(Date.now.formatted(date: .abbreviated, time: .omitted))
        .scrollIndicators(.hidden)
        .navigationBarTitleDisplayMode(.large)
        #if DEBUG || MOCK
        .sheet(isPresented: $viewModel.showDebugView, content: {
            devSettingsView()
        })
        #endif
        .sheet(isPresented: $viewModel.showCreateProfileSheet) {
            createAccountView()
                .presentationDetents([
                    .fraction(0.4)
                ])
        }
        .sheet(isPresented: $viewModel.showNotifications) {
            notificationsView()
        }
        .sheet(isPresented: $viewModel.showSetGoalSheet) {
            setGoalFlowView()
        }
        .toolbar {
            toolbarContent
        }
        .task {
            await viewModel.getActiveGoal()
            
        }
    }
    
    var createProfileSection: some View {
        Section {
            Button {
                viewModel.showCreateProfileSheet = true
            } label: {
                CustomListCellView(
                    imageName: nil,
                    title: "Create your profile",
                    subtitle: "Tap to get started",
                    isSelected: true,
                    iconName: "person.circle",
                    iconSize: CGFloat(32)
                )
            }
            .removeListRowFormatting()
        } header: {
            Text("Profile")
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                viewModel.showDebugView = true
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarItem(placement: .topBarLeading) {
            Button {
                onNotificationsPressed()
            } label: {
                Image(systemName: "bell")
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.navToSettingsView(path: delegate.path)
            } label: {
                Image(systemName: "gear")
            }
        }
    }
    
    private func onNotificationsPressed() {
        viewModel.showNotifications = true
    }
}

// MARK: - Previews
#Preview("User Has Profile") {
    @Previewable @State var path: [TabBarPathOption] = []
    let builder = CoreBuilder(container: DevPreview.shared.container)
    builder.profileView(delegate: ProfileViewDelegate(path: $path))
    .previewEnvironment()
}

#Preview("User No Profile") {
    @Previewable @State var path: [TabBarPathOption] = []
    let builder = CoreBuilder(container: DevPreview.shared.container)
    builder.profileView(delegate: ProfileViewDelegate(path: $path))
    .previewEnvironment()
}
