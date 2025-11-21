//
//  OnboardingHeightView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

struct OnboardingHeightViewDelegate {
    var path: Binding<[OnboardingPathOption]>
    var userModelBuilder: UserModelBuilder
}

struct OnboardingHeightView: View {

    @State var viewModel: OnboardingHeightViewModel

    var delegate: OnboardingHeightViewDelegate

    @ViewBuilder var devSettingsView: () -> AnyView

    var body: some View {
        List {
            pickerSection
            if viewModel.unit == .centimeters {
                metricSection
            } else {
                imperialSection
            }
        }
        .navigationTitle("How tall are you?")
        .toolbar {
            toolbarContent
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $viewModel.showDebugView) {
            devSettingsView()
        }
        #endif
    }
    
    private var pickerSection: some View {
        Section {
            Picker("Units", selection: $viewModel.unit) {
                Text("Metric").tag(UnitOfLength.centimeters)
                Text("Imperial").tag(UnitOfLength.inches)
            }
            .pickerStyle(.segmented)
        }
        .removeListRowFormatting()
        
    }
    
    private var metricSection: some View {
        Section {
            VStack {
                Picker("Centimeters", selection: $viewModel.selectedCentimeters) {
                    ForEach((100...250).reversed(), id: \.self) { value in
                        Text("\(value) cm").tag(value)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                .frame(maxWidth: 150)
                .clipped()
                .onChange(of: viewModel.selectedCentimeters) { _, _ in
                    viewModel.updateImperialFromCentimeters()
                }
            }
            .frame(maxWidth: .infinity)
        } header: {
            Text("Metric")
        }
        .removeListRowFormatting()
    }
    
    private var imperialSection: some View {
        Section {
            HStack(spacing: 12) {
                Spacer(minLength: 0)

                Picker("Feet", selection: $viewModel.selectedFeet) {
                    ForEach((3...8).reversed(), id: \.self) { feet in
                        Text("\(feet) ft").tag(feet)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                .frame(maxWidth: 150)
                .clipped()
                .onChange(of: viewModel.selectedFeet) { _, _ in
                    viewModel.updateCentimetersFromImperial()
                }
                Spacer(minLength: 0)

                Picker("Inches", selection: $viewModel.selectedInches) {
                    ForEach((0...11).reversed(), id: \.self) { inch in
                        Text("\(inch) in").tag(inch)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                .frame(maxWidth: 150)
                .clipped()
                .onChange(of: viewModel.selectedInches) { _, _ in
                    viewModel.updateCentimetersFromImperial()
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
        } header: {
            Text("Imperial")
        }
        .removeListRowFormatting()
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
                viewModel.navigateToWeightView(path: delegate.path, userBuilder: delegate.userModelBuilder)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
        }
    }
}

#Preview {
    @Previewable @State var path: [OnboardingPathOption] = []
    let builder = CoreBuilder(container: DevPreview.shared.container)
    NavigationStack(path: $path) {
        builder.onboardingHeightView(
            delegate: OnboardingHeightViewDelegate(
                path: $path,
                userModelBuilder: UserModelBuilder.heightMock
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
