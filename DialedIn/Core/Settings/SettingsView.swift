//
//  SettingsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/6/24.
//

import SwiftUI

struct SettingsViewDelegate {
    var path: Binding<[TabBarPathOption]>
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @State var viewModel: SettingsViewModel

    var delegate: SettingsViewDelegate

    @ViewBuilder var createAccountView: () -> AnyView

    var body: some View {
        NavigationStack {
            List {
                accountSection
                purchaseSection
                applicationSection
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $viewModel.showCreateAccountView, onDismiss: {
                viewModel.setAnonymousAccountStatus()
            }, content: {
                createAccountView()
                    .presentationDetents([.medium])
            })
            .onAppear {
                viewModel.setAnonymousAccountStatus()
            }
            .showCustomAlert(alert: $viewModel.showAlert)
            .screenAppearAnalytics(name: "Settings")
            .showModal(showModal: $viewModel.showRatingsModal) {
                ratingsModal
            }
        }
    }

    private var ratingsModal: some View {
        CustomModalView(
            title: "Are you enjoying Dialed?",
            subtitle: "We'd love to hear your feedback!",
            primaryButtonTitle: "Yes",
            primaryButtonAction: { viewModel.onEnjoyingAppYesPressed() },
            secondaryButtonTitle: "Not now",
            secondaryButtonAction: { viewModel.onEnjoyingAppNoPressed() }
        )
    }
    private var accountSection: some View {
        Section {
            if viewModel.isAnonymousUser {
                Text("Save & back-up account")
                    .anyButton(.highlight) {
                        viewModel.onCreateAccountPressed()
                    }
            } else {
                Text("Sign out")
                    .anyButton(.highlight) {
                        viewModel.onSignOutPressed(onDismiss: { dismiss() })
                    }
            }
            
            Text("Delete account")
                .foregroundStyle(.red)
                .anyButton(.highlight) {
                    viewModel.onDeleteAccountPressed(onDismiss: {
                        dismiss()
                    })
                }
        } header: {
            Text("Account")
        }
    }
    
    private var purchaseSection: some View {
        Section {
            Button {
                viewModel.navToManageSubscriptionView(path: delegate.path)
            } label: {
                Text("Account status: \(viewModel.isPremium ? "PREMIUM" : "FREE")")
            }
            
        } header: {
            Text("Purchases")
        }
    }
    
    private var applicationSection: some View {
        Section {
            Button {
                viewModel.onRatingsButtonPressed()
            } label: {
                Text("Rate us on the App Store")
            }

            HStack(spacing: 8) {
                Text("Version")
                Spacer(minLength: 0)
                Text(viewModel.appVersion)
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 8) {
                Text("Build Number")
                Spacer(minLength: 0)
                Text(viewModel.appBuild)
                    .foregroundStyle(.secondary)
            }

            Button {
                viewModel.onContactUsPressed()
            } label: {
                Text("Contact us")
            }
        } header: {
            Text("Application")
        } footer: {
            Text("Created by Andrew Coyle.\nLearn more at www.swiftful-thinking.com.")
                .baselineOffset(6)
        }
    }
}

fileprivate extension View {
    func rowFormatting() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color(uiColor: .systemBackground))
    }
}

#Preview("No auth") {
    @Previewable @State var path: [TabBarPathOption] = []
    let builder = CoreBuilder(container: DevPreview.shared.container)
    builder.settingsView(delegate: SettingsViewDelegate(path: $path))
    .previewEnvironment()
}

#Preview("Anonymous") {
    @Previewable @State var path: [TabBarPathOption] = []
    let builder = CoreBuilder(container: DevPreview.shared.container)
    builder.settingsView(delegate: SettingsViewDelegate(path: $path))
    .previewEnvironment()
}
#Preview("Not anonymous") {
    @Previewable @State var path: [TabBarPathOption] = []
    let builder = CoreBuilder(container: DevPreview.shared.container)
    builder.settingsView(delegate: SettingsViewDelegate(path: $path))
    .previewEnvironment()
}

#Preview("Premium") {
    @Previewable @State var path: [TabBarPathOption] = []
    let builder = CoreBuilder(container: DevPreview.shared.container)
    builder.settingsView(delegate: SettingsViewDelegate(path: $path))
    .previewEnvironment()
}
