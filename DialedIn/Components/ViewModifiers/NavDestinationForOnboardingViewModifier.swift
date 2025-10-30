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
                case OnboardingPathOption.dateOfBirth(gender: let gender):
                    OnboardingDateOfBirthView(
                        viewModel: OnboardingDateOfBirthViewModel(
                            interactor: CoreInteractor(
                                container: container
                            ),
                            gender: gender
                        ), path: path
                    )
                case OnboardingPathOption.height(gender: let gender, dateOfBirth: let dateOfBirth):
                    OnboardingHeightView(
                        viewModel: OnboardingHeightViewModel(
                            interactor: CoreInteractor(
                                container: container
                            ),
                            gender: gender,
                            dateOfBirth: dateOfBirth
                        ), path: path
                    )
                case OnboardingPathOption
                        .weight(
                            gender: let gender,
                            dateOfBirth: let dateOfBirth,
                            height: let height,
                            lengthUnitPreference: let lengthUnitPreference
                        ):
                    OnboardingWeightView(
                        viewModel: OnboardingWeightViewModel(
                            interactor: CoreInteractor(
                                container: container
                            ),
                            gender: gender,
                            dateOfBirth: dateOfBirth,
                            height: height,
                            lengthUnitPreference: lengthUnitPreference
                        ), path: path
                    )
                case OnboardingPathOption
                        .exerciseFrequency(
                            gender: let gender,
                            dateOfBirth: let dateOfBirth,
                            height: let height,
                            weight: let weight,
                            lengthUnitPreference: let lengthUnitPreference,
                            weightUnitPreference: let weightUnitPreference
                        ):
                    OnboardingExerciseFrequencyView(
                        viewModel: OnboardingExerciseFrequencyViewModel(
                            interactor: CoreInteractor(
                                container: container
                            ),
                            gender: gender,
                            dateOfBirth: dateOfBirth,
                            height: height,
                            weight: weight,
                            lengthUnitPreference: lengthUnitPreference,
                            weightUnitPreference: weightUnitPreference
                        ), path: path
                    )
                case OnboardingPathOption
                        .activityLevel(
                            gender: let gender,
                            dateOfBirth: let dateOfBirth,
                            height: let height,
                            weight: let weight,
                            exerciseFrequency: let exerciseFrequency,
                            lengthUnitPreference: let lengthUnitPreference,
                            weightUnitPreference: let weightUnitPreference
                        ):
                    OnboardingActivityView(
                        viewModel: OnboardingActivityViewModel(
                            interactor: CoreInteractor(
                                container: container
                            ),
                            gender: gender,
                            dateOfBirth: dateOfBirth,
                            height: height,
                            weight: weight,
                            exerciseFrequency: exerciseFrequency,
                            lengthUnitPreference: lengthUnitPreference,
                            weightUnitPreference: weightUnitPreference
                        ), path: path
                    )
                case OnboardingPathOption.cardioFitness(
                    gender: let gender,
                    dateOfBirth: let dateOfBirth,
                    height: let height,
                    weight: let weight,
                    exerciseFrequency: let exerciseFrequency,
                    activityLevel: let activityLevel,
                    lengthUnitPreference: let lengthUnitPreference,
                    weightUnitPreference: let weightUnitPreference
                ):
                    OnboardingCardioFitnessView(
                        viewModel: OnboardingCardioFitnessViewModel(
                            interactor: CoreInteractor(
                                container: container
                            ),
                            gender: gender,
                            dateOfBirth: dateOfBirth,
                            height: height,
                            weight: weight,
                            exerciseFrequency: exerciseFrequency,
                            activityLevel: activityLevel,
                            lengthUnitPreference: lengthUnitPreference,
                            weightUnitPreference: weightUnitPreference
                        ), path: path
                    )
                case OnboardingPathOption.expenditure(
                    gender: let gender,
                    dateOfBirth: let dateOfBirth,
                    height: let height,
                    weight: let weight,
                    exerciseFrequency: let exerciseFrequency,
                    activityLevel: let activityLevel,
                    lengthUnitPreference: let lengthUnitPreference,
                    weightUnitPreference: let weightUnitPreference,
                    selectedCardioFitness: let selectedCardioFitness
                ):
                    OnboardingExpenditureView(
                        viewModel: OnboardingExpenditureViewModel(
                            interactor: CoreInteractor(
                                container: container
                            ),
                            gender: gender,
                            dateOfBirth: dateOfBirth,
                            height: height,
                            weight: weight,
                            exerciseFrequency: exerciseFrequency,
                            activityLevel: activityLevel,
                            lengthUnitPreference: lengthUnitPreference,
                            weightUnitPreference: weightUnitPreference,
                            selectedCardioFitness: selectedCardioFitness
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
                case OnboardingPathOption.targetWeight(objective: let objective):
                    OnboardingTargetWeightView(
                        viewModel: OnboardingTargetWeightViewModel(
                            interactor: CoreInteractor(
                                container: container
                            ),
                            objective: objective
                        ), path: path
                    )
                case OnboardingPathOption.weightRate(
                            objective: let objective,
                            targetWeight: let targetWeight
                        ):
                    OnboardingWeightRateView(
                        viewModel: OnboardingWeightRateViewModel(
                            interactor: CoreInteractor(
                                container: container
                            ),
                            objective: objective,
                            targetWeight: targetWeight,
                            isStandaloneMode: false
                        ), path: path
                    )
                case OnboardingPathOption.goalSummary(
                            objective: let objective,
                            targetWeight: let targetWeight,
                            weightRate: let weightRate
                        ):
                    OnboardingGoalSummaryView(
                        viewModel: OnboardingGoalSummaryViewModel(
                            interactor: CoreInteractor(
                                container: container
                            ),
                            objective: objective,
                            targetWeight: targetWeight,
                            weightRate: weightRate
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
                case OnboardingPathOption.calorieFloor(
                            preferredDiet: let preferredDiet
                        ):
                    OnboardingCalorieFloorView(
                        viewModel: OnboardingCalorieFloorViewModel(
                            interactor: CoreInteractor(
                                container: container
                            ),
                            preferredDiet: preferredDiet
                        ), path: path
                    )
                case OnboardingPathOption.trainingType(
                            preferredDiet: let preferredDiet,
                            calorieFloor: let calorieFloor
                        ):
                    OnboardingTrainingTypeView(
                        viewModel: OnboardingTrainingTypeViewModel(
                            interactor: CoreInteractor(
                                container: container
                            ),
                            preferredDiet: preferredDiet,
                            calorieFloor: calorieFloor
                        ), path: path
                    )
                case OnboardingPathOption.calorieDistribution(
                            preferredDiet: let preferredDiet,
                            calorieFloor: let calorieFloor,
                            trainingType: let trainingType
                        ):
                    OnboardingCalorieDistributionView(
                        viewModel: OnboardingCalorieDistributionViewModel(
                            interactor: CoreInteractor(
                                container: container
                            ),
                            preferredDiet: preferredDiet,
                            calorieFloor: calorieFloor,
                            trainingType: trainingType
                        ), path: path
                    )
                case OnboardingPathOption.proteinIntake(
                            preferredDiet: let preferredDiet,
                            calorieFloor: let calorieFloor,
                            trainingType: let trainingType,
                            calorieDistribution: let calorieDistribution
                        ):
                    OnboardingProteinIntakeView(
                        viewModel: OnboardingProteinIntakeViewModel(
                            interactor: CoreInteractor(
                                container: container
                            ),
                            preferredDiet: preferredDiet,
                            calorieFloor: calorieFloor,
                            trainingType: trainingType,
                            calorieDistribution: calorieDistribution
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
