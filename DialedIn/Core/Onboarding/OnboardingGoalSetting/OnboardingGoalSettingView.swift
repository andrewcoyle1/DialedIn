//
//  OnboardingGoalSettingView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/10/2025.
//

import SwiftUI

struct OnboardingGoalSettingView: View {
    @Environment(DependencyContainer.self) private var container

    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    
    @State private var showAlert: AnyAppAlert?
    @State private var isLoading: Bool = false

    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif
        
    var body: some View {
        List {
            goalSettingSection
        }
        .navigationTitle("Goal Setting")
        .navigationBarBackButtonHidden()
        .toolbar {
            toolbarContent
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $showDebugView) {
            DevSettingsView(viewModel: DevSettingsViewModel(interactor: CoreInteractor(container: container)))
        }
        #endif
        .task {
            await updateOnboardingStep()
        }
        .showModal(showModal: $isLoading) {
            ProgressView()
                .tint(.white)
        }
        .showCustomAlert(alert: $showAlert)
    }
    
    private var goalSettingSection: some View {
        Section {
            Text("Depending on what your goal is, we will help you by generating a custom plan to help you get there. This can be changed in future, and your plan will be updated accordingly.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        } header: {
            Text("Goal")
        }
    }
    
    private func updateOnboardingStep() async {
        let target: OnboardingStep = .goalSetting
        if let current = userManager.currentUser?.onboardingStep, current.orderIndex >= target.orderIndex {
            return
        }
        isLoading = true
        logManager.trackEvent(event: Event.updateOnboardingStepStart)
        do {
            try await userManager.updateOnboardingStep(step: target)
            logManager.trackEvent(event: Event.updateOnboardingStepSuccess)
        } catch {
            showAlert = AnyAppAlert(title: "Unable to update your progress", subtitle: "Please check your internet connection and try again.", buttons: {
                AnyView(
                    HStack {
                        Button {
                            
                        } label: {
                            Text("Dismiss")
                        }
                        
                        Button {
                            Task {
                                await updateOnboardingStep()
                            }
                        } label: {
                            Text("Try again")
                        }
                    }
                )
            })
            logManager.trackEvent(event: Event.updateOnboardingStepFail(error: error))
        }
        isLoading = false
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                showDebugView = true
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            NavigationLink {
                OnboardingOverarchingObjectiveView()
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
        }
    }
    
    enum Event: LoggableEvent {
        case updateOnboardingStepStart
        case updateOnboardingStepSuccess
        case updateOnboardingStepFail(error: Error)
        
        var eventName: String {
            switch self {
            case .updateOnboardingStepStart:    return "update_onboarding_step_start"
            case .updateOnboardingStepSuccess:  return "update_onboarding_step_success"
            case .updateOnboardingStepFail:     return "update_onboarding_step_fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .updateOnboardingStepFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .updateOnboardingStepFail:
                return .severe
            default:
                return .analytic
                
            }
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingGoalSettingView()
    }
    .previewEnvironment()
}
