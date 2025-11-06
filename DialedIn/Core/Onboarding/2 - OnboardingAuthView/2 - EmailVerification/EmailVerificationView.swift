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

    var body: some View {
        List {
            listContent
        }
        .toolbar {
            toolbarContent
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
                toastMessageSection(toastMessage: toastMessage)
            }
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $viewModel.showDebugView) {
            DevSettingsView(viewModel: DevSettingsViewModel(interactor: CoreInteractor(container: container)))
        }
        #endif
        .onFirstTask {
            viewModel.setup(path: $path)
        }
        .onDisappear {
            viewModel.cleanUp()
        }
    }

    private var listContent: some View {
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

    private func toastMessageSection(toastMessage: String) -> some View {
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
        ToolbarItem(placement: .bottomBar) {
            Button {
                viewModel.startSendVerificationEmail(
                    isInitial: false,
                    onDismiss: {
                        Task { @MainActor in
                            dismiss()
                        }
                    }
                )
            } label: {
                Image(systemName: "arrow.trianglehead.clockwise")
            }
            .disabled(viewModel.isLoadingCheck || viewModel.isLoadingResend)
        }
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                viewModel.onDonePressed(path: $path)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(viewModel.isLoadingCheck || viewModel.isLoadingResend)
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
