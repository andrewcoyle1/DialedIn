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
            presenter: AppPresenter(interactor: interactor),
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
            presenter: OnboardingWelcomePresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func onboardingIntroView(router: Router) -> AnyView {
        OnboardingIntroView(
            presenter: OnboardingIntroPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    // MARK: Onboarding Auth

    func onboardingAuthOptionsView(router: Router) -> AnyView {
        AuthOptionsView(
            presenter: AuthOptionsPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func onboardingSignInView(router: Router) -> AnyView {
        SignInView(
            presenter: SignInPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func onboardingSignUpView(router: Router) -> AnyView {
        SignUpView(
            presenter: SignUpPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func onboardingEmailVerificationView(router: Router) -> AnyView {
        EmailVerificationView(
            presenter: EmailVerificationPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    // MARK: Onboarding Subscriptions

    func onboardingSubscriptionView(router: Router) -> AnyView {
        OnboardingSubscriptionView(
            presenter: OnboardingSubscriptionPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func onboardingSubscriptionPlanView(router: Router) -> AnyView {
        OnboardingSubscriptionPlanView(
            presenter: OnboardingSubscriptionPlanPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func onboardingCompleteAccountSetupView(router: Router) -> AnyView {
        OnboardingCompleteAccountSetupView(
            presenter: OnboardingCompleteAccountSetupPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func onboardingNamePhotoView(router: Router) -> AnyView {
        OnboardingNamePhotoView(
            presenter: OnboardingNamePhotoPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func onboardingGenderView(router: Router) -> AnyView {
        OnboardingGenderView(
            presenter: OnboardingGenderPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func onboardingDateOfBirthView(router: Router, delegate: OnboardingDateOfBirthDelegate) -> AnyView {
        OnboardingDateOfBirthView(
            presenter: OnboardingDateOfBirthPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingHeightView(router: Router, delegate: OnboardingHeightDelegate) -> AnyView {
        OnboardingHeightView(
            presenter: OnboardingHeightPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingWeightView(router: Router, delegate: OnboardingWeightDelegate) -> AnyView {
        OnboardingWeightView(
            presenter: OnboardingWeightPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingExerciseFrequencyView(router: Router, delegate: OnboardingExerciseFrequencyDelegate) -> AnyView {
        OnboardingExerciseFrequencyView(
            presenter: OnboardingExerciseFrequencyPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingActivityView(router: Router, delegate: OnboardingActivityDelegate) -> AnyView {
        OnboardingActivityView(
            presenter: OnboardingActivityPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingCardioFitnessView(router: Router, delegate: OnboardingCardioFitnessDelegate) -> AnyView {
        OnboardingCardioFitnessView(
            presenter: OnboardingCardioFitnessPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingExpenditureView(router: Router, delegate: OnboardingExpenditureDelegate) -> AnyView {
        OnboardingExpenditureView(
            presenter: OnboardingExpenditurePresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingHealthDataView(router: Router) -> AnyView {
        OnboardingHealthDataView(
            presenter: OnboardingHealthDataPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func onboardingNotificationsView(router: Router) -> AnyView {
        OnboardingNotificationsView(
            presenter: OnboardingNotificationsPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func onboardingHealthDisclaimerView(router: Router) -> AnyView {
        OnboardingHealthDisclaimerView(
            presenter: OnboardingHealthDisclaimerPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    // MARK: Onboarding Goal Setting

    func onboardingGoalSettingView(router: Router) -> AnyView {
        OnboardingGoalSettingView(
            presenter: OnboardingGoalSettingPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func onboardingOverarchingObjectiveView(router: Router) -> AnyView {
        OnboardingOverarchingObjectiveView(
            presenter: OnboardingOverarchingObjectivePresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func onboardingTargetWeightView(router: Router, delegate: OnboardingTargetWeightDelegate) -> AnyView {
        OnboardingTargetWeightView(
            presenter: OnboardingTargetWeightPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingWeightRateView(router: Router, delegate: OnboardingWeightRateDelegate) -> AnyView {
        OnboardingWeightRateView(
            presenter: OnboardingWeightRatePresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingGoalSummaryView(router: Router, delegate: OnboardingGoalSummaryDelegate) -> AnyView {
        OnboardingGoalSummaryView(
            presenter: OnboardingGoalSummaryPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    // MARK: Customise Program

    func onboardingTrainingProgramView(router: Router) -> AnyView {
        OnboardingTrainingProgramView(
            presenter: OnboardingTrainingProgramPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
        .any()
    }

    func onboardingCustomisingProgramView(router: Router) -> AnyView {
        OnboardingCustomisingProgramView(
            presenter: OnboardingCustomisingProgramPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func onboardingTrainingExperienceView(router: Router, delegate: OnboardingTrainingExperienceDelegate) -> AnyView {
        OnboardingTrainingExperienceView(
            presenter: OnboardingTrainingExperiencePresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingTrainingDaysPerWeekView(router: Router, delegate: OnboardingTrainingDaysPerWeekDelegate) -> AnyView {
        OnboardingTrainingDaysPerWeekView(
            presenter: OnboardingTrainingDaysPerWeekPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingTrainingSplitView(router: Router, delegate: OnboardingTrainingSplitDelegate) -> AnyView {
        OnboardingTrainingSplitView(
            presenter: OnboardingTrainingSplitPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingTrainingScheduleView(router: Router, delegate: OnboardingTrainingScheduleDelegate) -> AnyView {
        OnboardingTrainingScheduleView(
            presenter: OnboardingTrainingSchedulePresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingTrainingEquipmentView(router: Router, delegate: OnboardingTrainingEquipmentDelegate) -> AnyView {
        OnboardingTrainingEquipmentView(
            presenter: OnboardingTrainingEquipmentPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingTrainingReviewView(router: Router, delegate: OnboardingTrainingReviewDelegate) -> AnyView {
        OnboardingTrainingReviewView(
            presenter: OnboardingTrainingReviewPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingPreferredDietView(router: Router) -> AnyView {
        OnboardingPreferredDietView(
            presenter: OnboardingPreferredDietPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func onboardingCalorieFloorView(router: Router, delegate: OnboardingCalorieFloorDelegate) -> AnyView {
        OnboardingCalorieFloorView(
            presenter: OnboardingCalorieFloorPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingTrainingTypeView(router: Router, delegate: OnboardingTrainingTypeDelegate) -> AnyView {
        OnboardingTrainingTypeView(
            presenter: OnboardingTrainingTypePresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingCalorieDistributionView(router: Router, delegate: OnboardingCalorieDistributionDelegate) -> AnyView {
        OnboardingCalorieDistributionView(
            presenter: OnboardingCalorieDistributionPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingProteinIntakeView(router: Router, delegate: OnboardingProteinIntakeDelegate) -> AnyView {
        OnboardingProteinIntakeView(
            presenter: OnboardingProteinIntakePresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingDietPlanView(router: Router, delegate: OnboardingDietPlanDelegate) -> AnyView {
        OnboardingDietPlanView(
            presenter: OnboardingDietPlanPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func onboardingCompletedView(router: Router) -> AnyView {
        OnboardingCompletedView(
            presenter: OnboardingCompletedPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    // MARK: Main App
    func adaptiveMainView() -> AnyView {
        AdaptiveMainView(
            presenter: AdaptiveMainPresenter(interactor: interactor),
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
            presenter: TabBarPresenter(interactor: interactor),
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
            presenter: SplitViewContainerPresenter(interactor: interactor),
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

    func exerciseTemplateDetailView(router: Router, delegate: ExerciseTemplateDetailDelegate) -> AnyView {
        ExerciseTemplateDetailView(
            presenter: ExerciseTemplateDetailPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func tabViewAccessoryView(delegate: TabViewAccessoryDelegate) -> AnyView {
        TabViewAccessoryView(
            presenter: TabViewAccessoryPresenter(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func workoutTrackerView(router: Router, delegate: WorkoutTrackerDelegate) -> AnyView {
        WorkoutTrackerView(
            presenter: WorkoutTrackerPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate,
            exerciseTrackerCardView: { delegate in
                self.exerciseTrackerCardView(router: router, delegate: delegate)
            }
        )
        .any()
    }

    func ingredientDetailView(router: Router, delegate: IngredientDetailDelegate) -> AnyView {
        IngredientDetailView(
            presenter: IngredientDetailPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func exerciseTemplateListView(router: Router, delegate: ExerciseTemplateListDelegate) -> AnyView {
        ExerciseTemplateListView(
            presenter: ExerciseTemplateListPresenter.create(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate,
            genericTemplateListView: { presenter, configuration, supportsRefresh, templateIdsOverride in
                self.genericTemplateListView(
                    presenter: presenter,
                    configuration: configuration,
                    supportsRefresh: supportsRefresh,
                    templateIdsOverride: templateIdsOverride
                )
            }
        )
        .any()
    }

    func workoutTemplateListView(router: Router, delegate: WorkoutTemplateListDelegate) -> AnyView {
        WorkoutTemplateListView(
            presenter: WorkoutTemplateListPresenter.create(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate,
            genericTemplateListView: { presenter, configuration, supportsRefresh, templateIdsOverride in
                self.genericTemplateListView(
                    presenter: presenter,
                    configuration: configuration,
                    supportsRefresh: supportsRefresh,
                    templateIdsOverride: templateIdsOverride
                )
            }
        )
        .any()
    }

    func workoutTemplateDetailView(router: Router, delegate: WorkoutTemplateDetailDelegate) -> AnyView {
        WorkoutTemplateDetailView(
            presenter: WorkoutTemplateDetailPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func workoutSessionDetailView(router: Router, delegate: WorkoutSessionDetailDelegate) -> AnyView {
        WorkoutSessionDetailView(
            presenter: WorkoutSessionDetailPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate,
            editableExerciseCardWrapper: { delegate in
                self.editableExerciseCardWrapper(delegate: delegate)
            }
        )
        .any()
    }

    func programView(router: Router, delegate: ProgramDelegate) -> AnyView {
        ProgramView(
            presenter: ProgramPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate,
            workoutSummaryCardView: { delegate in
                self.workoutSummaryCardView(router: router, delegate: delegate)
            },
            todaysWorkoutCardView: { delegate in
                self.todaysWorkoutCardView(router: router, delegate: delegate)
            },
            workoutCalendarView: { delegate in
                self.workoutCalendarView(router: router, delegate: delegate)
            },
            scheduledWorkoutRowView: { delegate in
                self.scheduledWorkoutRowView(delegate: delegate)
            }
        )
        .any()
    }

    func devSettingsView(router: Router) -> AnyView {
        DevSettingsView(
            presenter: DevSettingsPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func workoutStartView(router: Router, delegate: WorkoutStartDelegate) -> AnyView {
        WorkoutStartView(
            presenter: WorkoutStartPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func dashboardView(router: Router) -> AnyView {
        DashboardView(
            presenter: DashboardPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            nutritionTargetChartView: { self.nutritionTargetChartView() }
        )
        .any()
    }

    func createIngredientView(router: Router) -> AnyView {
        CreateIngredientView(
            presenter: CreateIngredientPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func addIngredientModalView(router: Router, delegate: AddIngredientModalDelegate) -> AnyView {
        AddIngredientModalView(
            presenter: AddIngredientModalPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func createRecipeView(router: Router) -> AnyView {
        CreateRecipeView(
            presenter: CreateRecipePresenter(
                interactor: interactor,
                router: CoreRouter(
                    router: router,
                    builder: self
                )
            )
        )
        .any()
    }

    func recipeStartView(router: Router, delegate: RecipeStartDelegate) -> AnyView {
        RecipeStartView(
            presenter: RecipeStartPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
            .any()
    }

    func mealLogView(router: Router, delegate: MealLogDelegate) -> AnyView {
        MealLogView(
            presenter: MealLogPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func recipesView(router: Router, delegate: RecipesDelegate) -> AnyView {
        RecipesView(
            presenter: RecipesPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func ingredientsView(router: Router, delegate: IngredientsDelegate) -> AnyView {
        IngredientsView(
            presenter: IngredientsPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func nutritionView(router: Router) -> AnyView {
        NutritionView(
            presenter: NutritionPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
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

    func nutritionLibraryPickerView(router: Router, delegate: NutritionLibraryPickerDelegate) -> AnyView {
        NutritionLibraryPickerView(
            presenter: NutritionLibraryPickerPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func addMealView(router: Router, delegate: AddMealDelegate) -> AnyView {
        AddMealView(
            presenter: AddMealPresenter(
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

    func ingredientAmountView(router: Router, delegate: IngredientAmountDelegate) -> AnyView {
        IngredientAmountView(
            presenter: IngredientAmountPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
        .any()
    }

    func nutritionTargetChartView() -> AnyView {
        NutritionTargetChartView(
            presenter: NutritionTargetChartPresenter(interactor: interactor)
        )
        .any()
    }

    func workoutsView(router: Router, delegate: WorkoutsDelegate) -> AnyView {
        WorkoutsView(
            presenter: WorkoutsPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func workoutHistoryView(router: Router, delegate: WorkoutHistoryDelegate) -> AnyView {
        WorkoutHistoryView(
            presenter: WorkoutHistoryPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func createWorkoutView(router: Router, delegate: CreateWorkoutDelegate) -> AnyView {
        CreateWorkoutView(
            presenter: CreateWorkoutPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func createExerciseView(router: Router) -> AnyView {
        CreateExerciseView(
            presenter: CreateExercisePresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func addGoalView(router: Router, delegate: AddGoalDelegate) -> AnyView {
        AddGoalView(
            presenter: AddGoalPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func workoutSummaryCardView(router: Router, delegate: WorkoutSummaryCardDelegate) -> AnyView {
        WorkoutSummaryCardView(
            presenter: WorkoutSummaryCardPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
        .any()
    }

    func todaysWorkoutCardView(router: Router, delegate: TodaysWorkoutCardDelegate) -> AnyView {
        TodaysWorkoutCardView(
            presenter: TodaysWorkoutCardPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
        .any()
    }

    func scheduledWorkoutRowView(delegate: ScheduledWorkoutRowDelegate) -> AnyView {
        ScheduledWorkoutRowView(
            presenter: ScheduledWorkoutRowPresenter(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func programRowView(delegate: ProgramRowDelegate) -> AnyView {
        ProgramRowView(
            presenter: ProgramRowPresenter(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func workoutCalendarView(router: Router, delegate: WorkoutCalendarDelegate) -> AnyView {
        WorkoutCalendarView(
            presenter: WorkoutCalendarPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
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

    func exercisesView(router: Router, delegate: ExercisesDelegate) -> AnyView {
        ExercisesView(
            presenter: ExercisesPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func programManagementView(router: Router) -> AnyView {
        ProgramManagementView(
            presenter: ProgramManagementPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            programRowView: { delegate in
                self.programRowView(delegate: delegate)
            }
        )
        .any()
    }

    func trainingView(router: Router) -> AnyView {
        TrainingView(
            presenter: TrainingPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
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
            presenter: ProgressDashboardPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func strengthProgressView(router: Router) -> AnyView {
        StrengthProgressView(
            presenter: StrengthProgressPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func workoutHeatmapView(router: Router) -> AnyView {
        WorkoutHeatmapView(
            presenter: WorkoutHeatmapPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func notificationsView(router: Router) -> AnyView {
        NotificationsView(
            presenter: NotificationsPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func programGoalsView(router: Router, delegate: ProgramGoalsDelegate) -> AnyView {
        ProgramGoalsView(
            presenter: ProgramGoalsPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate,
            goalRow: { delegate in
                self.goalRow(delegate: delegate)
            }
        )
        .any()
    }

    func programScheduleView(router: Router, delegate: ProgramScheduleDelegate) -> AnyView {
        ProgramScheduleView(
            presenter: ProgramSchedulePresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func mealDetailView(router: Router, delegate: MealDetailDelegate) -> AnyView {
        MealDetailView(
            presenter: MealDetailPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func profileGoalsDetailView(router: Router) -> AnyView {
        ProfileGoalsDetailView(
            presenter: ProfileGoalsDetailPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func profileEditView(router: Router) -> AnyView {
        ProfileEditView(
            presenter: ProfileEditPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func profileNutritionDetailView(router: Router) -> AnyView {
        ProfileNutritionDetailView(
            presenter: ProfileNutritionDetailPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func profilePhysicalStatsView(router: Router) -> AnyView {
        ProfilePhysicalStatsView(
            presenter: ProfilePhysicalStatsPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func settingsView(router: Router) -> AnyView {
        SettingsView(
            presenter: SettingsPresenter(
                interactor: interactor,
                router: CoreRouter(
                    router: router,
                    builder: self
                )
            )
        )
        .any()
    }

    func ingredientTemplateListView(router: Router, delegate: IngredientTemplateListDelegate) -> AnyView {
        IngredientTemplateListView(
            interactor: interactor,
            router: CoreRouter(router: router, builder: self),
            delegate: delegate,
            genericTemplateListView: { presenter, configuration, supportsRefresh, templateIdsOverride in
                self.genericTemplateListView(
                    presenter: presenter,
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
            presenter: GoalRowPresenter(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func programTemplatePickerView(router: Router) -> AnyView {
        ProgramTemplatePickerView(
            presenter: ProgramTemplatePickerPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func editProgramView(router: Router, delegate: EditProgramDelegate) -> AnyView {
        EditProgramView(
            presenter: EditProgramPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func enhancedScheduleView(delegate: EnhancedScheduleDelegate) -> AnyView {
        EnhancedScheduleView(
            presenter: EnhancedSchedulePresenter(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func logWeightView(router: Router) -> AnyView {
        LogWeightView(
            presenter: LogWeightPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func profileHeaderView(router: Router) -> AnyView {
        ProfileHeaderView(
            presenter: ProfileHeaderPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func profilePhysicalMetricsView(router: Router) -> AnyView {
        ProfilePhysicalMetricsView(
            presenter: ProfilePhysicalMetricsPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func profileGoalSection(router: Router) -> AnyView {
        ProfileGoalSection(
            presenter: ProfileGoalSectionPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func profileNutritionPlanView(router: Router) -> AnyView {
        ProfileNutritionPlanView(
            presenter: ProfileNutritionPlanPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func profilePreferencesView(router: Router) -> AnyView {
        ProfilePreferencesView(
            presenter: ProfilePreferencesPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func profileMyTemplatesView(router: Router) -> AnyView {
        ProfileMyTemplatesView(
            presenter: ProfileMyTemplatesPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func recipeDetailView(router: Router, delegate: RecipeDetailDelegate) -> AnyView {
        RecipeDetailView(
            presenter: RecipeDetailPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func recipeTemplateListView(router: Router, delegate: RecipeTemplateListDelegate) -> AnyView {
        RecipeTemplateListView(
            interactor: interactor,
            router: CoreRouter(router: router, builder: self),
            delegate: delegate,
            genericTemplateListView: { presenter, configuration, supportsRefresh, templateIdsOverride in
                self.genericTemplateListView(
                    presenter: presenter,
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
        presenter: GenericTemplateListPresenter<Template>,
        configuration: TemplateListConfiguration<Template>,
        supportsRefresh: Bool,
        templateIdsOverride: [String]?
    ) -> AnyView {
        GenericTemplateListView(
            presenter: presenter,
            configuration: configuration,
            supportsRefresh: supportsRefresh,
            templateIdsOverride: templateIdsOverride
        )
        .any()
    }

    func customProgramBuilderView(router: Router) -> AnyView {
        CustomProgramBuilderView(
            presenter: CustomProgramBuilderPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func programPreviewView(router: Router, delegate: ProgramPreviewDelegate) -> AnyView {
        ProgramPreviewView(
            presenter: ProgramPreviewPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
        .any()
    }

    func manageSubscriptionView(router: Router, delegate: ManageSubscriptionDelegate) -> AnyView {
        ManageSubscriptionView(
            presenter: ManageSubscriptionPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
        .any()
    }

    func recipeAmountView(router: Router, delegate: RecipeAmountDelegate) -> AnyView {
        RecipeAmountView(
            presenter: RecipeAmountPresenter(
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

    func programStartConfigView(router: Router, delegate: ProgramStartConfigDelegate) -> AnyView {
        ProgramStartConfigView(
            presenter: ProgramStartConfigPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func volumeChartsView(router: Router) -> AnyView {
         VolumeChartsView(
            presenter: VolumeChartsPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            trendSummarySection: { delegate in
                self.trendSummarySection(delegate: delegate)
            }
         )
         .any()
    }

    func copyWeekPickerView(router: Router, delegate: CopyWeekPickerDelegate) -> AnyView {
        CopyWeekPickerView(
            presenter: CopyWeekPickerPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func workoutPickerSheet(router: Router, delegate: WorkoutPickerDelegate) -> AnyView {
        WorkoutPickerSheet(
            interactor: interactor,
            router: CoreRouter(router: router, builder: self),
            delegate: delegate
        )
        .any()
    }

    func workoutScheduleRowView(router: Router, delegate: WorkoutScheduleRowDelegate) -> AnyView {
        WorkoutScheduleRowView(
            presenter: WorkoutScheduleRowPresenter(
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

    func trendSummarySection(delegate: TrendSummarySectionDelegate) -> AnyView {
        TrendSummarySection(
            presenter: TrendSummarySectionPresenter(interactor: interactor),
            delegate: delegate
        )
        .any()
    }

    func setTrackerRowView(router: Router, delegate: SetTrackerRowDelegate) -> AnyView {
        SetTrackerRowView(
            presenter: SetTrackerRowPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
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

    func workoutNotesView(router: Router, delegate: WorkoutNotesDelegate) -> AnyView {
        WorkoutNotesView(
            presenter: WorkoutNotesPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
        .any()
    }

    func profileView(router: Router) -> AnyView {
        ProfileView(
            presenter: ProfilePresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
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
            presenter: CreateAccountPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func addExerciseModalView(router: Router, delegate: AddExerciseModalDelegate) -> AnyView {
        AddExerciseModalView(
            presenter: AddExerciseModalPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        .any()
    }

    func dayScheduleSheetView(router: Router, delegate: DayScheduleDelegate) -> AnyView {
        DayScheduleSheetView(
            presenter: DayScheduleSheetPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate,
            workoutSummaryCardView: { delegate in
                self.workoutSummaryCardView(router: router, delegate: delegate)
            },
            todaysWorkoutCardView: { delegate in
                self.todaysWorkoutCardView(router: router, delegate: delegate)
            }
        )
        .any()
    }

    func exerciseTrackerCardView(router: Router, delegate: ExerciseTrackerCardDelegate) -> AnyView {
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
