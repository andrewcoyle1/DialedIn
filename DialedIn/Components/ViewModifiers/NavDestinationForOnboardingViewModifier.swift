//
//  NavDestinationForOnboardingViewModifier.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

import SwiftUI

struct NavDestinationForOnboardingViewModifier: ViewModifier {

    let path: Binding<[OnboardingPathOption]>

    @ViewBuilder var onboardingIntroView: () -> AnyView
    @ViewBuilder var onboardingAuthOptionsView: (AuthOptionsViewDelegate) -> AnyView
    @ViewBuilder var onboardingSignInView: (SignInViewDelegate) -> AnyView
    @ViewBuilder var onboardingSignUpView: (SignUpViewDelegate) -> AnyView
    @ViewBuilder var onboardingEmailVerificationView: (EmailVerificationViewDelegate) -> AnyView
    @ViewBuilder var onboardingSubscriptionView: (OnboardingSubscriptionViewDelegate) -> AnyView
    @ViewBuilder var onboardingSubscriptionPlanView: (OnboardingSubscriptionPlanViewDelegate) -> AnyView
    @ViewBuilder var onboardingCompleteAccountSetupView: (OnboardingCompleteAccountSetupViewDelegate) -> AnyView
    @ViewBuilder var onboardingNamePhotoView: (OnboardingNamePhotoViewDelegate) -> AnyView
    @ViewBuilder var onboardingGenderView: (OnboardingGenderViewDelegate) -> AnyView
    @ViewBuilder var onboardingDateOfBirthView: (OnboardingDateOfBirthViewDelegate) -> AnyView
    @ViewBuilder var onboardingHeightView: (OnboardingHeightViewDelegate) -> AnyView
    @ViewBuilder var onboardingWeightView: (OnboardingWeightViewDelegate) -> AnyView
    @ViewBuilder var onboardingExerciseFrequencyView: (OnboardingExerciseFrequencyViewDelegate) -> AnyView
    @ViewBuilder var onboardingActivityView: (OnboardingActivityViewDelegate) -> AnyView
    @ViewBuilder var onboardingCardioFitnessView: (OnboardingCardioFitnessViewDelegate) -> AnyView
    @ViewBuilder var onboardingExpenditureView: (OnboardingExpenditureViewDelegate) -> AnyView
    @ViewBuilder var onboardingHealthDataView: (OnboardingHealthDataViewDelegate) -> AnyView
    @ViewBuilder var onboardingNotificationsView: (OnboardingNotificationsViewDelegate) -> AnyView
    @ViewBuilder var onboardingHealthDisclaimerView: (OnboardingHealthDisclaimerViewDelegate) -> AnyView
    @ViewBuilder var onboardingGoalSettingView: (OnboardingGoalSettingViewDelegate) -> AnyView
    @ViewBuilder var onboardingOverarchingObjectiveView: (OnboardingOverarchingObjectiveViewDelegate) -> AnyView
    @ViewBuilder var onboardingTargetWeightView: (OnboardingTargetWeightViewDelegate) -> AnyView
    @ViewBuilder var onboardingWeightRateView: (OnboardingWeightRateViewDelegate) -> AnyView
    @ViewBuilder var onboardingGoalSummaryView: (OnboardingGoalSummaryViewDelegate) -> AnyView
    @ViewBuilder var onboardingCustomisingProgramView: (OnboardingCustomisingProgramViewDelegate) -> AnyView
    @ViewBuilder var onboardingTrainingExperienceView: (OnboardingTrainingExperienceViewDelegate) -> AnyView
    @ViewBuilder var onboardingTrainingDaysPerWeekView: (OnboardingTrainingDaysPerWeekViewDelegate) -> AnyView
    @ViewBuilder var onboardingTrainingSplitView: (OnboardingTrainingSplitViewDelegate) -> AnyView
    @ViewBuilder var onboardingTrainingScheduleView: (OnboardingTrainingScheduleViewDelegate) -> AnyView
    @ViewBuilder var onboardingTrainingEquipmentView: (OnboardingTrainingEquipmentViewDelegate) -> AnyView
    @ViewBuilder var onboardingTrainingReviewView: (OnboardingTrainingReviewViewDelegate) -> AnyView
    @ViewBuilder var onboardingPreferredDietView: (OnboardingPreferredDietViewDelegate) -> AnyView
    @ViewBuilder var onboardingCalorieFloorView: (OnboardingCalorieFloorViewDelegate) -> AnyView
    @ViewBuilder var onboardingTrainingTypeView: (OnboardingTrainingTypeViewDelegate) -> AnyView
    @ViewBuilder var onboardingCalorieDistributionView: (OnboardingCalorieDistributionViewDelegate) -> AnyView
    @ViewBuilder var onboardingProteinIntakeView: (OnboardingProteinIntakeViewDelegate) -> AnyView
    @ViewBuilder var onboardingDietPlanView: (OnboardingDietPlanViewDelegate) -> AnyView
    @ViewBuilder var onboardingCompletedView: (OnboardingCompletedViewDelegate) -> AnyView

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: OnboardingPathOption.self) { newValue in
                switch newValue {
                case OnboardingPathOption.intro:
                    onboardingIntroView()
                case OnboardingPathOption.authOptions:
                    onboardingAuthOptionsView(AuthOptionsViewDelegate(path: path))
                case OnboardingPathOption.signIn:
                    onboardingSignInView(SignInViewDelegate(path: path))
                case OnboardingPathOption.signUp:
                    onboardingSignUpView(SignUpViewDelegate(path: path))
                case OnboardingPathOption.emailVerification:
                    onboardingEmailVerificationView(EmailVerificationViewDelegate(path: path))
                case OnboardingPathOption.subscriptionInfo:
                    onboardingSubscriptionView(OnboardingSubscriptionViewDelegate(path: path))
                case OnboardingPathOption.subscriptionPlan:
                    onboardingSubscriptionPlanView(OnboardingSubscriptionPlanViewDelegate(path: path))
                case OnboardingPathOption.completeAccount:
                    onboardingCompleteAccountSetupView(OnboardingCompleteAccountSetupViewDelegate(path: path))
                case OnboardingPathOption.namePhoto:
                    onboardingNamePhotoView(OnboardingNamePhotoViewDelegate(path: path))
                case OnboardingPathOption.gender:
                    onboardingGenderView(OnboardingGenderViewDelegate(path: path))
                case OnboardingPathOption.dateOfBirth(userModelBuilder: let userModelBuilder):
                    onboardingDateOfBirthView(OnboardingDateOfBirthViewDelegate(path: path, userModelBuilder: userModelBuilder))
                case OnboardingPathOption.height(userModelBuilder: let userModelBuilder):
                    onboardingHeightView(OnboardingHeightViewDelegate(path: path, userModelBuilder: userModelBuilder))
                case OnboardingPathOption.weight(userModelBuilder: let userModelBuilder):
                    onboardingWeightView(OnboardingWeightViewDelegate(path: path, userModelBuilder: userModelBuilder))
                case OnboardingPathOption.exerciseFrequency(userModelBuilder: let userModelBuilder):
                    onboardingExerciseFrequencyView(OnboardingExerciseFrequencyViewDelegate(path: path, userModelBuilder: userModelBuilder))
                case OnboardingPathOption.activityLevel(userModelBuilder: let userModelBuilder):
                    onboardingActivityView(OnboardingActivityViewDelegate(path: path, userModelBuilder: userModelBuilder))
                case OnboardingPathOption.cardioFitness(userModelBuilder: let userModelBuilder):
                    onboardingCardioFitnessView(OnboardingCardioFitnessViewDelegate(path: path, userModelBuilder: userModelBuilder))
                case OnboardingPathOption.expenditure(userModelBuilder: let userModelBuilder):
                    onboardingExpenditureView(OnboardingExpenditureViewDelegate(path: path, userBuilder: userModelBuilder))
                case OnboardingPathOption.healthData:
                    onboardingHealthDataView(OnboardingHealthDataViewDelegate(path: path))
                case OnboardingPathOption.notifications:
                    onboardingNotificationsView(OnboardingNotificationsViewDelegate(path: path))
                case OnboardingPathOption.healthDisclaimer:
                    onboardingHealthDisclaimerView(OnboardingHealthDisclaimerViewDelegate(path: path))

                    // MARK: Goal Setting
                case OnboardingPathOption.goalSetting:
                    onboardingGoalSettingView(OnboardingGoalSettingViewDelegate(path: path))
                case OnboardingPathOption.overarchingObjective:
                    onboardingOverarchingObjectiveView(OnboardingOverarchingObjectiveViewDelegate(path: path))
                case OnboardingPathOption.targetWeight(weightGoalBuilder: let weightGoalBuilder):
                    onboardingTargetWeightView(OnboardingTargetWeightViewDelegate(path: path, weightGoalBuilder: weightGoalBuilder))
                case OnboardingPathOption.weightRate(weightGoalBuilder: let weightGoalBuilder):
                    onboardingWeightRateView(OnboardingWeightRateViewDelegate(path: path, weightGoalBuilder: weightGoalBuilder))
                case OnboardingPathOption.goalSummary(weightGoalBuilder: let weightGoalBuilder):
                    onboardingGoalSummaryView(OnboardingGoalSummaryViewDelegate(path: path, weightGoalBuilder: weightGoalBuilder))

                    // MARK: Customise Program
                case OnboardingPathOption.customiseProgram:
                    onboardingCustomisingProgramView(OnboardingCustomisingProgramViewDelegate(path: path))
                case OnboardingPathOption.trainingExperience(trainingProgramBuilder: let trainingProgramBuilder):
                    onboardingTrainingExperienceView(OnboardingTrainingExperienceViewDelegate(path: path, trainingProgramBuilder: trainingProgramBuilder))
                case OnboardingPathOption.trainingDaysPerWeek(trainingProgramBuilder: let trainingProgramBuilder):
                    onboardingTrainingDaysPerWeekView(OnboardingTrainingDaysPerWeekViewDelegate(path: path, trainingProgramBuilder: trainingProgramBuilder))
                case OnboardingPathOption.trainingSplit(trainingProgramBuilder: let trainingProgramBuilder):
                    onboardingTrainingSplitView(OnboardingTrainingSplitViewDelegate(path: path, trainingProgramBuilder: trainingProgramBuilder))
                case OnboardingPathOption.trainingSchedule(trainingProgramBuilder: let trainingProgramBuilder):
                    onboardingTrainingScheduleView(OnboardingTrainingScheduleViewDelegate(path: path, trainingProgramBuilder: trainingProgramBuilder))
                case OnboardingPathOption.trainingEquipment(trainingProgramBuilder: let trainingProgramBuilder):
                    onboardingTrainingEquipmentView(OnboardingTrainingEquipmentViewDelegate(path: path, trainingProgramBuilder: trainingProgramBuilder))
                case OnboardingPathOption.trainingReview(trainingProgramBuilder: let trainingProgramBuilder):
                    onboardingTrainingReviewView(OnboardingTrainingReviewViewDelegate(path: path, trainingProgramBuilder: trainingProgramBuilder))
                case OnboardingPathOption.preferredDiet:
                    onboardingPreferredDietView(OnboardingPreferredDietViewDelegate(path: path))
                case OnboardingPathOption.calorieFloor(dietPlanBuilder: let dietPlanBuilder):
                    onboardingCalorieFloorView(OnboardingCalorieFloorViewDelegate(path: path, dietPlanBuilder: dietPlanBuilder))
                case OnboardingPathOption.trainingType(dietPlanBuilder: let dietPlanBuilder):
                    onboardingTrainingTypeView(OnboardingTrainingTypeViewDelegate(path: path, dietPlanBuilder: dietPlanBuilder))
                case OnboardingPathOption.calorieDistribution(dietPlanBuilder: let dietPlanBuilder):
                    onboardingCalorieDistributionView(OnboardingCalorieDistributionViewDelegate(path: path, dietPlanBuilder: dietPlanBuilder))
                case OnboardingPathOption.proteinIntake(dietPlanBuilder: let dietPlanBuilder):
                    onboardingProteinIntakeView(OnboardingProteinIntakeViewDelegate(path: path, dietPlanBuilder: dietPlanBuilder))
                case OnboardingPathOption.dietPlan(dietPlanBuilder: let dietPlanBuilder):
                    onboardingDietPlanView(OnboardingDietPlanViewDelegate(path: path, dietPlanBuilder: dietPlanBuilder))
                case OnboardingPathOption.complete:
                    onboardingCompletedView(OnboardingCompletedViewDelegate(path: path))
                }
            }
    }
}

extension View {

    // swiftlint:disable:next function_parameter_count
    func navigationDestinationOnboardingModule(
        path: Binding<[OnboardingPathOption]>,
        @ViewBuilder onboardingIntroView: @escaping () -> AnyView,
        @ViewBuilder onboardingAuthOptionsView: @escaping (AuthOptionsViewDelegate) -> AnyView,
        @ViewBuilder onboardingSignInView: @escaping (SignInViewDelegate) -> AnyView,
        @ViewBuilder onboardingSignUpView: @escaping (SignUpViewDelegate) -> AnyView,
        @ViewBuilder onboardingEmailVerificationView: @escaping (EmailVerificationViewDelegate) -> AnyView,
        @ViewBuilder onboardingSubscriptionView: @escaping (OnboardingSubscriptionViewDelegate) -> AnyView,
        @ViewBuilder onboardingSubscriptionPlanView: @escaping (OnboardingSubscriptionPlanViewDelegate) -> AnyView,
        @ViewBuilder onboardingCompleteAccountSetupView: @escaping (OnboardingCompleteAccountSetupViewDelegate) -> AnyView,
        @ViewBuilder onboardingNamePhotoView: @escaping (OnboardingNamePhotoViewDelegate) -> AnyView,
        @ViewBuilder onboardingGenderView: @escaping (OnboardingGenderViewDelegate) -> AnyView,
        @ViewBuilder onboardingDateOfBirthView: @escaping (OnboardingDateOfBirthViewDelegate) -> AnyView,
        @ViewBuilder onboardingHeightView: @escaping (OnboardingHeightViewDelegate) -> AnyView,
        @ViewBuilder onboardingWeightView: @escaping (OnboardingWeightViewDelegate) -> AnyView,
        @ViewBuilder onboardingExerciseFrequencyView: @escaping (OnboardingExerciseFrequencyViewDelegate) -> AnyView,
        @ViewBuilder onboardingActivityView: @escaping (OnboardingActivityViewDelegate) -> AnyView,
        @ViewBuilder onboardingCardioFitnessView: @escaping (OnboardingCardioFitnessViewDelegate) -> AnyView,
        @ViewBuilder onboardingExpenditureView: @escaping (OnboardingExpenditureViewDelegate) -> AnyView,
        @ViewBuilder onboardingHealthDataView: @escaping (OnboardingHealthDataViewDelegate) -> AnyView,
        @ViewBuilder onboardingNotificationsView: @escaping (OnboardingNotificationsViewDelegate) -> AnyView,
        @ViewBuilder onboardingHealthDisclaimerView: @escaping (OnboardingHealthDisclaimerViewDelegate) -> AnyView,
        @ViewBuilder onboardingGoalSettingView: @escaping (OnboardingGoalSettingViewDelegate) -> AnyView,
        @ViewBuilder onboardingOverarchingObjectiveView: @escaping (OnboardingOverarchingObjectiveViewDelegate) -> AnyView,
        @ViewBuilder onboardingTargetWeightView: @escaping (OnboardingTargetWeightViewDelegate) -> AnyView,
        @ViewBuilder onboardingWeightRateView: @escaping (OnboardingWeightRateViewDelegate) -> AnyView,
        @ViewBuilder onboardingGoalSummaryView: @escaping (OnboardingGoalSummaryViewDelegate) -> AnyView,
        @ViewBuilder onboardingCustomisingProgramView: @escaping (OnboardingCustomisingProgramViewDelegate) -> AnyView,
        @ViewBuilder onboardingTrainingExperienceView: @escaping (OnboardingTrainingExperienceViewDelegate) -> AnyView,
        @ViewBuilder onboardingTrainingDaysPerWeekView: @escaping (OnboardingTrainingDaysPerWeekViewDelegate) -> AnyView,
        @ViewBuilder onboardingTrainingSplitView: @escaping (OnboardingTrainingSplitViewDelegate) -> AnyView,
        @ViewBuilder onboardingTrainingScheduleView: @escaping (OnboardingTrainingScheduleViewDelegate) -> AnyView,
        @ViewBuilder onboardingTrainingEquipmentView: @escaping (OnboardingTrainingEquipmentViewDelegate) -> AnyView,
        @ViewBuilder onboardingTrainingReviewView: @escaping (OnboardingTrainingReviewViewDelegate) -> AnyView,
        @ViewBuilder onboardingPreferredDietView: @escaping (OnboardingPreferredDietViewDelegate) -> AnyView,
        @ViewBuilder onboardingCalorieFloorView: @escaping (OnboardingCalorieFloorViewDelegate) -> AnyView,
        @ViewBuilder onboardingTrainingTypeView: @escaping (OnboardingTrainingTypeViewDelegate) -> AnyView,
        @ViewBuilder onboardingCalorieDistributionView: @escaping (OnboardingCalorieDistributionViewDelegate) -> AnyView,
        @ViewBuilder onboardingProteinIntakeView: @escaping (OnboardingProteinIntakeViewDelegate) -> AnyView,
        @ViewBuilder onboardingDietPlanView: @escaping (OnboardingDietPlanViewDelegate) -> AnyView,
        @ViewBuilder onboardingCompletedView: @escaping (OnboardingCompletedViewDelegate) -> AnyView
    ) -> some View {
        modifier(
            NavDestinationForOnboardingViewModifier(
                path: path,
                onboardingIntroView: onboardingIntroView,
                onboardingAuthOptionsView: onboardingAuthOptionsView,
                onboardingSignInView: onboardingSignInView,
                onboardingSignUpView: onboardingSignUpView,
                onboardingEmailVerificationView: onboardingEmailVerificationView,
                onboardingSubscriptionView: onboardingSubscriptionView,
                onboardingSubscriptionPlanView: onboardingSubscriptionPlanView,
                onboardingCompleteAccountSetupView: onboardingCompleteAccountSetupView,
                onboardingNamePhotoView: onboardingNamePhotoView,
                onboardingGenderView: onboardingGenderView,
                onboardingDateOfBirthView: onboardingDateOfBirthView,
                onboardingHeightView: onboardingHeightView,
                onboardingWeightView: onboardingWeightView,
                onboardingExerciseFrequencyView: onboardingExerciseFrequencyView,
                onboardingActivityView: onboardingActivityView,
                onboardingCardioFitnessView: onboardingCardioFitnessView,
                onboardingExpenditureView: onboardingExpenditureView,
                onboardingHealthDataView: onboardingHealthDataView,
                onboardingNotificationsView: onboardingNotificationsView,
                onboardingHealthDisclaimerView: onboardingHealthDisclaimerView,
                onboardingGoalSettingView: onboardingGoalSettingView,
                onboardingOverarchingObjectiveView: onboardingOverarchingObjectiveView,
                onboardingTargetWeightView: onboardingTargetWeightView,
                onboardingWeightRateView: onboardingWeightRateView,
                onboardingGoalSummaryView: onboardingGoalSummaryView,
                onboardingCustomisingProgramView: onboardingCustomisingProgramView,
                onboardingTrainingExperienceView: onboardingTrainingExperienceView,
                onboardingTrainingDaysPerWeekView: onboardingTrainingDaysPerWeekView,
                onboardingTrainingSplitView: onboardingTrainingSplitView,
                onboardingTrainingScheduleView: onboardingTrainingScheduleView,
                onboardingTrainingEquipmentView: onboardingTrainingEquipmentView,
                onboardingTrainingReviewView: onboardingTrainingReviewView,
                onboardingPreferredDietView: onboardingPreferredDietView,
                onboardingCalorieFloorView: onboardingCalorieFloorView,
                onboardingTrainingTypeView: onboardingTrainingTypeView,
                onboardingCalorieDistributionView: onboardingCalorieDistributionView,
                onboardingProteinIntakeView: onboardingProteinIntakeView,
                onboardingDietPlanView: onboardingDietPlanView,
                onboardingCompletedView: onboardingCompletedView
            )
        )
    }
}
