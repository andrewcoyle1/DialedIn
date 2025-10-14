//
//  OnboardingCompleteAccountSetupView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

struct OnboardingCompleteAccountSetupView: View {
    @Environment(UserManager.self) private var userManager
    @Environment(PushManager.self) private var pushManager
    @Environment(HealthKitManager.self) private var healthManager
    @State private var navigationDestination: NavigationDestination?
    
    @State private var canRequestNotificationsAuthorisation: Bool?
    @State private var canRequestHealthDataAuthorisation: Bool?
    
    @State private var showAlert: AnyAppAlert?
    
    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif
        
    var body: some View {
        List {
            Text("Intro to complete account setup - explain why the user needs to submit their data")
        }
        .navigationTitle("Welcome")
        .navigationBarBackButtonHidden()
        .toolbar {
            toolbarContent
        }
        .task {
            await updateOnboardingStep()
        }
        .onAppear {
            canRequestHealthDataAuthorisation = healthManager.canRequestAuthorisation()
        }
        .showCustomAlert(alert: $showAlert)
        .navigationDestination(
            isPresented: Binding(
                get: {
                    navigationDestination == .healthData
                }, set: {
                    if !$0 {
                        navigationDestination = nil
                    }
                }
            )
        ) {
            OnboardingHealthDataView()
        }
        .navigationDestination(
            isPresented: Binding(
                get: {
                    navigationDestination == .notifications
                }, set: {
                    if !$0 {
                        navigationDestination = nil
                    }
                }
            )
        ) {
            OnboardingNotificationsView()
        }
        .navigationDestination(
            isPresented: Binding(
                get: {
                    navigationDestination == .gender
                }, set: {
                    if !$0 {
                        navigationDestination = nil
                    }
                }
            )
        ) {
            OnboardingGenderView()
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $showDebugView) {
            DevSettingsView()
        }
        #endif
    }
    
    private func updateOnboardingStep() async {
        // Only update if not already at this step to avoid redundant writes and step-flapping
        guard userManager.currentUser?.onboardingStep != .completeAccountSetup else {
            return
        }
        do {
            try await userManager.updateOnboardingStep(step: .completeAccountSetup)
        } catch {
            showAlert = AnyAppAlert(title: "Internet Connection Failed", subtitle: "Please check your internet connection and try again.") {
                AnyView(
                    HStack {
                        Button(role: .close) {
                            
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
            }
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
            Button {
                Task {
                    // Ensure we have the latest authorization status
                    if canRequestNotificationsAuthorisation == nil {
                        canRequestNotificationsAuthorisation = await pushManager.canRequestAuthorisation()
                    }
                    
                    if canRequestHealthDataAuthorisation == true {
                        navigationDestination = .healthData
                    } else if canRequestNotificationsAuthorisation == true {
                        navigationDestination = .notifications
                    } else {
                        navigationDestination = .gender
                    }
                }
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
        }
    }
}

#Preview("To Health Permissions") {
    NavigationStack {
        OnboardingCompleteAccountSetupView()
    }
    .environment(HealthKitManager(service: MockHealthService(canRequestAuthorisation: true)))
    .environment(PushManager(services: MockPushServices(canRequestAuthorisation: false)))
    .previewEnvironment()
}

#Preview("To Notification Permissions") {
    NavigationStack {
        OnboardingCompleteAccountSetupView()
    }
    .environment(HealthKitManager(service: MockHealthService(canRequestAuthorisation: false)))
    .environment(PushManager(services: MockPushServices(canRequestAuthorisation: true)))
    .previewEnvironment()
}

#Preview("To Health & Notifications Permissions") {
    NavigationStack {
        OnboardingCompleteAccountSetupView()
    }
    .environment(HealthKitManager(service: MockHealthService(canRequestAuthorisation: true)))
    .environment(PushManager(services: MockPushServices(canRequestAuthorisation: true)))
    .previewEnvironment()
}

#Preview("To Gender") {
    NavigationStack {
        OnboardingCompleteAccountSetupView()
    }
    .environment(HealthKitManager(service: MockHealthService(canRequestAuthorisation: false)))
    .environment(PushManager(services: MockPushServices(canRequestAuthorisation: false)))
    .previewEnvironment()
}
