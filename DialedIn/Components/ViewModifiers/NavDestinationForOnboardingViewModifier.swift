//
//  NavDestinationForOnboardingViewModifier.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

import SwiftUI

struct NavDestinationForOnboardingViewModifier: ViewModifier {
    
    @Environment(DependencyContainer.self) private var container
    let path: Binding<[OnboardingPathOption]>
    
    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: OnboardingPathOption.self) { newValue in
                switch newValue {
                case OnboardingPathOption.intro:
                    OnboardingIntroView(
                        viewModel: OnboardingIntroViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ),
                        path: path
                    )
                case OnboardingPathOption.authOptions:
                    AuthOptionsView(
                        viewModel: AuthOptionsViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path
                    )
                case OnboardingPathOption.signIn:
                    SignInView(
                        viewModel: SignInViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path
                    )

                case OnboardingPathOption.signUp:
                    SignUpView(
                        viewModel: SignUpViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path
                    )
                case OnboardingPathOption.emailVerification:
                    EmailVerificationView(
                        viewModel: EmailVerificationViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path
                    )
                case OnboardingPathOption.subscriptionInfo:
                    OnboardingSubscriptionView(
                        viewModel: OnboardingSubscriptionViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path
                    )
                case OnboardingPathOption.subscriptionPlan:
                    OnboardingSubscriptionPlanView(
                        viewModel: OnboardingSubscriptionPlanViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path
                    )
                case OnboardingPathOption.completeAccount:
                    OnboardingCompleteAccountSetupView(
                        viewModel: OnboardingCompleteAccountSetupViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path
                    )
                case OnboardingPathOption.namePhoto:
                    OnboardingNamePhotoView(
                        viewModel: OnboardingNamePhotoViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path
                    )
                case OnboardingPathOption.gender:
                    OnboardingGenderView(
                        viewModel: OnboardingGenderViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path
                    )
                case OnboardingPathOption.dateOfBirth(userModelBuilder: let userModelBuilder):
                    OnboardingDateOfBirthView(
                        viewModel: OnboardingDateOfBirthViewModel(
                            interactor: CoreInteractor(
                                container: container
                            ),
                        ),
                        path: path,
                        userModelBuilder: userModelBuilder
                    )
                case OnboardingPathOption.height(userModelBuilder: let userModelBuilder):
                    OnboardingHeightView(
                        viewModel: OnboardingHeightViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path,
                        userModelBuilder: userModelBuilder
                    )
                case OnboardingPathOption.weight(userModelBuilder: let userModelBuilder):
                    OnboardingWeightView(
                        viewModel: OnboardingWeightViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path,
                        userModelBuilder: userModelBuilder
                    )
                case OnboardingPathOption.exerciseFrequency(userModelBuilder: let userModelBuilder):
                    OnboardingExerciseFrequencyView(
                        viewModel: OnboardingExerciseFrequencyViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path,
                        userModelBuilder: userModelBuilder
                    )
                case OnboardingPathOption.activityLevel(userModelBuilder: let userModelBuilder):
                    OnboardingActivityView(
                        viewModel: OnboardingActivityViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path,
                        userModelBuilder: userModelBuilder
                    )
                case OnboardingPathOption.cardioFitness(userModelBuilder: let userModelBuilder):
                    OnboardingCardioFitnessView(
                        viewModel: OnboardingCardioFitnessViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path,
                        userModelBuilder: userModelBuilder
                    )
                case OnboardingPathOption.expenditure(userModelBuilder: let userModelBuilder):
                    OnboardingExpenditureView(
                        viewModel: OnboardingExpenditureViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path,
                        userBuilder: userModelBuilder
                    )
                case OnboardingPathOption.healthData:
                    OnboardingHealthDataView(
                        viewModel: OnboardingHealthDataViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path
                    )
                case OnboardingPathOption.notifications:
                    OnboardingNotificationsView(
                        viewModel: OnboardingNotificationsViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path
                    )
                case OnboardingPathOption.healthDisclaimer:
                    OnboardingHealthDisclaimerView(
                        viewModel: OnboardingHealthDisclaimerViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path
                    )

                    // MARK: Goal Setting
                case OnboardingPathOption.goalSetting:
                    OnboardingGoalSettingView(
                        viewModel: OnboardingGoalSettingViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path
                    )
                case OnboardingPathOption.overarchingObjective:
                    OnboardingOverarchingObjectiveView(
                        viewModel: OnboardingOverarchingObjectiveViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path
                    )
                case OnboardingPathOption.targetWeight(weightGoalBuilder: let weightGoalBuilder):
                    OnboardingTargetWeightView(
                        viewModel: OnboardingTargetWeightViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path,
                        weightGoalBuilder: weightGoalBuilder
                    )
                case OnboardingPathOption.weightRate(weightGoalBuilder: let weightGoalBuilder):
                    OnboardingWeightRateView(
                        viewModel: OnboardingWeightRateViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path,
                        weightGoalBuilder: weightGoalBuilder
                    )
                case OnboardingPathOption.goalSummary(weightGoalBuilder: let weightGoalBuilder):
                    OnboardingGoalSummaryView(
                        viewModel: OnboardingGoalSummaryViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path,
                        weightGoalBuilder: weightGoalBuilder
                    )

                    // MARK: Customise Program
                case OnboardingPathOption.customiseProgram:
                    OnboardingCustomisingProgramView(
                        viewModel: OnboardingCustomisingProgramViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path
                    )
                case OnboardingPathOption.trainingExperience(trainingProgramBuilder: let builder):
                    OnboardingTrainingExperienceView(
                        viewModel: OnboardingTrainingExperienceViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ),
                        path: path,
                        trainingProgramBuilder: builder
                    )
                case OnboardingPathOption.trainingDaysPerWeek(trainingProgramBuilder: let builder):
                    OnboardingTrainingDaysPerWeekView(
                        viewModel: OnboardingTrainingDaysPerWeekViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ),
                        path: path,
                        trainingProgramBuilder: builder
                    )
                case OnboardingPathOption.trainingSplit(trainingProgramBuilder: let builder):
                    OnboardingTrainingSplitView(
                        viewModel: OnboardingTrainingSplitViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ),
                        path: path,
                        trainingProgramBuilder: builder
                    )
                case OnboardingPathOption.trainingSchedule(trainingProgramBuilder: let builder):
                    OnboardingTrainingScheduleView(
                        viewModel: OnboardingTrainingScheduleViewModel(
                            interactor: CoreInteractor(
                                container: container
                            ),
                            builder: builder
                        ),
                        path: path,
                        trainingProgramBuilder: builder
                    )
                case OnboardingPathOption.trainingEquipment(trainingProgramBuilder: let builder):
                    OnboardingTrainingEquipmentView(
                        viewModel: OnboardingTrainingEquipmentViewModel(
                            interactor: CoreInteractor(
                                container: container
                            ),
                            builder: builder
                        ),
                        path: path,
                        trainingProgramBuilder: builder
                    )
                case OnboardingPathOption.trainingReview(trainingProgramBuilder: let builder):
                    OnboardingTrainingReviewView(
                        viewModel: OnboardingTrainingReviewViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ),
                        path: path,
                        trainingProgramBuilder: builder
                    )
                case OnboardingPathOption.preferredDiet:
                    OnboardingPreferredDietView(
                        viewModel: OnboardingPreferredDietViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path
                    )
                case OnboardingPathOption.calorieFloor(dietPlanBuilder: let dietPlanBuilder):
                    OnboardingCalorieFloorView(
                        viewModel: OnboardingCalorieFloorViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path,
                        dietPlanBuilder: dietPlanBuilder
                    )
                case OnboardingPathOption.trainingType(dietPlanBuilder: let dietPlanBuilder):
                    OnboardingTrainingTypeView(
                        viewModel: OnboardingTrainingTypeViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path,
                        dietPlanBuilder: dietPlanBuilder
                    )
                case OnboardingPathOption.calorieDistribution(dietPlanBuilder: let dietPlanBuilder):
                    OnboardingCalorieDistributionView(
                        viewModel: OnboardingCalorieDistributionViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path,
                        dietPlanBuilder: dietPlanBuilder
                    )
                case OnboardingPathOption.proteinIntake(dietPlanBuilder: let dietPlanBuilder):
                    OnboardingProteinIntakeView(
                        viewModel: OnboardingProteinIntakeViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path,
                        dietPlanBuilder: dietPlanBuilder
                    )
                case OnboardingPathOption.dietPlan(dietPlanBuilder: let dietPlanBuilder):
                    OnboardingDietPlanView(
                        viewModel: OnboardingDietPlanViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path,
                        dietPlanBuilder: dietPlanBuilder
                    )
                case OnboardingPathOption.complete:
                    OnboardingCompletedView(
                        viewModel: OnboardingCompletedViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path
                    )
                }
            }
    }
}

extension View {
    
    func navigationDestinationOnboardingModule(path: Binding<[OnboardingPathOption]>) -> some View {
        modifier(NavDestinationForOnboardingViewModifier(path: path))
    }
}
