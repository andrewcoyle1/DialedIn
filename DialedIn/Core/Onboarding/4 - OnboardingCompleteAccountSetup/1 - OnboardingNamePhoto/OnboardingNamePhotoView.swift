//
//  OnboardingNamePhotoView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI
import PhotosUI

struct OnboardingNamePhotoViewDelegate {
    var path: Binding<[OnboardingPathOption]>
}

struct OnboardingNamePhotoView: View {

    @State var viewModel: OnboardingNamePhotoViewModel

    var delegate: OnboardingNamePhotoViewDelegate

    @ViewBuilder var devSettingsView: () -> AnyView

    var body: some View {
        List {
            imageSection
            nameSection
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Create Profile")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            toolbarContent
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $viewModel.showDebugView) {
            devSettingsView()
        }
        #endif
        .onAppear(perform: viewModel.prefillFromCurrentUser)
        .onChange(of: viewModel.selectedPhotoItem) {
            Task {
                await viewModel.handlePhotoSelection()
            }
        }
        .showCustomAlert(alert: $viewModel.showAlert)
        .showModal(showModal: $viewModel.isSaving) {
            ProgressView()
                .tint(.white)
        }
    }
    
    private var imageSection: some View {
        Button {
            viewModel.isImagePickerPresented = true
        } label: {
            ZStack {
                Rectangle()
                    .fill(Color.secondary.opacity(0.001))
                Group {
                    if let data = viewModel.selectedImageData {
                        #if canImport(UIKit)
                        if let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                        }
                        #elseif canImport(AppKit)
                        if let nsImage = NSImage(data: data) {
                            Image(nsImage: nsImage)
                                .resizable()
                                .scaledToFill()
                        }
                        #endif
                    } else if let user = viewModel.currentUser,
                              let cachedImage = ProfileImageCache.shared.getCachedImage(userId: user.userId) {
                        // Show cached image if available
                        #if canImport(UIKit)
                        Image(uiImage: cachedImage)
                            .resizable()
                            .scaledToFill()
                        #elseif canImport(AppKit)
                        Image(nsImage: cachedImage)
                            .resizable()
                            .scaledToFill()
                        #endif
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "person.crop.circle")
                                .font(.system(size: 80))
                                .foregroundStyle(.accent)
                            Text("Add Photo (Optional)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
        }
        .photosPicker(isPresented: $viewModel.isImagePickerPresented, selection: $viewModel.selectedPhotoItem, matching: .images)
        .removeListRowFormatting()
    }
    
    private var nameSection: some View {
        Section {
            TextField("First name", text: $viewModel.firstName)
                .textContentType(.givenName)
                .autocapitalization(.words)
            TextField("Last name (optional)", text: $viewModel.lastName)
                .textContentType(.familyName)
                .autocapitalization(.words)
        } header: {
            Text("Your Name")
        } footer: {
            Text("Help us personalize your experience by providing your name. You can also add a profile photo if you'd like.")
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
                Task {
                    await viewModel.saveAndContinue(path: delegate.path)
                }
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(viewModel.isSaving || !viewModel.canContinue)
        }
    }
}

#Preview {
    @Previewable @State var path: [OnboardingPathOption] = []
    let builder = CoreBuilder(container: DevPreview.shared.container)
    NavigationStack(path: $path) {
        builder.onboardingNamePhotoView(
            delegate: OnboardingNamePhotoViewDelegate(
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
