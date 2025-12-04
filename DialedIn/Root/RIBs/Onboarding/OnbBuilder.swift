//
//  OnbBuilder.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/12/2025.
//

import SwiftUI
import CustomRouting

@MainActor
struct OnbBuilder: Builder {
    let interactor: OnbInteractor
    
    init(interactor: OnbInteractor) {
        self.interactor = interactor
    }
    
    func build() -> AnyView {
        onboardingWelcomeView()
            .any()
    }
    
    func onboardingWelcomeView() -> some View {
        RouterView { router in
            OnboardingWelcomeView(
                presenter: OnboardingWelcomePresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
            )
        }
    }

    func onboardingIntroView(router: Router) -> some View {
        OnboardingIntroView(
            presenter: OnboardingIntroPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
        
    }

    // MARK: Onboarding Auth

    func onboardingAuthOptionsView(router: Router) -> some View {
        AuthOptionsView(
            presenter: AuthOptionsPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
        
    }

    func onboardingSignInView(router: Router) -> some View {
        SignInView(
            presenter: SignInPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
        
    }

    func onboardingSignUpView(router: Router) -> some View {
        SignUpView(
            presenter: SignUpPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
        
    }

    func onboardingEmailVerificationView(router: Router) -> some View {
        EmailVerificationView(
            presenter: EmailVerificationPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
        
    }

    // MARK: Onboarding Subscriptions

    func onboardingSubscriptionView(router: Router) -> some View {
        OnboardingSubscriptionView(
            presenter: OnboardingSubscriptionPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
        
    }

    func onboardingSubscriptionPlanView(router: Router) -> some View {
        OnboardingSubscriptionPlanView(
            presenter: OnboardingSubscriptionPlanPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
        
    }

    func onboardingCompleteAccountSetupView(router: Router) -> some View {
        OnboardingCompleteAccountSetupView(
            presenter: OnboardingCompleteAccountSetupPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
        
    }

    func onboardingNamePhotoView(router: Router) -> some View {
        OnboardingNamePhotoView(
            presenter: OnboardingNamePhotoPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
        
    }

    func onboardingGenderView(router: Router) -> some View {
        OnboardingGenderView(
            presenter: OnboardingGenderPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
        
    }

    func onboardingDateOfBirthView(router: Router, delegate: OnboardingDateOfBirthDelegate) -> some View {
        OnboardingDateOfBirthView(
            presenter: OnboardingDateOfBirthPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingHeightView(router: Router, delegate: OnboardingHeightDelegate) -> some View {
        OnboardingHeightView(
            presenter: OnboardingHeightPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingWeightView(router: Router, delegate: OnboardingWeightDelegate) -> some View {
        OnboardingWeightView(
            presenter: OnboardingWeightPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingExerciseFrequencyView(router: Router, delegate: OnboardingExerciseFrequencyDelegate) -> some View {
        OnboardingExerciseFrequencyView(
            presenter: OnboardingExerciseFrequencyPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingActivityView(router: Router, delegate: OnboardingActivityDelegate) -> some View {
        OnboardingActivityView(
            presenter: OnboardingActivityPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingCardioFitnessView(router: Router, delegate: OnboardingCardioFitnessDelegate) -> some View {
        OnboardingCardioFitnessView(
            presenter: OnboardingCardioFitnessPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingExpenditureView(router: Router, delegate: OnboardingExpenditureDelegate) -> some View {
        OnboardingExpenditureView(
            presenter: OnboardingExpenditurePresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingHealthDataView(router: Router) -> some View {
        OnboardingHealthDataView(
            presenter: OnboardingHealthDataPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
        
    }

    func onboardingNotificationsView(router: Router) -> some View {
        OnboardingNotificationsView(
            presenter: OnboardingNotificationsPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
        
    }

    func onboardingHealthDisclaimerView(router: Router) -> some View {
        OnboardingHealthDisclaimerView(
            presenter: OnboardingHealthDisclaimerPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
        
    }

    // MARK: Onboarding Goal Setting

    func onboardingGoalSettingView(router: Router) -> some View {
        OnboardingGoalSettingView(
            presenter: OnboardingGoalSettingPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
        
    }

    func onboardingOverarchingObjectiveView(router: Router) -> some View {
        OnboardingOverarchingObjectiveView(
            presenter: OnboardingOverarchingObjectivePresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
        
    }

    func onboardingTargetWeightView(router: Router, delegate: OnboardingTargetWeightDelegate) -> some View {
        OnboardingTargetWeightView(
            presenter: OnboardingTargetWeightPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingWeightRateView(router: Router, delegate: OnboardingWeightRateDelegate) -> some View {
        OnboardingWeightRateView(
            presenter: OnboardingWeightRatePresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingGoalSummaryView(router: Router, delegate: OnboardingGoalSummaryDelegate) -> some View {
        OnboardingGoalSummaryView(
            presenter: OnboardingGoalSummaryPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    // MARK: Customise Program

    func onboardingTrainingProgramView(router: Router) -> some View {
        OnboardingTrainingProgramView(
            presenter: OnboardingTrainingProgramPresenter(
                interactor: interactor,
                router: OnbRouter(router: router, builder: self)
            )
        )
        
    }

    func onboardingCustomisingProgramView(router: Router) -> some View {
        OnboardingCustomisingProgramView(
            presenter: OnboardingCustomisingProgramPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
        
    }

    func onboardingTrainingExperienceView(router: Router, delegate: OnboardingTrainingExperienceDelegate) -> some View {
        OnboardingTrainingExperienceView(
            presenter: OnboardingTrainingExperiencePresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingTrainingDaysPerWeekView(router: Router, delegate: OnboardingTrainingDaysPerWeekDelegate) -> some View {
        OnboardingTrainingDaysPerWeekView(
            presenter: OnboardingTrainingDaysPerWeekPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingTrainingSplitView(router: Router, delegate: OnboardingTrainingSplitDelegate) -> some View {
        OnboardingTrainingSplitView(
            presenter: OnboardingTrainingSplitPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingTrainingScheduleView(router: Router, delegate: OnboardingTrainingScheduleDelegate) -> some View {
        OnboardingTrainingScheduleView(
            presenter: OnboardingTrainingSchedulePresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingTrainingEquipmentView(router: Router, delegate: OnboardingTrainingEquipmentDelegate) -> some View {
        OnboardingTrainingEquipmentView(
            presenter: OnboardingTrainingEquipmentPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingTrainingReviewView(router: Router, delegate: OnboardingTrainingReviewDelegate) -> some View {
        OnboardingTrainingReviewView(
            presenter: OnboardingTrainingReviewPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingPreferredDietView(router: Router) -> some View {
        OnboardingPreferredDietView(
            presenter: OnboardingPreferredDietPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
        
    }

    func onboardingCalorieFloorView(router: Router, delegate: OnboardingCalorieFloorDelegate) -> some View {
        OnboardingCalorieFloorView(
            presenter: OnboardingCalorieFloorPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingTrainingTypeView(router: Router, delegate: OnboardingTrainingTypeDelegate) -> some View {
        OnboardingTrainingTypeView(
            presenter: OnboardingTrainingTypePresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingCalorieDistributionView(router: Router, delegate: OnboardingCalorieDistributionDelegate) -> some View {
        OnboardingCalorieDistributionView(
            presenter: OnboardingCalorieDistributionPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingProteinIntakeView(router: Router, delegate: OnboardingProteinIntakeDelegate) -> some View {
        OnboardingProteinIntakeView(
            presenter: OnboardingProteinIntakePresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingDietPlanView(router: Router, delegate: OnboardingDietPlanDelegate) -> some View {
        OnboardingDietPlanView(
            presenter: OnboardingDietPlanPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingCompletedView(router: Router) -> some View {
        OnboardingCompletedView(
            presenter: OnboardingCompletedPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
        
    }
    
    func devSettingsView(router: Router) -> AnyView {
        DevSettingsView(
            presenter: DevSettingsPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
        .any()
    }
}
