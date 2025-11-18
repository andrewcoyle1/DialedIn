//
//  OnboardingWelcomeView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/08/2025.
//

import SwiftUI

struct OnboardingWelcomeView: View {

    @Environment(\.dismiss) private var dismiss
    
    @State var viewModel: OnboardingWelcomeViewModel

    @ViewBuilder var devSettingsView: () -> AnyView
    @ViewBuilder var onboardingIntroView: (OnboardingIntroViewDelegate) -> AnyView
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

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            VStack(spacing: 8) {
                ImageLoaderView(urlString: viewModel.imageName)
                    .ignoresSafeArea()
                titleSection
                    .padding(.top, 8)
                
                Spacer()

                policyLinks
            }
            .padding(.bottom)
            .toolbar {
                toolbarContent
            }
            #if DEBUG || MOCK
            .sheet(isPresented: $viewModel.showDebugView) {
                devSettingsView()
            }
            #endif
            .screenAppearAnalytics(name: "Welcome")
            .navigationDestinationOnboardingModule(
                path: $viewModel.path,
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
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                viewModel.showDebugView = true
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                viewModel.navToAppropriateView()
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
        }
    }
    
    private var titleSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "gauge.with.needle.fill")
                .font(.system(size: 40))
                .foregroundStyle(Color.accent)
            Text("Dialed")
                .font(.largeTitle)
                .fontWeight(.semibold)
            Text("A better way to manage your training")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
        }
        .padding(.top, 24)
    }
    
    private var policyLinks: some View {
        HStack(spacing: 8) {
            Link(destination: URL(string: Constants.termsofServiceURL)!) {
                Text("Terms of Service")
            }
            
            Circle()
                .fill(.accent)
                .frame(width: 4, height: 4)
            
            Link(destination: URL(string: Constants.privacyPolicyURL)!) {
                Text("Privacy Policy")
            }
        }
    }
}

#Preview("Functioning") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    builder.onboardingWelcomeView()
    .previewEnvironment()
}
