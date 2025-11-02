//
//  EmailVerificationView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

struct EmailVerificationView: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(\.dismiss) private var dismiss

    @State var viewModel: EmailVerificationViewModel
    @Binding var path: [OnboardingPathOption]

    enum NavigationDestination {
        case subscription
        case completeAccountSetup
        case healthDisclaimer
        case goalSetting
        case customiseProgram
        case diet
        case completed
    }
    
    var body: some View {
        List {
            Section {
                Text("Check your inbox and click the link we sent you to activate your account before you continue. If you don't see it, check your spam folder.")
                    .multilineTextAlignment(.leading)
                    .removeListRowFormatting()
                    .padding(.horizontal)
                    .foregroundStyle(Color.secondary)
            } header: {
                Text("Verify your email")
            }
        }
        .toolbar {
            #if DEBUG || MOCK
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.showDebugView = true
                } label: {
                    Image(systemName: "info")
                }
            }
            #endif
        }
        .navigationTitle("Email Verification")
        .showCustomAlert(alert: $viewModel.showAlert)
        .showModal(showModal: Binding(
            get: { viewModel.isLoadingCheck || viewModel.isLoadingResend },
            set: { _ in }
        )) {
            ProgressView()
                .tint(.white)
        }
        .overlay(alignment: .bottom) {
            if let toastMessage = viewModel.toastMessage {
                Text(toastMessage)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.85))
                    )
                    .padding(.bottom, 80)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.smooth, value: toastMessage)
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack {
                Capsule()
                    .frame(height: AuthConstants.buttonHeight)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle((!viewModel.isLoadingCheck && !viewModel.isLoadingResend) ? Color.accent : Color.gray.opacity(0.3))
                    .padding(.horizontal)
                    .overlay(alignment: .center) {
                        if !viewModel.isLoadingCheck && !viewModel.isLoadingResend {
                            Text("Done")
                                .foregroundStyle(Color.white)
                                .padding(.horizontal, 32)
                        } else {
                            ProgressView()
                                .tint(.white)
                        }
                    }
                    .allowsHitTesting(!viewModel.isLoadingCheck && !viewModel.isLoadingResend)
                    .anyButton(.press) {
                        viewModel.onDonePressed(path: $path)
                    }
                Text("Resend Email")
                    .foregroundStyle(Color.secondary)
                    .padding(.top)
                    .allowsHitTesting(!viewModel.isLoadingCheck && !viewModel.isLoadingResend)
                    .anyButton(.press) {
                        viewModel.startSendVerificationEmail(
                            isInitial: false,
                            onDismiss: {
                                Task { @MainActor in
                                    dismiss()
                                }
                            }
                        )
                    }
            }
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $viewModel.showDebugView) {
            DevSettingsView(viewModel: DevSettingsViewModel(interactor: CoreInteractor(container: container)))
        }
        #endif
        .onFirstTask {
            viewModel.startSendVerificationEmail(isInitial: true)
            viewModel.startPolling(path: $path)
        }
        .onDisappear {
            // Clean up any ongoing tasks and reset loading states
            viewModel.currentAuthTask?.cancel()
            viewModel.currentAuthTask = nil
            viewModel.currentPollingTask?.cancel()
            viewModel.currentPollingTask = nil
            viewModel.isLoadingCheck = false
            viewModel.isLoadingResend = false
        }
    }
}

// MARK: - Previews

#Preview("Default") {
    @Previewable @State var path: [OnboardingPathOption] = []
    NavigationStack {
        EmailVerificationView(
            viewModel: EmailVerificationViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                )
            ), path: $path
        )
    }
    .previewEnvironment()
}

#Preview("Initial Send - Success") {
    @Previewable @State var path: [OnboardingPathOption] = []
    NavigationStack {
        EmailVerificationView(
            viewModel: EmailVerificationViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                )
            ), path: $path
        )
    }
    .previewEnvironment()
}

#Preview("Initial Send - Slow") {
    @Previewable @State var path: [OnboardingPathOption] = []
    NavigationStack {
        EmailVerificationView(
            viewModel: EmailVerificationViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                )
            ), path: $path
        )
    }
    .previewEnvironment()
}

#Preview("Initial Send - Failure") {
    @Previewable @State var path: [OnboardingPathOption] = []
    NavigationStack {
        EmailVerificationView(
            viewModel: EmailVerificationViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                )
            ), path: $path
        )
    }
    .previewEnvironment()
}

#Preview("Check - Not Verified") {
    @Previewable @State var path: [OnboardingPathOption] = []
    NavigationStack {
        EmailVerificationView(
            viewModel: EmailVerificationViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                )
            ), path: $path
        )
    }
    .previewEnvironment()
}

#Preview("Check - Verified") {
    @Previewable @State var path: [OnboardingPathOption] = []
    NavigationStack {
        EmailVerificationView(
            viewModel: EmailVerificationViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                )
            ), path: $path
        )
    }
    .previewEnvironment()
}

#Preview("No Current User - Error") {
    @Previewable @State var path: [OnboardingPathOption] = []
    NavigationStack {
        EmailVerificationView(
            viewModel: EmailVerificationViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                )
            ), path: $path
        )
    }
    .previewEnvironment()
}
