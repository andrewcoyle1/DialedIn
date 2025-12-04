//
//  CoreBuilder.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/11/2025.
//

import SwiftUI
import SwiftfulRouting

@MainActor
// swiftlint:disable:next type_body_length
struct CoreBuilder: Builder {

    let interactor: CoreInteractor

    init(interactor: CoreInteractor) {
        self.interactor = interactor
    }
    
    init(container: DependencyContainer) {
        self.interactor = CoreInteractor(container: container)
    }
    
    func build() -> AnyView {
        adaptiveMainView()
            .any()
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

    func exerciseTemplateDetailView(router: AnyRouter, delegate: ExerciseTemplateDetailDelegate) -> some View {
        ExerciseTemplateDetailView(
            presenter: ExerciseTemplateDetailPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }

    func tabViewAccessoryView(router: AnyRouter, delegate: TabViewAccessoryDelegate) -> some View {
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

    func workoutTrackerView(router: AnyRouter, delegate: WorkoutTrackerDelegate) -> some View {
        WorkoutTrackerView(
            presenter: WorkoutTrackerPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate,
            exerciseTrackerCardView: { delegate in
                self.exerciseTrackerCardView(router: router, delegate: delegate)
                    .any()
            }
        )
    }

    func ingredientDetailView(router: AnyRouter, delegate: IngredientDetailDelegate) -> some View {
        IngredientDetailView(
            presenter: IngredientDetailPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }

    func exerciseTemplateListView(router: AnyRouter, delegate: ExerciseTemplateListDelegate) -> some View {
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

    func workoutTemplateListView(router: AnyRouter) -> some View {
        WorkoutTemplateListView(
            presenter: WorkoutTemplateListPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }

    func workoutTemplateDetailView(router: AnyRouter, delegate: WorkoutTemplateDetailDelegate) -> some View {
        WorkoutTemplateDetailView(
            presenter: WorkoutTemplateDetailPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }

    func workoutSessionDetailView(router: AnyRouter, delegate: WorkoutSessionDetailDelegate) -> some View {
        WorkoutSessionDetailView(
            presenter: WorkoutSessionDetailPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate,
            editableExerciseCardWrapper: { delegate in
                self.editableExerciseCardWrapper(delegate: delegate)
                    .any()
            }
        )
    }
    
    func trainingProgressChartsView(router: AnyRouter) -> some View {
        TrainingProgressChartsView(
            presenter: TrainingProgressChartsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }

    func programView(router: AnyRouter) -> some View {
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

    func todaysWorkoutSectionView(router: AnyRouter) -> some View {
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
    
    func devSettingsView(router: AnyRouter) -> AnyView {
        DevSettingsView(
            presenter: DevSettingsPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        .any()
    }

    func workoutStartView(router: AnyRouter, delegate: WorkoutStartDelegate) -> some View {
        WorkoutStartView(
            presenter: WorkoutStartPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }

    func dashboardView(router: AnyRouter) -> some View {
        DashboardView(
            presenter: DashboardPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            nutritionTargetChartView: {
                self.nutritionTargetChartView()
                    .any()
            }
        )
    }

    func createIngredientView(router: AnyRouter) -> some View {
        CreateIngredientView(
            presenter: CreateIngredientPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }

    func addIngredientModalView(router: AnyRouter, delegate: AddIngredientModalDelegate) -> some View {
        AddIngredientModalView(
            presenter: AddIngredientModalPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }

    func createRecipeView(router: AnyRouter) -> some View {
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

    func recipeStartView(router: AnyRouter, delegate: RecipeStartDelegate) -> some View {
        RecipeStartView(
            presenter: RecipeStartPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }

    func mealLogView(router: AnyRouter, delegate: MealLogDelegate) -> some View {
        MealLogView(
            presenter: MealLogPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }

    func recipesView(router: AnyRouter, delegate: RecipesDelegate) -> some View {
        RecipesView(
            presenter: RecipesPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }

    func ingredientsView(router: AnyRouter, delegate: IngredientsDelegate) -> some View {
        IngredientsView(
            presenter: IngredientsPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }

    func nutritionView(router: AnyRouter) -> some View {
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

    func nutritionLibraryPickerView(router: AnyRouter, delegate: NutritionLibraryPickerDelegate) -> some View {
        NutritionLibraryPickerView(
            presenter: NutritionLibraryPickerPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }

    func addMealView(router: AnyRouter, delegate: AddMealDelegate) -> some View {
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

    func ingredientAmountView(router: AnyRouter, delegate: IngredientAmountDelegate) -> some View {
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

    func workoutsView(router: AnyRouter) -> some View {
        WorkoutsView(
            presenter: WorkoutsPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            workoutListViewBuilder: { delegate in
                self.workoutListViewBuilder(router: router, delegate: delegate)
            }
        )
    }

    func workoutHistoryView(router: AnyRouter) -> some View {
        WorkoutHistoryView(
            presenter: WorkoutHistoryPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
        )
    }

    func createWorkoutView(router: AnyRouter, delegate: CreateWorkoutDelegate) -> some View {
        CreateWorkoutView(
            presenter: CreateWorkoutPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }

    func createExerciseView(router: AnyRouter) -> some View {
        CreateExerciseView(
            presenter: CreateExercisePresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }

    func addGoalView(router: AnyRouter, delegate: AddGoalDelegate) -> some View {
        AddGoalView(
            presenter: AddGoalPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }

    func workoutSummaryCardView(router: AnyRouter, delegate: WorkoutSummaryCardDelegate) -> some View {
        WorkoutSummaryCardView(
            presenter: WorkoutSummaryCardPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }

    func todaysWorkoutCardView(router: AnyRouter, delegate: TodaysWorkoutCardDelegate) -> some View {
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

    func workoutCalendarView(router: AnyRouter) -> some View {
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

    func exercisesView(router: AnyRouter) -> some View {
        ExercisesView(
            presenter: ExercisesPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }

    func programManagementView(router: AnyRouter) -> some View {
        ProgramManagementView(
            presenter: ProgramManagementPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            programRowView: { delegate in
                self.programRowView(delegate: delegate)
                    .any()
            }
        )
    }
    
    func goalListSectionView(router: AnyRouter) -> some View {
        GoalListSectionView(
            presenter: GoalListSectionPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }

    func trainingView(router: AnyRouter) -> some View {
        TrainingView(
            presenter: TrainingPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            programView: {
                self.programView(router: router)
            }
        )
    }

    func progressDashboardView(router: AnyRouter) -> some View {
        ProgressDashboardView(
            presenter: ProgressDashboardPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }

    func strengthProgressView(router: AnyRouter) -> some View {
        StrengthProgressView(
            presenter: StrengthProgressPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }

    func workoutHeatmapView(router: AnyRouter) -> some View {
        WorkoutHeatmapView(
            presenter: WorkoutHeatmapPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }

    func notificationsView(router: AnyRouter) -> some View {
        NotificationsView(
            presenter: NotificationsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }

    func programGoalsView(router: AnyRouter, delegate: ProgramGoalsDelegate) -> some View {
        ProgramGoalsView(
            presenter: ProgramGoalsPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate,
            goalRow: { delegate in
                self.goalRow(delegate: delegate)
                    .any()
            }
        )
    }

    func programScheduleView(router: AnyRouter, delegate: ProgramScheduleDelegate) -> some View {
        ProgramScheduleView(
            presenter: ProgramSchedulePresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }

    func mealDetailView(router: AnyRouter, delegate: MealDetailDelegate) -> some View {
        MealDetailView(
            presenter: MealDetailPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }

    func profileGoalsDetailView(router: AnyRouter) -> some View {
        ProfileGoalsDetailView(
            presenter: ProfileGoalsDetailPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }

    func profileEditView(router: AnyRouter) -> some View {
        ProfileEditView(
            presenter: ProfileEditPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }

    func profileNutritionDetailView(router: AnyRouter) -> some View {
        ProfileNutritionDetailView(
            presenter: ProfileNutritionDetailPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }

    func profilePhysicalStatsView(router: AnyRouter) -> some View {
        ProfilePhysicalStatsView(
            presenter: ProfilePhysicalStatsPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }
    
    func workoutListViewBuilder(router: AnyRouter, delegate: WorkoutListDelegateBuilder) -> some View {
        WorkoutListViewBuilder(
            presenter: WorkoutListPresenterBuilder(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
    func settingsView(router: AnyRouter) -> some View {
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

    func ingredientTemplateListView(router: AnyRouter, delegate: IngredientTemplateListDelegate) -> some View {
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

    func programTemplatePickerView(router: AnyRouter) -> some View {
        ProgramTemplatePickerView(
            presenter: ProgramTemplatePickerPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }

    func editProgramView(router: AnyRouter, delegate: EditProgramDelegate) -> some View {
        EditProgramView(
            presenter: EditProgramPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
    
    func thisWeeksWorkoutsView(router: AnyRouter) -> some View {
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

    func logWeightView(router: AnyRouter) -> some View {
        LogWeightView(
            presenter: LogWeightPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }

    func profileHeaderView(router: AnyRouter) -> some View {
        ProfileHeaderView(
            presenter: ProfileHeaderPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }

    func profilePhysicalMetricsView(router: AnyRouter) -> some View {
        ProfilePhysicalMetricsView(
            presenter: ProfilePhysicalMetricsPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }

    func profileGoalSection(router: AnyRouter) -> some View {
        ProfileGoalSection(
            presenter: ProfileGoalSectionPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }

    func profileNutritionPlanView(router: AnyRouter) -> some View {
        ProfileNutritionPlanView(
            presenter: ProfileNutritionPlanPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }

    func profilePreferencesView(router: AnyRouter) -> some View {
        ProfilePreferencesView(
            presenter: ProfilePreferencesPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }

    func profileMyTemplatesView(router: AnyRouter) -> some View {
        ProfileMyTemplatesView(
            presenter: ProfileMyTemplatesPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }

    func recipeDetailView(router: AnyRouter, delegate: RecipeDetailDelegate) -> some View {
        RecipeDetailView(
            presenter: RecipeDetailPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }

    func recipeTemplateListView(router: AnyRouter, delegate: RecipeTemplateListDelegate) -> some View {
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

    func customProgramBuilderView(router: AnyRouter) -> some View {
        CustomProgramBuilderView(
            presenter: CustomProgramBuilderPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }

    func programPreviewView(router: AnyRouter, delegate: ProgramPreviewDelegate) -> some View {
        ProgramPreviewView(
            presenter: ProgramPreviewPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }

    func manageSubscriptionView(router: AnyRouter, delegate: ManageSubscriptionDelegate) -> some View {
        ManageSubscriptionView(
            presenter: ManageSubscriptionPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }

    func recipeAmountView(router: AnyRouter, delegate: RecipeAmountDelegate) -> some View {
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

    func programStartConfigView(router: AnyRouter, delegate: ProgramStartConfigDelegate) -> some View {
        ProgramStartConfigView(
            presenter: ProgramStartConfigPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func volumeChartsView(router: AnyRouter) -> some View {
         VolumeChartsView(
            presenter: VolumeChartsPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            trendSummarySection: { delegate in
                self.trendSummarySection(delegate: delegate)
                    .any()
            }
         )
    }

    func copyWeekPickerView(router: AnyRouter, delegate: CopyWeekPickerDelegate) -> some View {
        CopyWeekPickerView(
            presenter: CopyWeekPickerPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func workoutPickerSheet(router: AnyRouter, delegate: WorkoutPickerDelegate) -> some View {
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

    func workoutScheduleRowView(router: AnyRouter, delegate: WorkoutScheduleRowDelegate) -> some View {
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

    func setTrackerRowView(router: AnyRouter, delegate: SetTrackerRowDelegate) -> some View {
        SetTrackerRowView(
            presenter: SetTrackerRowPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate,
        )
        
    }

    func workoutNotesView(router: AnyRouter, delegate: WorkoutNotesDelegate) -> some View {
        WorkoutNotesView(
            presenter: WorkoutNotesPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
        
    }

    func profileView(router: AnyRouter) -> some View {
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

    func createAccountView(router: AnyRouter) -> some View {
        CreateAccountView(
            presenter: CreateAccountPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
        
    }

    func addExerciseModalView(router: AnyRouter, delegate: AddExerciseModalDelegate) -> some View {
        AddExerciseModalView(
            presenter: AddExerciseModalPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func dayScheduleSheetView(router: AnyRouter, delegate: DayScheduleDelegate) -> some View {
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

    func exerciseTrackerCardView(router: AnyRouter, delegate: ExerciseTrackerCardDelegate) -> some View {
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
