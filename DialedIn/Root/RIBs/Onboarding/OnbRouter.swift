//
//  Onb.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/12/2025.
//

import SwiftUI
import SwiftfulRouting

@MainActor
struct OnbRouter: GlobalRouter {
    let router: AnyRouter
    let builder: OnbBuilder
    
    func showOnboardingIntroView() {
        router.showScreen(.push) { router in
            builder.onboardingIntroView(router: router)
        }
    }

    func showAuthOptionsView() {
        router.showScreen(.push) { router in
            builder.onboardingAuthOptionsView(router: router)
        }
    }

    func showSignInView() {
        router.showScreen(.push) { router in
            builder.onboardingSignInView(router: router)
        }
    }

    func showSignUpView() {
        router.showScreen(.push) { router in
            builder.onboardingSignUpView(router: router)
        }
    }

    func showEmailVerificationView() {
        router.showScreen(.push) { router in
            builder.onboardingEmailVerificationView(router: router)
        }
    }

    func showSubscriptionView() {
        router.showScreen(.push) { router in
            builder.onboardingSubscriptionView(router: router)
        }
    }

    func showSubscriptionPlanView() {
        router.showScreen(.push) { router in
            builder.onboardingSubscriptionPlanView(router: router)
        }
    }

    func showOnboardingCompleteAccountSetupView() {
        router.showScreen(.push) { router in
            builder.onboardingCompleteAccountSetupView(router: router)
        }
    }

    func showOnboardingNamePhotoView() {
        router.showScreen(.push) { router in
            builder.onboardingNamePhotoView(router: router)
        }
    }

    func showOnboardingGenderView() {
        router.showScreen(.push) { router in
            builder.onboardingGenderView(router: router)
        }
    }

    func showOnboardingDateOfBirthView(delegate: OnboardingDateOfBirthDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingDateOfBirthView(router: router, delegate: delegate)
        }
    }

    func showOnboardingHeightView(delegate: OnboardingHeightDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingHeightView(router: router, delegate: delegate)
        }
    }

    func showOnboardingWeightView(delegate: OnboardingWeightDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingWeightView(router: router, delegate: delegate)
        }
    }

    func showOnboardingExerciseFrequencyView(delegate: OnboardingExerciseFrequencyDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingExerciseFrequencyView(router: router, delegate: delegate)
        }
    }

    func showOnboardingActivityView(delegate: OnboardingActivityDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingActivityView(router: router, delegate: delegate)
        }
    }

    func showOnboardingCardioFitnessView(delegate: OnboardingCardioFitnessDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingCardioFitnessView(router: router, delegate: delegate)
        }
    }

    func showOnboardingExpenditureView(delegate: OnboardingExpenditureDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingExpenditureView(router: router, delegate: delegate)
        }
    }

    func showOnboardingHealthDataView() {
        router.showScreen(.push) { router in
            builder.onboardingHealthDataView(router: router)
        }
    }

    func showOnboardingNotificationsView() {
        router.showScreen(.push) { router in
            builder.onboardingNotificationsView(router: router)
        }
    }

    func showOnboardingHealthDisclaimerView() {
        router.showScreen(.push) { router in
            builder.onboardingHealthDisclaimerView(router: router)
        }
    }

    func showOnboardingGoalSettingView() {
        router.showScreen(.push) { router in
            builder.onboardingGoalSettingView(router: router)
        }
    }

    func showOnboardingOverarchingObjectiveView() {
        router.showScreen(.push) { router in
            builder.onboardingOverarchingObjectiveView(router: router)
        }
    }

    func showOnboardingTargetWeightView(delegate: OnboardingTargetWeightDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingTargetWeightView(router: router, delegate: delegate)
        }
    }

    func showOnboardingWeightRateView(delegate: OnboardingWeightRateDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingWeightRateView(router: router, delegate: delegate)
        }
    }

    func showOnboardingGoalSummaryView(delegate: OnboardingGoalSummaryDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingGoalSummaryView(router: router, delegate: delegate)
        }
    }

    func showOnboardingTrainingProgramView() {
        router.showScreen(.push) { router in
            builder.onboardingTrainingProgramView(router: router)
        }
    }

    func showOnboardingCustomisingProgramView() {
        router.showScreen(.push) { router in
            builder.onboardingCustomisingProgramView(router: router)
        }
    }

    func showOnboardingTrainingExperienceView(delegate: OnboardingTrainingExperienceDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingTrainingExperienceView(router: router, delegate: delegate)
        }
    }

    func showOnboardingTrainingDaysPerWeekView(delegate: OnboardingTrainingDaysPerWeekDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingTrainingDaysPerWeekView(router: router, delegate: delegate)
        }
    }

    func showOnboardingTrainingSplitView(delegate: OnboardingTrainingSplitDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingTrainingSplitView(router: router, delegate: delegate)
        }
    }

    func showOnboardingTrainingScheduleView(delegate: OnboardingTrainingScheduleDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingTrainingScheduleView(router: router, delegate: delegate)
        }
    }

    func showOnboardingTrainingEquipmentView(delegate: OnboardingTrainingEquipmentDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingTrainingEquipmentView(router: router, delegate: delegate)
        }
    }

    func showOnboardingTrainingReviewView(delegate: OnboardingTrainingReviewDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingTrainingReviewView(router: router, delegate: delegate)
        }
    }

    func showOnboardingPreferredDietView() {
        router.showScreen(.push) { router in
            builder.onboardingPreferredDietView(router: router)
        }
    }

    func showOnboardingCalorieFloorView(delegate: OnboardingCalorieFloorDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingCalorieFloorView(router: router, delegate: delegate)
        }
    }

    func showOnboardingTrainingTypeView(delegate: OnboardingTrainingTypeDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingTrainingTypeView(router: router, delegate: delegate)
        }
    }

    func showOnboardingCalorieDistributionView(delegate: OnboardingCalorieDistributionDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingCalorieDistributionView(router: router, delegate: delegate)
        }
    }

    func showOnboardingProteinIntakeView(delegate: OnboardingProteinIntakeDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingProteinIntakeView(router: router, delegate: delegate)
        }
    }

    func showOnboardingDietPlanView(delegate: OnboardingDietPlanDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingDietPlanView(router: router, delegate: delegate)
        }
    }

    func showOnboardingCompletedView() {
        router.showScreen(.push) { router in
            builder.onboardingCompletedView(router: router)
        }
    }

    func showDevSettingsView() {
        router.showScreen(.fullScreenCover) { router in
            builder.devSettingsView(router: router)
        }
    }
}
