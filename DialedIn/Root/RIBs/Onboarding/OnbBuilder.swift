//
//  OnbBuilder.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/12/2025.
//

import SwiftUI
import SwiftfulRouting

@MainActor
struct OnbBuilder: Builder {
    let interactor: OnbInteractor
        
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

    func onboardingIntroView(router: AnyRouter) -> some View {
        OnboardingIntroView(
            presenter: OnboardingIntroPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
        
    }

    // MARK: Onboarding Auth

    func onboardingOnboardingAuthView(router: AnyRouter) -> some View {
        OnboardingAuthView(
            presenter: OnboardingAuthPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
    }

    // MARK: Onboarding Subscriptions

    func onboardingSubscriptionView(router: AnyRouter) -> some View {
        OnboardingSubscriptionView(
            presenter: OnboardingSubscriptionPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
        
    }

    func onboardingSubscriptionPlanView(router: AnyRouter) -> some View {
        OnboardingSubscriptionPlanView(
            presenter: OnboardingSubscriptionPlanPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
        
    }

    func onboardingCompleteAccountSetupView(router: AnyRouter) -> some View {
        OnboardingCompleteAccountSetupView(
            presenter: OnboardingCompleteAccountSetupPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
        
    }

    func onboardingNamePhotoView(router: AnyRouter) -> some View {
        OnboardingNamePhotoView(
            presenter: OnboardingNamePhotoPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
        
    }

    func onboardingGenderView(router: AnyRouter) -> some View {
        OnboardingGenderView(
            presenter: OnboardingGenderPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
        
    }

    func onboardingDateOfBirthView(router: AnyRouter, delegate: OnboardingDateOfBirthDelegate) -> some View {
        OnboardingDateOfBirthView(
            presenter: OnboardingDateOfBirthPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingHeightView(router: AnyRouter, delegate: OnboardingHeightDelegate) -> some View {
        OnboardingHeightView(
            presenter: OnboardingHeightPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingWeightView(router: AnyRouter, delegate: OnboardingWeightDelegate) -> some View {
        OnboardingWeightView(
            presenter: OnboardingWeightPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingExerciseFrequencyView(router: AnyRouter, delegate: OnboardingExerciseFrequencyDelegate) -> some View {
        OnboardingExerciseFrequencyView(
            presenter: OnboardingExerciseFrequencyPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingActivityView(router: AnyRouter, delegate: OnboardingActivityDelegate) -> some View {
        OnboardingActivityView(
            presenter: OnboardingActivityPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingCardioFitnessView(router: AnyRouter, delegate: OnboardingCardioFitnessDelegate) -> some View {
        OnboardingCardioFitnessView(
            presenter: OnboardingCardioFitnessPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingExpenditureView(router: AnyRouter, delegate: OnboardingExpenditureDelegate) -> some View {
        OnboardingExpenditureView(
            presenter: OnboardingExpenditurePresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingHealthDataView(router: AnyRouter) -> some View {
        OnboardingHealthDataView(
            presenter: OnboardingHealthDataPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
        
    }

    func onboardingNotificationsView(router: AnyRouter) -> some View {
        OnboardingNotificationsView(
            presenter: OnboardingNotificationsPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
        
    }

    func onboardingHealthDisclaimerView(router: AnyRouter) -> some View {
        OnboardingHealthDisclaimerView(
            presenter: OnboardingHealthDisclaimerPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
        
    }

    // MARK: Onboarding Goal Setting

    func onboardingGoalSettingView(router: AnyRouter) -> some View {
        OnboardingGoalSettingView(
            presenter: OnboardingGoalSettingPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
        
    }

    func onboardingOverarchingObjectiveView(router: AnyRouter) -> some View {
        OnboardingOverarchingObjectiveView(
            presenter: OnboardingOverarchingObjectivePresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
        
    }

    func onboardingTargetWeightView(router: AnyRouter, delegate: OnboardingTargetWeightDelegate) -> some View {
        OnboardingTargetWeightView(
            presenter: OnboardingTargetWeightPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingWeightRateView(router: AnyRouter, delegate: OnboardingWeightRateDelegate) -> some View {
        OnboardingWeightRateView(
            presenter: OnboardingWeightRatePresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingGoalSummaryView(router: AnyRouter, delegate: OnboardingGoalSummaryDelegate) -> some View {
        OnboardingGoalSummaryView(
            presenter: OnboardingGoalSummaryPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    // MARK: Customise Program

    func onboardingTrainingProgramView(router: AnyRouter) -> some View {
        OnboardingTrainingProgramView(
            presenter: OnboardingTrainingProgramPresenter(
                interactor: interactor,
                router: OnbRouter(router: router, builder: self)
            )
        )
        
    }

    func onboardingCustomisingProgramView(router: AnyRouter) -> some View {
        OnboardingCustomisingProgramView(
            presenter: OnboardingCustomisingProgramPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
        
    }

    func onboardingTrainingExperienceView(router: AnyRouter, delegate: OnboardingTrainingExperienceDelegate) -> some View {
        OnboardingTrainingExperienceView(
            presenter: OnboardingTrainingExperiencePresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingTrainingDaysPerWeekView(router: AnyRouter, delegate: OnboardingTrainingDaysPerWeekDelegate) -> some View {
        OnboardingTrainingDaysPerWeekView(
            presenter: OnboardingTrainingDaysPerWeekPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingTrainingSplitView(router: AnyRouter, delegate: OnboardingTrainingSplitDelegate) -> some View {
        OnboardingTrainingSplitView(
            presenter: OnboardingTrainingSplitPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingTrainingScheduleView(router: AnyRouter, delegate: OnboardingTrainingScheduleDelegate) -> some View {
        OnboardingTrainingScheduleView(
            presenter: OnboardingTrainingSchedulePresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingTrainingEquipmentView(router: AnyRouter, delegate: OnboardingTrainingEquipmentDelegate) -> some View {
        OnboardingTrainingEquipmentView(
            presenter: OnboardingTrainingEquipmentPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingTrainingReviewView(router: AnyRouter, delegate: OnboardingTrainingReviewDelegate) -> some View {
        OnboardingTrainingReviewView(
            presenter: OnboardingTrainingReviewPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingPreferredDietView(router: AnyRouter) -> some View {
        OnboardingPreferredDietView(
            presenter: OnboardingPreferredDietPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
        
    }

    func onboardingCalorieFloorView(router: AnyRouter, delegate: OnboardingCalorieFloorDelegate) -> some View {
        OnboardingCalorieFloorView(
            presenter: OnboardingCalorieFloorPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingTrainingTypeView(router: AnyRouter, delegate: OnboardingTrainingTypeDelegate) -> some View {
        OnboardingTrainingTypeView(
            presenter: OnboardingTrainingTypePresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingCalorieDistributionView(router: AnyRouter, delegate: OnboardingCalorieDistributionDelegate) -> some View {
        OnboardingCalorieDistributionView(
            presenter: OnboardingCalorieDistributionPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingProteinIntakeView(router: AnyRouter, delegate: OnboardingProteinIntakeDelegate) -> some View {
        OnboardingProteinIntakeView(
            presenter: OnboardingProteinIntakePresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingDietPlanView(router: AnyRouter, delegate: OnboardingDietPlanDelegate) -> some View {
        OnboardingDietPlanView(
            presenter: OnboardingDietPlanPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
        
    }

    func onboardingCompletedView(router: AnyRouter) -> some View {
        OnboardingCompletedView(
            presenter: OnboardingCompletedPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
        
    }
    
    func devSettingsView(router: AnyRouter) -> AnyView {
        DevSettingsView(
            presenter: DevSettingsPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
        .any()
    }
}
