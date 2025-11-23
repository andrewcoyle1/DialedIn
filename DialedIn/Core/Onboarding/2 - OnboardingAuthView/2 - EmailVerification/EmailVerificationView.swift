//
//  EmailVerificationView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI
import CustomRouting

struct EmailVerificationView: View {

    @Environment(\.dismiss) private var dismiss

    @State var viewModel: EmailVerificationViewModel

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
        .onFirstTask {
            viewModel.setup()
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
                viewModel.onDevSettingsPressed()
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
                viewModel.onDonePressed()
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
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.onboardingEmailVerificationView(router: router)
    }
    .previewEnvironment()
}

#Preview("Initial Send - Success") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.onboardingEmailVerificationView(router: router)
    }
    .previewEnvironment()
}

#Preview("Initial Send - Slow") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.onboardingEmailVerificationView(router: router)
    }
    .previewEnvironment()
}

#Preview("Initial Send - Failure") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.onboardingEmailVerificationView(router: router)
    }
    .previewEnvironment()
}

#Preview("Check - Not Verified") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.onboardingEmailVerificationView(router: router)
    }
    .previewEnvironment()
}

#Preview("Check - Verified") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.onboardingEmailVerificationView(router: router)
    }
    .previewEnvironment()
}

#Preview("No Current User - Error") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.onboardingEmailVerificationView(router: router)
    }
    .previewEnvironment()
}
