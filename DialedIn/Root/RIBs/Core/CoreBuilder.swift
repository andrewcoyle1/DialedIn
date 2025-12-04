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
class CoreBuilder: Buildable {

    let interactor: CoreInteractor

    init(container: DependencyContainer) {
        interactor = CoreInteractor(container: container)
    }

    func build() -> AnyView {
        adaptiveMainView()
            .any()
    }
    
    // MARK: Onboarding

    func onboardingWelcomeView(router: Router) -> some View {
        OnboardingWelcomeView(
            presenter: OnboardingWelcomePresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        
    }

    func onboardingIntroView(router: Router) -> some View {
        OnboardingIntroView(
            presenter: OnboardingIntroPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        
    }

    // MARK: Onboarding Auth

    func onboardingAuthOptionsView(router: Router) -> some View {
        AuthOptionsView(
            presenter: AuthOptionsPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        
    }

    func onboardingSignInView(router: Router) -> some View {
        SignInView(
            presenter: SignInPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        
    }

    func onboardingSignUpView(router: Router) -> some View {
        SignUpView(
            presenter: SignUpPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        
    }

    func onboardingEmailVerificationView(router: Router) -> some View {
        EmailVerificationView(
            presenter: EmailVerificationPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        
    }

    // MARK: Onboarding Subscriptions

    func onboardingSubscriptionView(router: Router) -> some View {
        OnboardingSubscriptionView(
            presenter: OnboardingSubscriptionPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        
    }

    func onboardingSubscriptionPlanView(router: Router) -> some View {
        OnboardingSubscriptionPlanView(
            presenter: OnboardingSubscriptionPlanPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        
    }

    func onboardingCompleteAccountSetupView(router: Router) -> some View {
        OnboardingCompleteAccountSetupView(
            presenter: OnboardingCompleteAccountSetupPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        
    }

    func onboardingNamePhotoView(router: Router) -> some View {
        OnboardingNamePhotoView(
            presenter: OnboardingNamePhotoPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        
    }

    func onboardingGenderView(router: Router) -> some View {
        OnboardingGenderView(
            presenter: OnboardingGenderPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        
    }

    func onboardingDateOfBirthView(router: Router, delegate: OnboardingDateOfBirthDelegate) -> some View {
        OnboardingDateOfBirthView(
            presenter: OnboardingDateOfBirthPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingHeightView(router: Router, delegate: OnboardingHeightDelegate) -> some View {
        OnboardingHeightView(
            presenter: OnboardingHeightPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingWeightView(router: Router, delegate: OnboardingWeightDelegate) -> some View {
        OnboardingWeightView(
            presenter: OnboardingWeightPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingExerciseFrequencyView(router: Router, delegate: OnboardingExerciseFrequencyDelegate) -> some View {
        OnboardingExerciseFrequencyView(
            presenter: OnboardingExerciseFrequencyPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingActivityView(router: Router, delegate: OnboardingActivityDelegate) -> some View {
        OnboardingActivityView(
            presenter: OnboardingActivityPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingCardioFitnessView(router: Router, delegate: OnboardingCardioFitnessDelegate) -> some View {
        OnboardingCardioFitnessView(
            presenter: OnboardingCardioFitnessPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingExpenditureView(router: Router, delegate: OnboardingExpenditureDelegate) -> some View {
        OnboardingExpenditureView(
            presenter: OnboardingExpenditurePresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingHealthDataView(router: Router) -> some View {
        OnboardingHealthDataView(
            presenter: OnboardingHealthDataPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        
    }

    func onboardingNotificationsView(router: Router) -> some View {
        OnboardingNotificationsView(
            presenter: OnboardingNotificationsPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        
    }

    func onboardingHealthDisclaimerView(router: Router) -> some View {
        OnboardingHealthDisclaimerView(
            presenter: OnboardingHealthDisclaimerPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        
    }

    // MARK: Onboarding Goal Setting

    func onboardingGoalSettingView(router: Router) -> some View {
        OnboardingGoalSettingView(
            presenter: OnboardingGoalSettingPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        
    }

    func onboardingOverarchingObjectiveView(router: Router) -> some View {
        OnboardingOverarchingObjectiveView(
            presenter: OnboardingOverarchingObjectivePresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        
    }

    func onboardingTargetWeightView(router: Router, delegate: OnboardingTargetWeightDelegate) -> some View {
        OnboardingTargetWeightView(
            presenter: OnboardingTargetWeightPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingWeightRateView(router: Router, delegate: OnboardingWeightRateDelegate) -> some View {
        OnboardingWeightRateView(
            presenter: OnboardingWeightRatePresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingGoalSummaryView(router: Router, delegate: OnboardingGoalSummaryDelegate) -> some View {
        OnboardingGoalSummaryView(
            presenter: OnboardingGoalSummaryPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    // MARK: Customise Program

    func onboardingTrainingProgramView(router: Router) -> some View {
        OnboardingTrainingProgramView(
            presenter: OnboardingTrainingProgramPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
        
    }

    func onboardingCustomisingProgramView(router: Router) -> some View {
        OnboardingCustomisingProgramView(
            presenter: OnboardingCustomisingProgramPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        
    }

    func onboardingTrainingExperienceView(router: Router, delegate: OnboardingTrainingExperienceDelegate) -> some View {
        OnboardingTrainingExperienceView(
            presenter: OnboardingTrainingExperiencePresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingTrainingDaysPerWeekView(router: Router, delegate: OnboardingTrainingDaysPerWeekDelegate) -> some View {
        OnboardingTrainingDaysPerWeekView(
            presenter: OnboardingTrainingDaysPerWeekPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingTrainingSplitView(router: Router, delegate: OnboardingTrainingSplitDelegate) -> some View {
        OnboardingTrainingSplitView(
            presenter: OnboardingTrainingSplitPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingTrainingScheduleView(router: Router, delegate: OnboardingTrainingScheduleDelegate) -> some View {
        OnboardingTrainingScheduleView(
            presenter: OnboardingTrainingSchedulePresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingTrainingEquipmentView(router: Router, delegate: OnboardingTrainingEquipmentDelegate) -> some View {
        OnboardingTrainingEquipmentView(
            presenter: OnboardingTrainingEquipmentPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingTrainingReviewView(router: Router, delegate: OnboardingTrainingReviewDelegate) -> some View {
        OnboardingTrainingReviewView(
            presenter: OnboardingTrainingReviewPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingPreferredDietView(router: Router) -> some View {
        OnboardingPreferredDietView(
            presenter: OnboardingPreferredDietPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        
    }

    func onboardingCalorieFloorView(router: Router, delegate: OnboardingCalorieFloorDelegate) -> some View {
        OnboardingCalorieFloorView(
            presenter: OnboardingCalorieFloorPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingTrainingTypeView(router: Router, delegate: OnboardingTrainingTypeDelegate) -> some View {
        OnboardingTrainingTypeView(
            presenter: OnboardingTrainingTypePresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingCalorieDistributionView(router: Router, delegate: OnboardingCalorieDistributionDelegate) -> some View {
        OnboardingCalorieDistributionView(
            presenter: OnboardingCalorieDistributionPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingProteinIntakeView(router: Router, delegate: OnboardingProteinIntakeDelegate) -> some View {
        OnboardingProteinIntakeView(
            presenter: OnboardingProteinIntakePresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingDietPlanView(router: Router, delegate: OnboardingDietPlanDelegate) -> some View {
        OnboardingDietPlanView(
            presenter: OnboardingDietPlanPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingCompletedView(router: Router) -> some View {
        OnboardingCompletedView(
            presenter: OnboardingCompletedPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        
    }

    // MARK: Main App
    func adaptiveMainView() -> some View {
        AdaptiveMainView(
            presenter: AdaptiveMainPresenter(interactor: interactor),
            tabBarView: {
                self.tabBarView()
                    .any()
            },
            splitViewContainer: {
                self.splitViewContainer()
                    .any()
            }
        )
    }
    
    func tabBarView() -> some View {
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
                RouterView { router in
                    self.tabViewAccessoryView(router: router, delegate: delegate)
                }
            }
        )
    }

    func splitViewContainer() -> some View {
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
                RouterView { router in
                    self.tabViewAccessoryView(router: router, delegate: accessoryDelegate)
                }
            }
        )
    }

    func exerciseTemplateDetailView(router: Router, delegate: ExerciseTemplateDetailDelegate) -> some View {
        ExerciseTemplateDetailView(
            presenter: ExerciseTemplateDetailPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }

    func tabViewAccessoryView(router: Router, delegate: TabViewAccessoryDelegate) -> some View {
        let coreRouter = CoreRouter(router: router, builder: self)
        return TabViewAccessoryView(
            presenter: TabViewAccessoryPresenter(interactor: interactor),
            delegate: delegate,
            onTap: {
                coreRouter.showWorkoutTrackerView(
                    delegate: WorkoutTrackerDelegate(workoutSession: delegate.active)
                )
            }
        )
    }

    func workoutTrackerView(router: Router, delegate: WorkoutTrackerDelegate) -> some View {
        WorkoutTrackerView(
            presenter: WorkoutTrackerPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate,
            exerciseTrackerCardView: { delegate in
                self.exerciseTrackerCardView(router: router, delegate: delegate)
                    .any()
            }
        )
    }

    func ingredientDetailView(router: Router, delegate: IngredientDetailDelegate) -> some View {
        IngredientDetailView(
            presenter: IngredientDetailPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }

    func exerciseTemplateListView(router: Router, delegate: ExerciseTemplateListDelegate) -> some View {
        ExerciseTemplateListView(
            presenter: ExerciseTemplateListPresenter.create(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                templateIds: delegate.templateIds
            ),
            delegate: delegate,
            genericTemplateListView: { presenter, configuration, supportsRefresh, templateIdsOverride in
                self.genericTemplateListView(
                    presenter: presenter,
                    configuration: configuration,
                    supportsRefresh: supportsRefresh,
                    templateIdsOverride: templateIdsOverride
                )
                .any()
            }
        )
    }

    func workoutTemplateListView(router: Router) -> some View {
        WorkoutTemplateListView(
            presenter: WorkoutTemplateListPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }

    func workoutTemplateDetailView(router: Router, delegate: WorkoutTemplateDetailDelegate) -> some View {
        WorkoutTemplateDetailView(
            presenter: WorkoutTemplateDetailPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }

    func workoutSessionDetailView(router: Router, delegate: WorkoutSessionDetailDelegate) -> some View {
        WorkoutSessionDetailView(
            presenter: WorkoutSessionDetailPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate,
            editableExerciseCardWrapper: { delegate in
                self.editableExerciseCardWrapper(delegate: delegate)
                    .any()
            }
        )
    }
    
    func trainingProgressChartsView(router: Router) -> some View {
        TrainingProgressChartsView(
            presenter: TrainingProgressChartsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }

    func programView(router: Router) -> some View {
        ProgramView(
            presenter: ProgramPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            todaysWorkoutSectionView: {
                self.todaysWorkoutSectionView(router: router)
            },
            workoutCalendarView: {
                self.workoutCalendarView(router: router)
            },
            thisWeeksWorkoutsView: {
                self.thisWeeksWorkoutsView(router: router)
            },
            goalListSectionView: {
                self.goalListSectionView(router: router)
            },
            trainingProgressChartsView: {
                self.trainingProgressChartsView(router: router)
            }
        )
    }

    func todaysWorkoutSectionView(router: Router) -> some View {
        TodaysWorkoutSectionView(
            presenter: TodaysWorkoutSectionPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            workoutSummaryCardView: { delegate in
                self.workoutSummaryCardView(router: router, delegate: delegate)
            },
            todaysWorkoutCardView: { delegate in
                self.todaysWorkoutCardView(router: router, delegate: delegate)
            }
        )
    }
    
    func devSettingsView(router: Router) -> some View {
        DevSettingsView(
            presenter: DevSettingsPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }

    func workoutStartView(router: Router, delegate: WorkoutStartDelegate) -> some View {
        WorkoutStartView(
            presenter: WorkoutStartPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }

    func dashboardView(router: Router) -> some View {
        DashboardView(
            presenter: DashboardPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            nutritionTargetChartView: {
                self.nutritionTargetChartView()
                    .any()
            }
        )
    }

    func createIngredientView(router: Router) -> some View {
        CreateIngredientView(
            presenter: CreateIngredientPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }

    func addIngredientModalView(router: Router, delegate: AddIngredientModalDelegate) -> some View {
        AddIngredientModalView(
            presenter: AddIngredientModalPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }

    func createRecipeView(router: Router) -> some View {
        CreateRecipeView(
            presenter: CreateRecipePresenter(
                interactor: interactor,
                router: CoreRouter(
                    router: router,
                    builder: self
                )
            )
        )
    }

    func recipeStartView(router: Router, delegate: RecipeStartDelegate) -> some View {
        RecipeStartView(
            presenter: RecipeStartPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }

    func mealLogView(router: Router, delegate: MealLogDelegate) -> some View {
        MealLogView(
            presenter: MealLogPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }

    func recipesView(router: Router, delegate: RecipesDelegate) -> some View {
        RecipesView(
            presenter: RecipesPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }

    func ingredientsView(router: Router, delegate: IngredientsDelegate) -> some View {
        IngredientsView(
            presenter: IngredientsPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }

    func nutritionView(router: Router) -> some View {
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
    }

    func nutritionLibraryPickerView(router: Router, delegate: NutritionLibraryPickerDelegate) -> some View {
        NutritionLibraryPickerView(
            presenter: NutritionLibraryPickerPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }

    func addMealView(router: Router, delegate: AddMealDelegate) -> some View {
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
    }

    func ingredientAmountView(router: Router, delegate: IngredientAmountDelegate) -> some View {
        IngredientAmountView(
            presenter: IngredientAmountPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }

    func nutritionTargetChartView() -> some View {
        NutritionTargetChartView(
            presenter: NutritionTargetChartPresenter(interactor: interactor)
        )
    }

    func workoutsView(router: Router) -> some View {
        WorkoutsView(
            presenter: WorkoutsPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            workoutListViewBuilder: { delegate in
                self.workoutListViewBuilder(router: router, delegate: delegate)
            }
        )
    }

    func workoutHistoryView(router: Router) -> some View {
        WorkoutHistoryView(
            presenter: WorkoutHistoryPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
        )
    }

    func createWorkoutView(router: Router, delegate: CreateWorkoutDelegate) -> some View {
        CreateWorkoutView(
            presenter: CreateWorkoutPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }

    func createExerciseView(router: Router) -> some View {
        CreateExerciseView(
            presenter: CreateExercisePresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }

    func addGoalView(router: Router, delegate: AddGoalDelegate) -> some View {
        AddGoalView(
            presenter: AddGoalPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }

    func workoutSummaryCardView(router: Router, delegate: WorkoutSummaryCardDelegate) -> some View {
        WorkoutSummaryCardView(
            presenter: WorkoutSummaryCardPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }

    func todaysWorkoutCardView(router: Router, delegate: TodaysWorkoutCardDelegate) -> some View {
        TodaysWorkoutCardView(
            presenter: TodaysWorkoutCardPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }

    func scheduledWorkoutRowView(delegate: ScheduledWorkoutRowDelegate) -> some View {
        ScheduledWorkoutRowView(
            presenter: ScheduledWorkoutRowPresenter(interactor: interactor),
            delegate: delegate
        )
    }

    func programRowView(delegate: ProgramRowDelegate) -> some View {
        ProgramRowView(
            presenter: ProgramRowPresenter(interactor: interactor),
            delegate: delegate
        )
    }

    func workoutCalendarView(router: Router) -> some View {
        WorkoutCalendarView(
            presenter: WorkoutCalendarPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            scheduleView: { delegate in
                self.scheduleView(delegate: delegate)
                    .any()
            }
        )
    }

    func editableExerciseCardWrapper(delegate: EditableExerciseCardWrapperDelegate) -> some View {
        EditableExerciseCardWrapper(
            delegate: delegate,
            interactor: interactor
        )
    }

    func exercisesView(router: Router) -> some View {
        ExercisesView(
            presenter: ExercisesPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }

    func programManagementView(router: Router) -> some View {
        ProgramManagementView(
            presenter: ProgramManagementPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            programRowView: { delegate in
                self.programRowView(delegate: delegate)
                    .any()
            }
        )
    }
    
    func goalListSectionView(router: Router) -> some View {
        GoalListSectionView(
            presenter: GoalListSectionPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }

    func trainingView(router: Router) -> some View {
        TrainingView(
            presenter: TrainingPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            programView: {
                self.programView(router: router)
            }
        )
    }

    func progressDashboardView(router: Router) -> some View {
        ProgressDashboardView(
            presenter: ProgressDashboardPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }

    func strengthProgressView(router: Router) -> some View {
        StrengthProgressView(
            presenter: StrengthProgressPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }

    func workoutHeatmapView(router: Router) -> some View {
        WorkoutHeatmapView(
            presenter: WorkoutHeatmapPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }

    func notificationsView(router: Router) -> some View {
        NotificationsView(
            presenter: NotificationsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }

    func programGoalsView(router: Router, delegate: ProgramGoalsDelegate) -> some View {
        ProgramGoalsView(
            presenter: ProgramGoalsPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate,
            goalRow: { delegate in
                self.goalRow(delegate: delegate)
                    .any()
            }
        )
    }

    func programScheduleView(router: Router, delegate: ProgramScheduleDelegate) -> some View {
        ProgramScheduleView(
            presenter: ProgramSchedulePresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }

    func mealDetailView(router: Router, delegate: MealDetailDelegate) -> some View {
        MealDetailView(
            presenter: MealDetailPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }

    func profileGoalsDetailView(router: Router) -> some View {
        ProfileGoalsDetailView(
            presenter: ProfileGoalsDetailPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }

    func profileEditView(router: Router) -> some View {
        ProfileEditView(
            presenter: ProfileEditPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }

    func profileNutritionDetailView(router: Router) -> some View {
        ProfileNutritionDetailView(
            presenter: ProfileNutritionDetailPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }

    func profilePhysicalStatsView(router: Router) -> some View {
        ProfilePhysicalStatsView(
            presenter: ProfilePhysicalStatsPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }
    
    func workoutListViewBuilder(router: Router, delegate: WorkoutListDelegateBuilder) -> some View {
        WorkoutListViewBuilder(
            presenter: WorkoutListPresenterBuilder(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
    func settingsView(router: Router) -> some View {
        SettingsView(
            presenter: SettingsPresenter(
                interactor: interactor,
                router: CoreRouter(
                    router: router,
                    builder: self
                )
            )
        )
    }

    func ingredientTemplateListView(router: Router, delegate: IngredientTemplateListDelegate) -> some View {
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
                .any()
            }
        )
    }

    func goalRow(delegate: GoalRowDelegate) -> some View {
        GoalRow(
            presenter: GoalRowPresenter(interactor: interactor),
            delegate: delegate
        )
    }

    func programTemplatePickerView(router: Router) -> some View {
        ProgramTemplatePickerView(
            presenter: ProgramTemplatePickerPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }

    func editProgramView(router: Router, delegate: EditProgramDelegate) -> some View {
        EditProgramView(
            presenter: EditProgramPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
    
    func thisWeeksWorkoutsView(router: Router) -> some View {
        ThisWeeksWorkoutsView(
            presenter: ThisWeeksWorkoutsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            workoutSummaryCardView: { delegate in
                self.workoutSummaryCardView(router: router, delegate: delegate)
            },
            scheduledWorkoutRowView: { delegate in
                self.scheduledWorkoutRowView(delegate: delegate)
            }
        )
    }

    func scheduleView(delegate: ScheduleDelegate) -> some View {
        ScheduleView(
            presenter: SchedulePresenter(interactor: interactor),
            delegate: delegate
        )
    }

    func logWeightView(router: Router) -> some View {
        LogWeightView(
            presenter: LogWeightPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }

    func profileHeaderView(router: Router) -> some View {
        ProfileHeaderView(
            presenter: ProfileHeaderPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }

    func profilePhysicalMetricsView(router: Router) -> some View {
        ProfilePhysicalMetricsView(
            presenter: ProfilePhysicalMetricsPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }

    func profileGoalSection(router: Router) -> some View {
        ProfileGoalSection(
            presenter: ProfileGoalSectionPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }

    func profileNutritionPlanView(router: Router) -> some View {
        ProfileNutritionPlanView(
            presenter: ProfileNutritionPlanPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }

    func profilePreferencesView(router: Router) -> some View {
        ProfilePreferencesView(
            presenter: ProfilePreferencesPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }

    func profileMyTemplatesView(router: Router) -> some View {
        ProfileMyTemplatesView(
            presenter: ProfileMyTemplatesPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }

    func recipeDetailView(router: Router, delegate: RecipeDetailDelegate) -> some View {
        RecipeDetailView(
            presenter: RecipeDetailPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }

    func recipeTemplateListView(router: Router, delegate: RecipeTemplateListDelegate) -> some View {
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
                .any()
            }
        )
    }

    // MARK: Generic Template List
    func genericTemplateListView<Template: TemplateModel>(
        presenter: GenericTemplateListPresenter<Template>,
        configuration: TemplateListConfiguration<Template>,
        supportsRefresh: Bool,
        templateIdsOverride: [String]?
    ) -> some View {
        GenericTemplateListView(
            presenter: presenter,
            configuration: configuration,
            supportsRefresh: supportsRefresh,
            templateIdsOverride: templateIdsOverride
        )
    }

    func customProgramBuilderView(router: Router) -> some View {
        CustomProgramBuilderView(
            presenter: CustomProgramBuilderPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }

    func programPreviewView(router: Router, delegate: ProgramPreviewDelegate) -> some View {
        ProgramPreviewView(
            presenter: ProgramPreviewPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }

    func manageSubscriptionView(router: Router, delegate: ManageSubscriptionDelegate) -> some View {
        ManageSubscriptionView(
            presenter: ManageSubscriptionPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }

    func recipeAmountView(router: Router, delegate: RecipeAmountDelegate) -> some View {
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
    }

    func programStartConfigView(router: Router, delegate: ProgramStartConfigDelegate) -> some View {
        ProgramStartConfigView(
            presenter: ProgramStartConfigPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func volumeChartsView(router: Router) -> some View {
         VolumeChartsView(
            presenter: VolumeChartsPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            trendSummarySection: { delegate in
                self.trendSummarySection(delegate: delegate)
                    .any()
            }
         )
    }

    func copyWeekPickerView(router: Router, delegate: CopyWeekPickerDelegate) -> some View {
        CopyWeekPickerView(
            presenter: CopyWeekPickerPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func workoutPickerSheet(router: Router, delegate: WorkoutPickerDelegate) -> some View {
        WorkoutPickerView(
            presenter: WorkoutPickerPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate,
            workoutListBuilderView: { delegate in
                self.workoutListViewBuilder(router: router, delegate: delegate)
            }
        )
    }

    func workoutScheduleRowView(router: Router, delegate: WorkoutScheduleRowDelegate) -> some View {
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
        
    }

    func trendSummarySection(delegate: TrendSummarySectionDelegate) -> some View {
        TrendSummarySection(
            presenter: TrendSummarySectionPresenter(interactor: interactor),
            delegate: delegate
        )
        
    }

    func setTrackerRowView(router: Router, delegate: SetTrackerRowDelegate) -> some View {
        SetTrackerRowView(
            presenter: SetTrackerRowPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate,
        )
        
    }

    func setGoalFlowView(router: Router) -> some View {
        SetGoalFlowView(
            onboardingOverarchingObjectiveView: {
                self.onboardingOverarchingObjectiveView(router: router)
                    .any()
            }
        )
        
    }

    func workoutNotesView(router: Router, delegate: WorkoutNotesDelegate) -> some View {
        WorkoutNotesView(
            presenter: WorkoutNotesPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
        
    }

    func profileView(router: Router) -> some View {
        ProfileView(
            presenter: ProfilePresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            profileHeaderView: {
                self.profileHeaderView(router: router)
                    .any()
            },
            profilePhysicalMetricsView: {
                self.profilePhysicalMetricsView(router: router)
                    .any()
            },
            profileGoalSection: {
                self.profileGoalSection(router: router)
                    .any()
            },
            profileNutritionPlanView: {
                self.profileNutritionPlanView(router: router)
                    .any()
            },
            profilePreferencesView: {
                self.profilePreferencesView(router: router)
                    .any()
            },
            profileMyTemplatesView: { 
                self.profileMyTemplatesView(router: router)
                    .any()
            }
        )
        
    }

    func createAccountView(router: Router) -> some View {
        CreateAccountView(
            presenter: CreateAccountPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        
    }

    func addExerciseModalView(router: Router, delegate: AddExerciseModalDelegate) -> some View {
        AddExerciseModalView(
            presenter: AddExerciseModalPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func dayScheduleSheetView(router: Router, delegate: DayScheduleDelegate) -> some View {
        DayScheduleSheetView(
            presenter: DayScheduleSheetPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate,
            workoutSummaryCardView: { delegate in
                self.workoutSummaryCardView(router: router, delegate: delegate)
                    .any()
            },
            todaysWorkoutCardView: { delegate in
                self.todaysWorkoutCardView(router: router, delegate: delegate)
                    .any()
            }
        )
    }

    func exerciseTrackerCardView(router: Router, delegate: ExerciseTrackerCardDelegate) -> some View {
        ExerciseTrackerCardView(
            delegate: delegate,
            interactor: interactor,
            setTrackerRowView: { delegate in
                self.setTrackerRowView(router: router, delegate: delegate)
                    .any()
            }
        )
    }

    // swiftlint:disable:next file_length
}
