//
//  NavDestinationForOnboardingViewModifier.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

import SwiftUI

struct NavDestinationForOnboardingViewModifier: ViewModifier {

    @Environment(CoreBuilder.self) private var builder
    let path: Binding<[OnboardingPathOption]>
    
    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: OnboardingPathOption.self) { newValue in
                switch newValue {
                case OnboardingPathOption.intro:
                    builder.onboardingIntroView(
                        delegate: OnboardingIntroViewDelegate(
                            path: path
                        )
                    )
                case OnboardingPathOption.authOptions:
                    builder.onboardingAuthOptionsView(
                        delegate: AuthOptionsViewDelegate(
                            path: path
                        )
                    )
                case OnboardingPathOption.signIn:
                    builder.onboardingSignInView(
                        delegate: SignInViewDelegate(
                            path: path
                        )
                    )
                case OnboardingPathOption.signUp:
                    builder.onboardingSignUpView(
                        delegate: SignUpViewDelegate(
                            path: path
                        )
                    )
                case OnboardingPathOption.emailVerification:
                    builder.onboardingEmailVerificationView(
                        delegate: EmailVerificationViewDelegate(
                            path: path
                        )
                    )

                case OnboardingPathOption.subscriptionInfo:
                    builder.onboardingSubscriptionView(
                        delegate: OnboardingSubscriptionViewDelegate(
                            path: path
                        )
                    )
                case OnboardingPathOption.subscriptionPlan:
                    builder.onboardingSubscriptionPlanView(
                        delegate: OnboardingSubscriptionPlanViewDelegate(
                            path: path
                        )
                    )
                case OnboardingPathOption.completeAccount:
                    builder.onboardingCompleteAccountSetupView(
                        delegate: OnboardingCompleteAccountSetupViewDelegate(
                            path: path
                        )
                    )
                case OnboardingPathOption.namePhoto:
                    builder.onboardingNamePhotoView(
                        delegate: OnboardingNamePhotoViewDelegate(
                            path: path
                        )
                    )
                case OnboardingPathOption.gender:
                    builder.onboardingGenderView(
                        delegate: OnboardingGenderViewDelegate(
                            path: path
                        )
                    )
                case OnboardingPathOption.dateOfBirth(userModelBuilder: let userModelBuilder):
                    builder.onboardingDateOfBirthView(
                        delegate: OnboardingDateOfBirthViewDelegate(
                            path: path,
                            userModelBuilder: userModelBuilder
                        )
                    )
                case OnboardingPathOption.height(userModelBuilder: let userModelBuilder):
                    builder.onboardingHeightView(
                        delegate: OnboardingHeightViewDelegate(
                            path: path,
                            userModelBuilder: userModelBuilder
                        )
                    )
                case OnboardingPathOption.weight(userModelBuilder: let userModelBuilder):
                    builder.onboardingWeightView(
                        delegate: OnboardingWeightViewDelegate(
                            path: path,
                            userModelBuilder: userModelBuilder
                        )
                    )
                case OnboardingPathOption.exerciseFrequency(userModelBuilder: let userModelBuilder):
                    builder.onboardingExerciseFrequencyView(
                        delegate: OnboardingExerciseFrequencyViewDelegate(
                            path: path,
                            userModelBuilder: userModelBuilder
                        )
                    )
                case OnboardingPathOption.activityLevel(userModelBuilder: let userModelBuilder):
                    builder.onboardingActivityView(
                        delegate: OnboardingActivityViewDelegate(
                            path: path,
                            userModelBuilder: userModelBuilder
                        )
                    )
                case OnboardingPathOption.cardioFitness(userModelBuilder: let userModelBuilder):
                    builder.onboardingCardioFitnessView(
                        delegate: OnboardingCardioFitnessViewDelegate(
                            path: path, 
                            userModelBuilder: userModelBuilder
                        )
                    )
                case OnboardingPathOption.expenditure(userModelBuilder: let userModelBuilder):
                    builder.onboardingExpenditureView(
                        delegate: OnboardingExpenditureViewDelegate(
                            path: path, 
                            userBuilder: userModelBuilder
                        )
                    )
                case OnboardingPathOption.healthData:
                    builder.onboardingHealthDataView(
                        delegate: OnboardingHealthDataViewDelegate(
                            path: path
                        )
                    )
                case OnboardingPathOption.notifications:
                    builder.onboardingNotificationsView(
                        delegate: OnboardingNotificationsViewDelegate(
                            path: path
                        )
                    )
                case OnboardingPathOption.healthDisclaimer:
                    builder.onboardingHealthDisclaimerView(
                        delegate: OnboardingHealthDisclaimerViewDelegate(
                            path: path
                        )
                    )

                    // MARK: Goal Setting
                case OnboardingPathOption.goalSetting:
                    builder.onboardingGoalSettingView(
                        delegate: OnboardingGoalSettingViewDelegate(
                            path: path
                        )
                    )
                case OnboardingPathOption.overarchingObjective:
                    builder.onboardingOverarchingObjectiveView(
                        delegate: OnboardingOverarchingObjectiveViewDelegate(
                            path: path
                        )
                    )
                case OnboardingPathOption.targetWeight(weightGoalBuilder: let weightGoalBuilder):
                    builder.onboardingTargetWeightView(
                        delegate: OnboardingTargetWeightViewDelegate(
                            path: path,
                            weightGoalBuilder: weightGoalBuilder
                        )
                    )
                case OnboardingPathOption.weightRate(weightGoalBuilder: let weightGoalBuilder):
                    builder.onboardingWeightRateView(
                        delegate: OnboardingWeightRateViewDelegate(
                            path: path,
                            weightGoalBuilder: weightGoalBuilder
                        )
                    )
                case OnboardingPathOption.goalSummary(weightGoalBuilder: let weightGoalBuilder):
                    builder.onboardingGoalSummaryView(
                        delegate: OnboardingGoalSummaryViewDelegate(
                            path: path,
                            weightGoalBuilder: weightGoalBuilder
                        )
                    )

                    // MARK: Customise Program
                case OnboardingPathOption.customiseProgram:
                    builder.onboardingCustomisingProgramView(
                        delegate: OnboardingCustomisingProgramViewDelegate(
                            path: path
                        )
                    )
                case OnboardingPathOption.trainingExperience(trainingProgramBuilder: let trainingProgramBuilder):
                    builder.onboardingTrainingExperienceView(
                        delegate: OnboardingTrainingExperienceViewDelegate(
                            path: path,
                            trainingProgramBuilder: trainingProgramBuilder
                        )
                    )
                case OnboardingPathOption.trainingDaysPerWeek(trainingProgramBuilder: let trainingProgramBuilder):
                    builder.onboardingTrainingExperienceView(
                        delegate: OnboardingTrainingExperienceViewDelegate(
                            path: path,
                            trainingProgramBuilder: trainingProgramBuilder
                        )
                    )
                case OnboardingPathOption.trainingSplit(trainingProgramBuilder: let trainingProgramBuilder):
                    builder.onboardingTrainingSplitView(
                        delegate: OnboardingTrainingSplitViewDelegate(
                            path: path,
                            trainingProgramBuilder: trainingProgramBuilder
                        )
                    )
                case OnboardingPathOption.trainingSchedule(trainingProgramBuilder: let trainingProgramBuilder):
                    builder.onboardingTrainingScheduleView(
                        delegate: OnboardingTrainingScheduleViewDelegate(
                            path: path,
                            trainingProgramBuilder: trainingProgramBuilder
                        )
                    )
                case OnboardingPathOption.trainingEquipment(trainingProgramBuilder: let trainingProgramBuilder):
                    builder.onboardingTrainingEquipmentView(
                        delegate: OnboardingTrainingEquipmentViewDelegate(
                            path: path,
                            trainingProgramBuilder: trainingProgramBuilder
                        )
                    )
                case OnboardingPathOption.trainingReview(trainingProgramBuilder: let trainingProgramBuilder):
                    builder.onboardingTrainingReviewView(
                        delegate: OnboardingTrainingReviewViewDelegate(
                            path: path,
                            trainingProgramBuilder: trainingProgramBuilder
                        )
                    )
                case OnboardingPathOption.preferredDiet:
                    builder.onboardingPreferredDietView(
                        delegate: OnboardingPreferredDietViewDelegate(
                            path: path
                        )
                    )
                case OnboardingPathOption.calorieFloor(dietPlanBuilder: let dietPlanBuilder):
                    builder.onboardingCalorieFloorView(
                        delegate: OnboardingCalorieFloorViewDelegate(
                            path: path,
                            dietPlanBuilder: dietPlanBuilder
                        )
                    )
                case OnboardingPathOption.trainingType(dietPlanBuilder: let dietPlanBuilder):
                    builder.onboardingTrainingTypeView(
                        delegate: OnboardingTrainingTypeViewDelegate(
                            path: path,
                            dietPlanBuilder: dietPlanBuilder
                        )
                    )
                case OnboardingPathOption.calorieDistribution(dietPlanBuilder: let dietPlanBuilder):
                    builder.onboardingCalorieDistributionView(
                        delegate: OnboardingCalorieDistributionViewDelegate(
                            path: path,
                            dietPlanBuilder: dietPlanBuilder
                        )
                    )
                case OnboardingPathOption.proteinIntake(dietPlanBuilder: let dietPlanBuilder):
                    builder.onboardingProteinIntakeView(
                        delegate: OnboardingProteinIntakeViewDelegate(
                            path: path,
                            dietPlanBuilder: dietPlanBuilder
                        )
                    )
                case OnboardingPathOption.dietPlan(dietPlanBuilder: let dietPlanBuilder):
                    builder.onboardingDietPlanView(
                        delegate: OnboardingDietPlanViewDelegate(
                            path: path,
                            dietPlanBuilder: dietPlanBuilder
                        )
                    )
                case OnboardingPathOption.complete:
                    builder.onboardingCompletedView(
                        delegate: OnboardingCompletedViewDelegate(
                            path: path
                        ),
                        devSettingsView: {
                            builder.devSettingsView()
                        }
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
