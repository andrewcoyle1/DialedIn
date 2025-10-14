//
//  OnboardingCustomisingProgramView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/10/2025.
//

import SwiftUI

struct OnboardingCustomisingProgramView: View {
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager

    @State private var showAlert: AnyAppAlert?
    @State private var isLoading: Bool = false

    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif
        
    var body: some View {
        List {
            dietSection
        }
        .navigationTitle("Customise Program")
        .toolbar {
            toolbarContent
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $showDebugView) {
            DevSettingsView()
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
    
    private func updateOnboardingStep() async {
        
        // Only update if not already at this step (to avoid redundant updates and loading flashes)
        guard userManager.currentUser?.onboardingStep != .customiseProgram else {
            return
        }
        
        isLoading = true
        logManager.trackEvent(event: Event.updateOnboardingStepStart)
        
        do {
            try await userManager.updateOnboardingStep(step: .customiseProgram)
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
    
    private var dietSection: some View {
        Section {
            VStack(alignment: .leading) {
                Text("Let's get to work creating a custom diet program tuned to your needs. This will evolve over time as we learn how your body responds to the diet and make the necessary changes. This can always be manually altered later if you would like a specific change.")
                Text("We'll start with a few questions to get you started.")
                    .padding(.top)
            }
            .removeListRowFormatting()
            .padding(.horizontal)
            .foregroundStyle(Color.secondary)
        } header: {
            Text("Diet Program")
        }
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
                OnboardingPreferredDietView()
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
        OnboardingCustomisingProgramView()
    }
    .previewEnvironment()
}
