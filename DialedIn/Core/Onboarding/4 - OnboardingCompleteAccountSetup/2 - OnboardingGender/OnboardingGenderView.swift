//
//  OnboardingGenderView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

struct OnboardingGenderViewDelegate {
    var path: Binding<[OnboardingPathOption]>
}

struct OnboardingGenderView: View {

    @Environment(\.dismiss) private var dismiss

    @State var viewModel: OnboardingGenderViewModel

    var delegate: OnboardingGenderViewDelegate

    @ViewBuilder var devSettingsView: () -> AnyView

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    genderRow(.male)
                    genderRow(.female)
                }
                .removeListRowFormatting()
                .padding(.horizontal)
            } header: {
                Text("Select your gender")
            }
        }
        .navigationTitle("About You")
        .screenAppearAnalytics(name: "OnboardingSelectGender")
        .toolbar {
            toolbarContent
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $viewModel.showDebugView) {
            devSettingsView()
        }
        #endif
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
                viewModel.navigateToDateOfBirth(path: delegate.path)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(!viewModel.canSubmit)
        }
    }
    
    private func genderRow(_ gender: Gender) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(gender.description)
                    .font(.headline)
            }
            Spacer(minLength: 8)
            Image(systemName: viewModel.selectedGender == gender ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(viewModel.selectedGender == gender ? Color.accent : Color.secondary)
        }
        .contentShape(Rectangle())
        .anyButton(.press) {
            viewModel.selectedGender = gender
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    @Previewable @State var path: [OnboardingPathOption] = []
    let builder = CoreBuilder(container: DevPreview.shared.container)
    NavigationStack(path: $path) {
        builder.onboardingGenderView(
            delegate: OnboardingGenderViewDelegate(
                path: $path
            )
        )
    }
    .navigationDestinationOnboardingModule(
        path: $path,
        onboardingIntroView: { 
            Text("Intro View").any()
        },
        onboardingAuthOptionsView: { _ in
            Text("Auth Option View").any()
        },
        onboardingSignInView: { _ in
            Text("Sign In View").any()
        },
        onboardingSignUpView: { _ in
            Text("Sign Up View").any()
        },
        onboardingEmailVerificationView: { _ in
            Text("Email Verification View").any()
        },
        onboardingSubscriptionView: { _ in
            Text("Subscription View").any()
        },
        onboardingSubscriptionPlanView: { _ in
            Text("Subcription Plan View").any()
        },
        onboardingCompleteAccountSetupView: { _ in
            Text("Complete Account Setup View").any()
        },
        onboardingNamePhotoView: { _ in
            Text("Name & Photo View").any()
        },
        onboardingGenderView: { _ in
            Text("Gender View").any()
        },
        onboardingDateOfBirthView: { _ in
            Text("Date of Birth View").any()
        },
        onboardingHeightView: { _ in
            Text("Height View").any()
        },
        onboardingWeightView: { _ in
            Text("Weight View").any()
        },
        onboardingExerciseFrequencyView: { _ in
            Text("Exercise Frequency View").any()
        },
        onboardingActivityView: { _ in
            Text("Activity View").any()
        },
        onboardingCardioFitnessView: { _ in
            Text("Cardio Fitness View").any()
        },
        onboardingExpenditureView: { _ in
            Text("Expenditure View").any()
        },
        onboardingHealthDataView: { _ in
            Text("Health Data View").any()
        },
        onboardingNotificationsView: { _ in
            Text("Notifications View").any()
        },
        onboardingHealthDisclaimerView: { _ in
            Text("Health Disclaimer View").any()
        },
        onboardingGoalSettingView: { _ in
            Text("Goal Setting View").any()
        },
        onboardingOverarchingObjectiveView: { _ in
            Text("Overarching Objective View").any()
        },
        onboardingTargetWeightView: { _ in
            Text("Target Weight View").any()
        },
        onboardingWeightRateView: { _ in
            Text("Weight Rate View").any()
        },
        onboardingGoalSummaryView: { _ in
            Text("Goal Summary View").any()
        },
        onboardingCustomisingProgramView: { _ in
            Text("Customising Program View").any()
        },
        onboardingTrainingExperienceView: { _ in
            Text("Training Experience View").any()
        },
        onboardingTrainingDaysPerWeekView: { _ in
            Text("Training Days Per Week View").any()
        },
        onboardingTrainingSplitView: { _ in
            Text("Training Split View").any()
        },
        onboardingTrainingScheduleView: { _ in
            Text("Training Schedule  View").any()
        },
        onboardingTrainingEquipmentView: { _ in
            Text("Training Equipment View").any()
        },
        onboardingTrainingReviewView: { _ in
            Text("Training Review View").any()
        },
        onboardingPreferredDietView: { _ in
            Text("Preferred Diet View").any()
        },
        onboardingCalorieFloorView: { _ in
            Text("Calorie Floor View").any()
        },
        onboardingTrainingTypeView: { _ in
            Text("Training Type View").any()
        },
        onboardingCalorieDistributionView: { _ in
            Text("Calorie Distribution View").any()
        },
        onboardingProteinIntakeView: { _ in
            Text("Protein Intake View").any()
        },
        onboardingDietPlanView: { _ in
            Text("Diet Plan View").any()
        },
        onboardingCompletedView: { _ in
            Text("Onboarding Completed View").any()
        }
    )    .previewEnvironment()
}
