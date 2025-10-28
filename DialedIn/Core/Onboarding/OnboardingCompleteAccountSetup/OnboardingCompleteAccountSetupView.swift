//
//  OnboardingCompleteAccountSetupView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

struct OnboardingCompleteAccountSetupView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: OnboardingCompleteAccountSetupViewModel
        
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
            await viewModel.updateOnboardingStep()
        }
        .onAppear {
            viewModel.canRequestHealthDataAuthorisation = viewModel.checkHealthDataAuthorisationStatus()
        }
        .showCustomAlert(alert: $viewModel.showAlert)
        .navigationDestination(
            isPresented: Binding(
                get: {
                    viewModel.navigationDestination == .healthData
                }, set: {
                    if !$0 {
                        viewModel.navigationDestination = nil
                    }
                }
            )
        ) {
            OnboardingHealthDataView(
                viewModel: OnboardingHealthDataViewModel(
                    interactor: CoreInteractor(
                        container: container
                    )
                )
            )
        }
        .navigationDestination(
            isPresented: Binding(
                get: {
                    viewModel.navigationDestination == .notifications
                }, set: {
                    if !$0 {
                        viewModel.navigationDestination = nil
                    }
                }
            )
        ) {
            OnboardingNotificationsView(
                viewModel: OnboardingNotificationsViewModel(
                    interactor: CoreInteractor(
                        container: container
                    )
                )
            )
        }
        .navigationDestination(
            isPresented: Binding(
                get: {
                    viewModel.navigationDestination == .namePhoto
                }, set: {
                    if !$0 {
                        viewModel.navigationDestination = nil
                    }
                }
            )
        ) {
            OnboardingNamePhotoView(
                viewModel: OnboardingNamePhotoViewModel(
                    interactor: CoreInteractor(
                        container: container
                    )
                )
            )
        }
        .navigationDestination(
            isPresented: Binding(
                get: {
                    viewModel.navigationDestination == .gender
                }, set: {
                    if !$0 {
                        viewModel.navigationDestination = nil
                    }
                }
            )
        ) {
            OnboardingGenderView(
                viewModel: OnboardingGenderViewModel(
                    interactor: CoreInteractor(
                        container: container
                    )
                )
            )
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $viewModel.showDebugView) {
            DevSettingsView(
                viewModel: DevSettingsViewModel(
                    interactor: CoreInteractor(
                        container: container
                    )
                )
            )
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
                Task {
                    // Ensure we have the latest authorization status
                    if viewModel.canRequestNotificationsAuthorisation == nil {
                        viewModel.canRequestNotificationsAuthorisation = await viewModel.canRequestNotificationAuthorisation()
                    }
                    
                    if viewModel.canRequestHealthDataAuthorisation == true {
                        viewModel.navigationDestination = .healthData
                    } else if viewModel.canRequestNotificationsAuthorisation == true {
                        viewModel.navigationDestination = .notifications
                    } else {
                        viewModel.navigationDestination = .namePhoto
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
        OnboardingCompleteAccountSetupView(
            viewModel: OnboardingCompleteAccountSetupViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                )
            )
        )
    }
    .previewEnvironment()
}
