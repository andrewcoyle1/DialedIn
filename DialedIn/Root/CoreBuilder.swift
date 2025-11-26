//
//  CoreBuilder.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/11/2025.
//

import SwiftUI
import CustomRouting

@Observable
@MainActor
// swiftlint:disable:next type_body_length
class CoreBuilder {

    let interactor: CoreInteractor

    init(container: DependencyContainer) {
        interactor = CoreInteractor(container: container)
    }

    func appView() -> AnyView {
        AppView(
            viewModel: AppViewModel(interactor: interactor),
            adaptiveMainView: { self.adaptiveMainView() },
            onboardingWelcomeView: {
                RouterView { router in
                    self.onboardingWelcomeView(router: router)
                }
                .any()
            }
        )
        .any()
    }

    // MARK: Onboarding

    func onboardingWelcomeView(router: Router) -> AnyView {
        OnboardingWelcomeView(
            viewModel: OnboardingWelcomeViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func onboardingIntroView(router: Router) -> AnyView {
        OnboardingIntroView(
            viewModel: OnboardingIntroViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    // MARK: Onboarding Auth

    func onboardingAuthOptionsView(router: Router) -> AnyView {
        AuthOptionsView(
            viewModel: AuthOptionsViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func onboardingSignInView(router: Router) -> AnyView {
        SignInView(
            viewModel: SignInViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func onboardingSignUpView(router: Router) -> AnyView {
        SignUpView(
            viewModel: SignUpViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func onboardingEmailVerificationView(router: Router) -> AnyView {
        EmailVerificationView(
            viewModel: EmailVerificationViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    // MARK: Onboarding Subscriptions

    func onboardingSubscriptionView(router: Router) -> AnyView {
        OnboardingSubscriptionView(
            viewModel: OnboardingSubscriptionViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func onboardingSubscriptionPlanView(router: Router) -> AnyView {
        OnboardingSubscriptionPlanView(
            viewModel: OnboardingSubscriptionPlanViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func onboardingCompleteAccountSetupView(router: Router) -> AnyView {
        OnboardingCompleteAccountSetupView(
            viewModel: OnboardingCompleteAccountSetupViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func onboardingNamePhotoView(router: Router) -> AnyView {
        OnboardingNamePhotoView(
            viewModel: OnboardingNamePhotoViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func onboardingGenderView(router: Router) -> AnyView {
        OnboardingGenderView(
            viewModel: OnboardingGenderViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func onboardingDateOfBirthView(router: Router, delegate: OnboardingDateOfBirthViewDelegate) -> AnyView {
        OnboardingDateOfBirthView(
            viewModel: OnboardingDateOfBirthViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingHeightView(router: Router, delegate: OnboardingHeightViewDelegate) -> AnyView {
        OnboardingHeightView(
            viewModel: OnboardingHeightViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingWeightView(router: Router, delegate: OnboardingWeightViewDelegate) -> AnyView {
        OnboardingWeightView(
            viewModel: OnboardingWeightViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingExerciseFrequencyView(router: Router, delegate: OnboardingExerciseFrequencyViewDelegate) -> AnyView {
        OnboardingExerciseFrequencyView(
            viewModel: OnboardingExerciseFrequencyViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingActivityView(router: Router, delegate: OnboardingActivityViewDelegate) -> AnyView {
        OnboardingActivityView(
            viewModel: OnboardingActivityViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingCardioFitnessView(router: Router, delegate: OnboardingCardioFitnessViewDelegate) -> AnyView {
        OnboardingCardioFitnessView(
            viewModel: OnboardingCardioFitnessViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingExpenditureView(router: Router, delegate: OnboardingExpenditureViewDelegate) -> AnyView {
        OnboardingExpenditureView(
            viewModel: OnboardingExpenditureViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingHealthDataView(router: Router) -> AnyView {
        OnboardingHealthDataView(
            viewModel: OnboardingHealthDataViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func onboardingNotificationsView(router: Router) -> AnyView {
        OnboardingNotificationsView(
            viewModel: OnboardingNotificationsViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func onboardingHealthDisclaimerView(router: Router) -> AnyView {
        OnboardingHealthDisclaimerView(
            viewModel: OnboardingHealthDisclaimerViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    // MARK: Onboarding Goal Setting

    func onboardingGoalSettingView(router: Router) -> AnyView {
        OnboardingGoalSettingView(
            viewModel: OnboardingGoalSettingViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func onboardingOverarchingObjectiveView(router: Router) -> AnyView {
        OnboardingOverarchingObjectiveView(
            viewModel: OnboardingOverarchingObjectiveViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func onboardingTargetWeightView(router: Router, delegate: OnboardingTargetWeightViewDelegate) -> AnyView {
        OnboardingTargetWeightView(
            viewModel: OnboardingTargetWeightViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingWeightRateView(router: Router, delegate: OnboardingWeightRateViewDelegate) -> AnyView {
        OnboardingWeightRateView(
            viewModel: OnboardingWeightRateViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingGoalSummaryView(router: Router, delegate: OnboardingGoalSummaryViewDelegate) -> AnyView {
        OnboardingGoalSummaryView(
            viewModel: OnboardingGoalSummaryViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    // MARK: Customise Program

    func onboardingTrainingProgramView(router: Router) -> AnyView {
        OnboardingTrainingProgramView(
            viewModel: OnboardingTrainingProgramViewModel(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
        .any()
    }

    func onboardingCustomisingProgramView(router: Router) -> AnyView {
        OnboardingCustomisingProgramView(
            viewModel: OnboardingCustomisingProgramViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func onboardingTrainingExperienceView(router: Router, delegate: OnboardingTrainingExperienceViewDelegate) -> AnyView {
        OnboardingTrainingExperienceView(
            viewModel: OnboardingTrainingExperienceViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingTrainingDaysPerWeekView(router: Router, delegate: OnboardingTrainingDaysPerWeekViewDelegate) -> AnyView {
        OnboardingTrainingDaysPerWeekView(
            viewModel: OnboardingTrainingDaysPerWeekViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingTrainingSplitView(router: Router, delegate: OnboardingTrainingSplitViewDelegate) -> AnyView {
        OnboardingTrainingSplitView(
            viewModel: OnboardingTrainingSplitViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingTrainingScheduleView(router: Router, delegate: OnboardingTrainingScheduleViewDelegate) -> AnyView {
        OnboardingTrainingScheduleView(
            viewModel: OnboardingTrainingScheduleViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingTrainingEquipmentView(router: Router, delegate: OnboardingTrainingEquipmentViewDelegate) -> AnyView {
        OnboardingTrainingEquipmentView(
            viewModel: OnboardingTrainingEquipmentViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingTrainingReviewView(router: Router, delegate: OnboardingTrainingReviewViewDelegate) -> AnyView {
        OnboardingTrainingReviewView(
            viewModel: OnboardingTrainingReviewViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingPreferredDietView(router: Router) -> AnyView {
        OnboardingPreferredDietView(
            viewModel: OnboardingPreferredDietViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func onboardingCalorieFloorView(router: Router, delegate: OnboardingCalorieFloorViewDelegate) -> AnyView {
        OnboardingCalorieFloorView(
            viewModel: OnboardingCalorieFloorViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingTrainingTypeView(router: Router, delegate: OnboardingTrainingTypeViewDelegate) -> AnyView {
        OnboardingTrainingTypeView(
            viewModel: OnboardingTrainingTypeViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingCalorieDistributionView(router: Router, delegate: OnboardingCalorieDistributionViewDelegate) -> AnyView {
        OnboardingCalorieDistributionView(
            viewModel: OnboardingCalorieDistributionViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingProteinIntakeView(router: Router, delegate: OnboardingProteinIntakeViewDelegate) -> AnyView {
        OnboardingProteinIntakeView(
            viewModel: OnboardingProteinIntakeViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingDietPlanView(router: Router, delegate: OnboardingDietPlanViewDelegate) -> AnyView {
        OnboardingDietPlanView(
            viewModel: OnboardingDietPlanViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingCompletedView(router: Router) -> AnyView {
        OnboardingCompletedView(
            viewModel: OnboardingCompletedViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    // MARK: Main App
    func adaptiveMainView() -> AnyView {
        AdaptiveMainView(
            viewModel: AdaptiveMainViewModel(interactor: interactor),
            tabBarView: {
                self.tabBarView()
                .any()
            },
            splitViewContainer: {
                self.splitViewContainer()
            }
        )
        .any()
    }

    func tabBarView() -> AnyView {
        TabBarView(
            viewModel: TabBarViewModel(interactor: interactor),
            tabs: [
                TabBarScreen(
                    title: "Dashboard",
                    systemImage: "house",
                    screen: {
                        RouterView { router in
                            self.dashboardView(router: router)
                        }
                        .any()
                    }
                ),
                TabBarScreen(
                    title: "Nutrition",
                    systemImage: "carrot",
                    screen: {
                        RouterView { router in
                            self.nutritionView(router: router)
                        }
                        .any()
                    }
                ),
                TabBarScreen(
                    title: "Training",
                    systemImage: "dumbbell",
                    screen: {
                        RouterView { router in
                            self.trainingView(router: router)
                        }
                        .any()
                    }
                ),
                TabBarScreen(
                    title: "Profile",
                    systemImage: "person",
                    screen: {
                        RouterView { router in
                            self.profileView(router: router)
                        }
                        .any()
                    }
                )
            ],
            tabViewAccessoryView: { delegate in
                self.tabViewAccessoryView(delegate: delegate)
            }
        )
        .any()
    }

    // swiftlint:disable:next function_body_length
    func splitViewContainer() -> AnyView {
        SplitViewContainer(
            viewModel: SplitViewContainerViewModel(interactor: interactor),
            tabs: [
                TabBarScreen(
                    title: "Dashboard",
                    systemImage: "house",
                    screen: {
                        RouterView { router in
                            self.dashboardView(router: router)
                        }
                        .any()
                    }
                ),
                TabBarScreen(
                    title: "Nutrition",
                    systemImage: "carrot",
                    screen: {
                        RouterView { router in
                            self.nutritionView(router: router)
                        }
                        .any()
                    }
                ),
                TabBarScreen(
                    title: "Training",
                    systemImage: "dumbbell",
                    screen: {
                        RouterView { router in
                            self.trainingView(router: router)
                        }
                        .any()
                    }
                ),
                TabBarScreen(
                    title: "Profile",
                    systemImage: "person",
                    screen: {
                        RouterView { router in
                            self.profileView(router: router)
                        }
                        .any()
                    }
                )
            ],
            tabViewAccessoryView: { accessoryDelegate in
                self.tabViewAccessoryView(delegate: accessoryDelegate)
            },
            workoutTrackerView: { trackerDelegate in
                RouterView { router in
                    self.workoutTrackerView(router: router, delegate: trackerDelegate)
                }
                .any()
            }
        )
        .any()
    }

    func exerciseTemplateDetailView(router: Router, delegate: ExerciseTemplateDetailViewDelegate) -> AnyView {
        ExerciseTemplateDetailView(
            viewModel: ExerciseTemplateDetailViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func tabViewAccessoryView(delegate: TabViewAccessoryViewDelegate) -> AnyView {
        TabViewAccessoryView(
            viewModel: TabViewAccessoryViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func workoutTrackerView(router: Router, delegate: WorkoutTrackerViewDelegate) -> AnyView {
        WorkoutTrackerView(
            viewModel: WorkoutTrackerViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate,
            exerciseTrackerCardView: { delegate in
                self.exerciseTrackerCardView(router: router, delegate: delegate)
            }
        )
        .any()
    }

    func ingredientDetailView(router: Router, delegate: IngredientDetailViewDelegate) -> AnyView {
        IngredientDetailView(
            viewModel: IngredientDetailViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func exerciseTemplateListView(router: Router, delegate: ExerciseTemplateListViewDelegate) -> AnyView {
        ExerciseTemplateListView(
            viewModel: ExerciseTemplateListViewModel.create(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate,
            genericTemplateListView: { viewModel, configuration, supportsRefresh, templateIdsOverride in
                self.genericTemplateListView(
                    viewModel: viewModel,
                    configuration: configuration,
                    supportsRefresh: supportsRefresh,
                    templateIdsOverride: templateIdsOverride
                )
            }
        )
        .any()
    }

    func workoutTemplateListView(router: Router, delegate: WorkoutTemplateListViewDelegate) -> AnyView {
        WorkoutTemplateListView(
            viewModel: WorkoutTemplateListViewModel.create(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate,
            genericTemplateListView: { viewModel, configuration, supportsRefresh, templateIdsOverride in
                self.genericTemplateListView(
                    viewModel: viewModel,
                    configuration: configuration,
                    supportsRefresh: supportsRefresh,
                    templateIdsOverride: templateIdsOverride
                )
            }
        )
        .any()
    }

    func workoutTemplateDetailView(router: Router, delegate: WorkoutTemplateDetailViewDelegate) -> AnyView {
        WorkoutTemplateDetailView(
            viewModel: WorkoutTemplateDetailViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func workoutSessionDetailView(router: Router, delegate: WorkoutSessionDetailViewDelegate) -> AnyView {
        WorkoutSessionDetailView(
            viewModel: WorkoutSessionDetailViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate,
            editableExerciseCardWrapper: { delegate in
                self.editableExerciseCardWrapper(delegate: delegate)
            }
        )
        .any()
    }

    func programView(router: Router, delegate: ProgramViewDelegate) -> AnyView {
        ProgramView(
            viewModel: ProgramViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate,
            workoutSummaryCardView: { delegate in
                self.workoutSummaryCardView(delegate: delegate)
            },
            todaysWorkoutCardView: { delegate in
                self.todaysWorkoutCardView(delegate: delegate)
            },
            workoutCalendarView: { delegate in
                self.workoutCalendarView(delegate: delegate)
            },
            scheduledWorkoutRowView: { delegate in
                self.scheduledWorkoutRowView(delegate: delegate)
            }
        )
        .any()
    }

    func devSettingsView(router: Router) -> AnyView {
        DevSettingsView(
            viewModel: DevSettingsViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func workoutStartView(router: Router, delegate: WorkoutStartViewDelegate) -> AnyView {
        WorkoutStartView(
            viewModel: WorkoutStartViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func dashboardView(router: Router) -> AnyView {
        DashboardView(
            viewModel: DashboardViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            nutritionTargetChartView: { self.nutritionTargetChartView() }
        )
        .any()
    }

    func createIngredientView(router: Router) -> AnyView {
        CreateIngredientView(
            viewModel: CreateIngredientViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func addIngredientModalView(router: Router, delegate: AddIngredientModalViewDelegate) -> AnyView {
        AddIngredientModalView(
            viewModel: AddIngredientModalViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func createRecipeView(router: Router) -> AnyView {
        CreateRecipeView(
            viewModel: CreateRecipeViewModel(
                interactor: interactor,
                router: CoreRouter(
                    router: router,
                    builder: self
                )
            )
        )
        .any()
    }

    func recipeStartView(router: Router, delegate: RecipeStartViewDelegate) -> AnyView {
        RecipeStartView(
            viewModel: RecipeStartViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
            .any()
    }

    func mealLogView(router: Router, delegate: MealLogViewDelegate) -> AnyView {
        MealLogView(
            viewModel: MealLogViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func recipesView(router: Router, delegate: RecipesViewDelegate) -> AnyView {
        RecipesView(
            viewModel: RecipesViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func ingredientsView(router: Router, delegate: IngredientsViewDelegate) -> AnyView {
        IngredientsView(
            viewModel: IngredientsViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func nutritionView(router: Router) -> AnyView {
        NutritionView(
            viewModel: NutritionViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            mealLogView: { delegate in
                self.mealLogView(router: router, delegate: delegate)
            },
            recipesView: { delegate in
                self.recipesView(router: router, delegate: delegate)
            },
            ingredientsView: { delegate in
                self.ingredientsView(router: router, delegate: delegate)
            }
        )
        .any()
    }

    func nutritionLibraryPickerView(router: Router, delegate: NutritionLibraryPickerViewDelegate) -> AnyView {
        NutritionLibraryPickerView(
            viewModel: NutritionLibraryPickerViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func addMealSheet(router: Router, delegate: AddMealSheetDelegate) -> AnyView {
        AddMealSheet(
            viewModel: AddMealSheetViewModel(
                interactor: interactor,
                router: CoreRouter(
                    router: router,
                    builder: self
                )
            ),
            delegate: delegate
        )
        .any()
    }

    func ingredientAmountView(router: Router, delegate: IngredientAmountViewDelegate) -> AnyView {
        IngredientAmountView(
            viewModel: IngredientAmountViewModel(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
        .any()
    }

    func nutritionTargetChartView() -> AnyView {
        NutritionTargetChartView(
            viewModel: NutritionTargetChartViewModel(interactor: interactor)
        )
        .any()
    }

    func workoutsView(router: Router, delegate: WorkoutsViewDelegate) -> AnyView {
        WorkoutsView(
            viewModel: WorkoutsViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func workoutHistoryView(router: Router, delegate: WorkoutHistoryViewDelegate) -> AnyView {
        WorkoutHistoryView(
            viewModel: WorkoutHistoryViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func createWorkoutView(router: Router, delegate: CreateWorkoutViewDelegate) -> AnyView {
        CreateWorkoutView(
            viewModel: CreateWorkoutViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func createExerciseView(router: Router) -> AnyView {
        CreateExerciseView(
            viewModel: CreateExerciseViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func addGoalView(router: Router, delegate: AddGoalViewDelegate) -> AnyView {
        AddGoalView(
            viewModel: AddGoalViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func workoutSummaryCardView(delegate: WorkoutSummaryCardViewDelegate) -> AnyView {
        WorkoutSummaryCardView(
            viewModel: WorkoutSummaryCardViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func todaysWorkoutCardView(delegate: TodaysWorkoutCardViewDelegate) -> AnyView {
        TodaysWorkoutCardView(
            viewModel: TodaysWorkoutCardViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func scheduledWorkoutRowView(delegate: ScheduledWorkoutRowViewDelegate) -> AnyView {
        ScheduledWorkoutRowView(
            viewModel: ScheduledWorkoutRowViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func programRowView(delegate: ProgramRowViewDelegate) -> AnyView {
        ProgramRowView(
            viewModel: ProgramRowViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func workoutCalendarView(delegate: WorkoutCalendarViewDelegate) -> AnyView {
        WorkoutCalendarView(
            viewModel: WorkoutCalendarViewModel(interactor: interactor),
            delegate: delegate,
            enhancedScheduleView: { delegate in
                self.enhancedScheduleView(delegate: delegate)
            }
        )
        .any()
    }

    func editableExerciseCardWrapper(delegate: EditableExerciseCardWrapperDelegate) -> AnyView {
        EditableExerciseCardWrapper(
            delegate: delegate,
            interactor: interactor
        )
        .any()
    }

    func exercisesView(router: Router, delegate: ExercisesViewDelegate) -> AnyView {
        ExercisesView(
            viewModel: ExercisesViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func programManagementView(router: Router) -> AnyView {
        ProgramManagementView(
            viewModel: ProgramManagementViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            programRowView: { delegate in
                self.programRowView(delegate: delegate)
            }
        )
        .any()
    }

    func trainingView(router: Router) -> AnyView {
        TrainingView(
            viewModel: TrainingViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            programView: { delegate in
                self.programView(router: router, delegate: delegate)
            },
            workoutsView: { delegate in
                self.workoutsView(router: router, delegate: delegate)
            },
            exercisesView: { delegate in
                self.exercisesView(router: router, delegate: delegate)
            },
            workoutHistoryView: { delegate in
                self.workoutHistoryView(router: router, delegate: delegate)
            }
        )
        .any()
    }

    func progressDashboardView(router: Router) -> AnyView {
        ProgressDashboardView(
            viewModel: ProgressDashboardViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func strengthProgressView(router: Router) -> AnyView {
        StrengthProgressView(
            viewModel: StrengthProgressViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func workoutHeatmapView(router: Router) -> AnyView {
        WorkoutHeatmapView(
            viewModel: WorkoutHeatmapViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func notificationsView(router: Router) -> AnyView {
        NotificationsView(
            viewModel: NotificationsViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func programGoalsView(router: Router, delegate: ProgramGoalsViewDelegate) -> AnyView {
        ProgramGoalsView(
            viewModel: ProgramGoalsViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate,
            goalRow: { delegate in
                self.goalRow(delegate: delegate)
            }
        )
        .any()
    }

    func programScheduleView(router: Router, delegate: ProgramScheduleViewDelegate) -> AnyView {
        ProgramScheduleView(
            viewModel: ProgramScheduleViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func mealDetailView(router: Router, delegate: MealDetailViewDelegate) -> AnyView {
        MealDetailView(
            viewModel: MealDetailViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func profileGoalsDetailView(router: Router) -> AnyView {
        ProfileGoalsDetailView(
            viewModel: ProfileGoalsDetailViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func profileEditView(router: Router) -> AnyView {
        ProfileEditView(
            viewModel: ProfileEditViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func profileNutritionDetailView(router: Router) -> AnyView {
        ProfileNutritionDetailView(
            viewModel: ProfileNutritionDetailViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func profilePhysicalStatsView(router: Router) -> AnyView {
        ProfilePhysicalStatsView(
            viewModel: ProfilePhysicalStatsViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func settingsView(router: Router) -> AnyView {
        SettingsView(
            viewModel: SettingsViewModel(
                interactor: interactor,
                router: CoreRouter(
                    router: router,
                    builder: self
                )
            )
        )
        .any()
    }

    func ingredientTemplateListView(router: Router, delegate: IngredientTemplateListViewDelegate) -> AnyView {
        IngredientTemplateListView(
            interactor: interactor,
            router: CoreRouter(router: router, builder: self),
            delegate: delegate,
            genericTemplateListView: { viewModel, configuration, supportsRefresh, templateIdsOverride in
                self.genericTemplateListView(
                    viewModel: viewModel,
                    configuration: configuration,
                    supportsRefresh: supportsRefresh,
                    templateIdsOverride: templateIdsOverride
                )
            }
        )
        .any()
    }

    func goalRow(delegate: GoalRowDelegate) -> AnyView {
        GoalRow(
            viewModel: GoalRowViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func programTemplatePickerView(router: Router) -> AnyView {
        ProgramTemplatePickerView(
            viewModel: ProgramTemplatePickerViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func editProgramView(router: Router, delegate: EditProgramViewDelegate) -> AnyView {
        EditProgramView(
            viewModel: EditProgramViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func enhancedScheduleView(delegate: EnhancedScheduleViewDelegate) -> AnyView {
        EnhancedScheduleView(
            viewModel: EnhancedScheduleViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func logWeightView(router: Router) -> AnyView {
        LogWeightView(
            viewModel: LogWeightViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func profileHeaderView(router: Router) -> AnyView {
        ProfileHeaderView(
            viewModel: ProfileHeaderViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func profilePhysicalMetricsView(router: Router) -> AnyView {
        ProfilePhysicalMetricsView(
            viewModel: ProfilePhysicalMetricsViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func profileGoalSection(router: Router) -> AnyView {
        ProfileGoalSection(
            viewModel: ProfileGoalSectionViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func profileNutritionPlanView(router: Router) -> AnyView {
        ProfileNutritionPlanView(
            viewModel: ProfileNutritionPlanViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func profilePreferencesView(router: Router) -> AnyView {
        ProfilePreferencesView(
            viewModel: ProfilePreferencesViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func profileMyTemplatesView(router: Router) -> AnyView {
        ProfileMyTemplatesView(
            viewModel: ProfileMyTemplatesViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func recipeDetailView(router: Router, delegate: RecipeDetailViewDelegate) -> AnyView {
        RecipeDetailView(
            viewModel: RecipeDetailViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func recipeTemplateListView(router: Router, delegate: RecipeTemplateListViewDelegate) -> AnyView {
        RecipeTemplateListView(
            interactor: interactor,
            router: CoreRouter(router: router, builder: self),
            delegate: delegate,
            genericTemplateListView: { viewModel, configuration, supportsRefresh, templateIdsOverride in
                self.genericTemplateListView(
                    viewModel: viewModel,
                    configuration: configuration,
                    supportsRefresh: supportsRefresh,
                    templateIdsOverride: templateIdsOverride
                )
            }
        )
        .any()
    }

    // MARK: Generic Template List
    func genericTemplateListView<Template: TemplateModel>(
        viewModel: GenericTemplateListViewModel<Template>,
        configuration: TemplateListConfiguration<Template>,
        supportsRefresh: Bool,
        templateIdsOverride: [String]?
    ) -> AnyView {
        GenericTemplateListView(
            viewModel: viewModel,
            configuration: configuration,
            supportsRefresh: supportsRefresh,
            templateIdsOverride: templateIdsOverride
        )
        .any()
    }

    func customProgramBuilderView(router: Router) -> AnyView {
        CustomProgramBuilderView(
            viewModel: CustomProgramBuilderViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func programPreviewView(router: Router, delegate: ProgramPreviewViewDelegate) -> AnyView {
        ProgramPreviewView(
            viewModel: ProgramPreviewViewModel(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
        .any()
    }

    func manageSubscriptionView(router: Router, delegate: ManageSubscriptionDelegate) -> AnyView {
        ManageSubscriptionView(
            viewModel: ManageSubscriptionViewModel(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
        .any()
    }

    func recipeAmountView(router: Router, delegate: RecipeAmountViewDelegate) -> AnyView {
        RecipeAmountView(
            viewModel: RecipeAmountViewModel(
                interactor: interactor,
                router: CoreRouter(
                    router: router,
                    builder: self
                )
            ),
            delegate: delegate
        )
        .any()
    }

    func programStartConfigView(router: Router, delegate: ProgramStartConfigViewDelegate) -> AnyView {
        ProgramStartConfigView(
            viewModel: ProgramStartConfigViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func volumeChartsView(router: Router) -> AnyView {
         VolumeChartsView(
            viewModel: VolumeChartsViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            trendSummarySection: { delegate in
                self.trendSummarySection(delegate: delegate)
            }
         )
         .any()
    }

    func copyWeekPickerView(router: Router, delegate: CopyWeekPickerDelegate) -> AnyView {
        CopyWeekPickerSheet(
            viewModel: CopyWeekPickerViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func workoutPickerSheet(router: Router, delegate: WorkoutPickerSheetDelegate) -> AnyView {
        WorkoutPickerSheet(
            interactor: interactor,
            router: CoreRouter(router: router, builder: self),
            delegate: delegate
        )
        .any()
    }

    func trendSummarySection(delegate: TrendSummarySectionDelegate) -> AnyView {
        TrendSummarySection(
            viewModel: TrendSummarySectionViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func setTrackerRowView(router: Router, delegate: SetTrackerRowViewDelegate) -> AnyView {
        SetTrackerRowView(
            viewModel: SetTrackerRowViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate,
        )
        .any()
    }

    func setGoalFlowView(router: Router) -> AnyView {
        SetGoalFlowView(
            onboardingOverarchingObjectiveView: {
                self.onboardingOverarchingObjectiveView(router: router)
            }
        )
        .any()
    }

    func workoutNotesView(router: Router, delegate: WorkoutNotesViewDelegate) -> AnyView {
        WorkoutNotesView(
            viewModel: WorkoutNotesViewModel(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
        .any()
    }

    func profileView(router: Router) -> AnyView {
        ProfileView(
            viewModel: ProfileViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            profileHeaderView: {
                self.profileHeaderView(router: router)
            },
            profilePhysicalMetricsView: {
                self.profilePhysicalMetricsView(router: router)
            },
            profileGoalSection: {
                self.profileGoalSection(router: router)
            },
            profileNutritionPlanView: {
                self.profileNutritionPlanView(router: router)
            },
            profilePreferencesView: {
                self.profilePreferencesView(router: router)
            },
            profileMyTemplatesView: { 
                self.profileMyTemplatesView(router: router)
            }
        )
        .any()
    }

    func createAccountView(router: Router) -> AnyView {
        CreateAccountView(
            viewModel: CreateAccountViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func addExerciseModalView(router: Router, delegate: AddExerciseModalViewDelegate) -> AnyView {
        AddExerciseModalView(
            viewModel: AddExerciseModalViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func dayScheduleSheetView(router: Router, delegate: DayScheduleSheetViewDelegate) -> AnyView {
        DayScheduleSheetView(
            viewModel: DayScheduleSheetViewModel(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate,
            workoutSummaryCardView: { delegate in
                self.workoutSummaryCardView(delegate: delegate)
            },
            todaysWorkoutCardView: { delegate in
                self.todaysWorkoutCardView(delegate: delegate)
            }
        )
        .any()
    }

    func exerciseTrackerCardView(router: Router, delegate: ExerciseTrackerCardViewDelegate) -> AnyView {
        ExerciseTrackerCardView(
            delegate: delegate,
            interactor: interactor,
            setTrackerRowView: { delegate in
                self.setTrackerRowView(router: router, delegate: delegate)
            }
        )
        .any()
    }

    // swiftlint:disable:next file_length
}
