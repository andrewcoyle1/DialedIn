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
                case OnboardingPathOption.dateOfBirth:
                    OnboardingDateOfBirthView(
                        viewModel: OnboardingDateOfBirthViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path
                    )
                case OnboardingPathOption.height:
                    OnboardingHeightView(
                        viewModel: OnboardingHeightViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path
                    )
                case OnboardingPathOption.weight:
                    OnboardingWeightView(
                        viewModel: OnboardingWeightViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path
                    )
                case OnboardingPathOption.exerciseFrequency:
                    OnboardingExerciseFrequencyView(
                        viewModel: OnboardingExerciseFrequencyViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path
                    )
                case OnboardingPathOption.activityLevel:
                    OnboardingActivityView(
                        viewModel: OnboardingActivityViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path
                    )
                case OnboardingPathOption.cardioFitness:
                    OnboardingCardioFitnessView(
                        viewModel: OnboardingCardioFitnessViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path
                    )
                case OnboardingPathOption.expenditure:
                    OnboardingExpenditureView(
                        viewModel: OnboardingExpenditureViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path
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
                case OnboardingPathOption.targetWeight:
                    OnboardingTargetWeightView(
                        viewModel: OnboardingTargetWeightViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path
                    )
                case OnboardingPathOption.weightRate:
                    OnboardingWeightRateView(
                        viewModel: OnboardingWeightRateViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path
                    )
                case OnboardingPathOption.goalSummary:
                    OnboardingGoalSummaryView(
                        viewModel: OnboardingGoalSummaryViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path
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
                case OnboardingPathOption.preferredDiet:
                    OnboardingPreferredDietView(
                        viewModel: OnboardingPreferredDietViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path
                    )
                case OnboardingPathOption.calorieFloor:
                    OnboardingCalorieFloorView(
                        viewModel: OnboardingCalorieFloorViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path
                    )
                case OnboardingPathOption.trainingType:
                    OnboardingTrainingTypeView(
                        viewModel: OnboardingTrainingTypeViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path
                    )
                case OnboardingPathOption.calorieDistribution:
                    OnboardingCalorieDistributionView(
                        viewModel: OnboardingCalorieDistributionViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path
                    )
                case OnboardingPathOption.proteinIntake:
                    OnboardingProteinIntakeView(
                        viewModel: OnboardingProteinIntakeViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        ), path: path
                    )
                case OnboardingPathOption.dietPlan:
                    OnboardingDietPlanView(
                        viewModel: OnboardingDietPlanViewModel(
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
