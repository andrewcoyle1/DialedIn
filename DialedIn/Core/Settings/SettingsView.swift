//
//  SettingsView.swift
//  AIChatCourse
//
//  Created by Andrew Coyle on 10/6/24.
//

import SwiftUI
import SwiftfulUtilities

struct SettingsView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(AppState.self) private var appState
    @Environment(LogManager.self) private var logManager
    
    @State var isPremium: Bool = false
    @State private var isAnonymousUser: Bool = false
    @State private var showCreateAccountView: Bool = false
    @State private var showAlert: AnyAppAlert?
    @State private var showRatingsModal: Bool = false
    /// View Logic
    var body: some View {
        NavigationStack {
            List {
                accountSection
                purchaseSection
                applicationSection
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showCreateAccountView, onDismiss: {
                setAnonymousAccountStatus()
            }, content: {
                CreateAccountView()
                    .presentationDetents([.medium])
            })
            .onAppear {
                setAnonymousAccountStatus()
            }
            .showCustomAlert(alert: $showAlert)
            .screenAppearAnalytics(name: "Settings")
            .showModal(showModal: $showRatingsModal) {
                ratingsModal
            }
        }
    }

    private var ratingsModal: some View {
        CustomModalView(
            title: "Are you enjoying Dialed?",
            subtitle: "We'd love to hear your feedback!",
            primaryButtonTitle: "Yes",
            primaryButtonAction: { onEnjoyingAppYesPressed() },
            secondaryButtonTitle: "Not now",
            secondaryButtonAction: { onEnjoyingAppNoPressed() }
        )
    }
    private var accountSection: some View {
        Section {
            if isAnonymousUser {
                Text("Save & back-up account")
                    .anyButton(.highlight) {
                        onCreateAccountPressed()
                    }
            } else {
                Text("Sign out")
                    .anyButton(.highlight) {
                        onSignOutPressed()
                    }
            }
            
            Text("Delete account")
                .foregroundStyle(.red)
                .anyButton(.highlight) {
                    onDeleteAccountPressed()
                }
        } header: {
            Text("Account")
        }
    }
    
    private var purchaseSection: some View {
        Section {
            NavigationLink {
                ManageSubscriptionView()
            } label: {
                Text("Account status: \(isPremium ? "PREMIUM" : "FREE")")
            }
            
        } header: {
            Text("Purchases")
        }
    }
    
    private var applicationSection: some View {
        Section {
            Button {
                onRatingsButtonPressed()
            } label: {
                Text("Rate us on the App Store")
            }

            HStack(spacing: 8) {
                Text("Version")
                Spacer(minLength: 0)
                Text(SwiftfulUtilities.Utilities.appVersion ?? "")
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 8) {
                Text("Build Number")
                Spacer(minLength: 0)
                Text(SwiftfulUtilities.Utilities.buildNumber ?? "")
                    .foregroundStyle(.secondary)
            }

            Button {
                onContactUsPressed()
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

    private func onRatingsButtonPressed() {
        logManager.trackEvent(event: Event.ratingsPressed)
        showRatingsModal = true
    }

    private func onEnjoyingAppYesPressed() {
        logManager.trackEvent(event: Event.ratingsYesPressed)
        showRatingsModal = false
        AppStoreRatingsHelper.requestRatingsReview()
    }

    private func onEnjoyingAppNoPressed() {
        logManager.trackEvent(event: Event.ratingsNoPressed)
        showRatingsModal = false
    }

    private func onContactUsPressed() {
        logManager.trackEvent(event: Event.contactUsPressed)
        let email = "andrewcoyle.1@outlook.com"
        let emailString = "mailto:\(email)"
        guard let url = URL(string: emailString), UIApplication.shared.canOpenURL(url) else {
            return
        }

        UIApplication.shared.open(url)
    }

    /// Logger Events
    
    enum Event: LoggableEvent {
        case signOutStart
        case signOutSuccess
        case signOutFail(error: Error)
        case deleteAccountStart
        case deleteAccountStartConfirm
        case deleteAccountSuccess
        case deleteAccountFail(error: Error)
        case createAccountPressed
        case contactUsPressed
        case ratingsPressed
        case ratingsYesPressed
        case ratingsNoPressed

        var eventName: String {
            switch self {
            case .signOutStart:                 return "Settings_SignOut_Start"
            case .signOutSuccess:               return "Settings_SignOut_Success"
            case .signOutFail:                  return "Settings_SignOut_Fail"
            case .deleteAccountStart:           return "Settings_DeleteAccount_Start"
            case .deleteAccountStartConfirm:    return "Settings_DeleteAccount_StartConfirm"
            case .deleteAccountSuccess:         return "Settings_DeleteAccount_Success"
            case .deleteAccountFail:            return "Settings_DeleteAccount_Fail"
            case .createAccountPressed:         return "Settings_CreateAccount_Press"
            case .contactUsPressed:             return "Settings_ContactUs_Press"
            case .ratingsPressed:               return "Settings_Ratings_Press"
            case .ratingsYesPressed:            return "Settings_RatingsYes_Press"
            case .ratingsNoPressed:             return "Settings_RatingsNo_Press"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .signOutFail(error: let error), .deleteAccountFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .signOutFail, .deleteAccountFail:
                return .severe
            default:
                return .analytic
                
            }
        }
    }
    
    /// Business Logic
    
    func setAnonymousAccountStatus() {
        isAnonymousUser = authManager.auth?.isAnonymous == true
    }
    
    func onSignOutPressed() {
        logManager.trackEvent(event: Event.signOutStart)
        Task {
            do {
                try authManager.signOut()
                userManager.signOut()
                logManager.trackEvent(event: Event.signOutSuccess)

                await dismissScreen()
            } catch {
                logManager.trackEvent(event: Event.signOutFail(error: error))

                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    private func dismissScreen() async {
        dismiss()
        // try? await Task.sleep(for: .seconds(1))
        appState.updateViewState(showTabBarView: false)
    }
    
    func onDeleteAccountPressed() {
        logManager.trackEvent(event: Event.deleteAccountStart)

        showAlert = AnyAppAlert(
            title: "Delete Account?",
            subtitle: "This action is permanent and cannot be undone. Your data will be deleted from our server forever.",
            buttons: {
                AnyView(
                    Button("Delete", role: .destructive, action: {
                        onDeleteAccountConfirmed()
                    })
                )
            }
        )
    }
    
    private func onDeleteAccountConfirmed() {
        logManager.trackEvent(event: Event.deleteAccountStartConfirm)

        Task {
            do {
                // Require recent authentication before destructive deletion
                try await authManager.reauthenticateWithApple()
                // Ensure app-side data removal completes while auth still valid,
                // then remove auth account.
                try await userManager.deleteCurrentUser()
                try await authManager.deleteAccount()
                
                logManager.deleteUserProfile()
                logManager.trackEvent(event: Event.deleteAccountSuccess)

                await dismissScreen()
            } catch {
                logManager.trackEvent(event: Event.deleteAccountFail(error: error))
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    func onCreateAccountPressed() {
        logManager.trackEvent(event: Event.createAccountPressed)

        showCreateAccountView = true
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
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: nil)))
        .environment(UserManager(services: MockUserServices(user: nil)))
        .previewEnvironment()
}
#Preview("Anonymous") {
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: true))))
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .previewEnvironment()
}
#Preview("Not anonymous") {
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: false))))
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .previewEnvironment()
}

#Preview("Premium") {
    SettingsView(isPremium: true)
        .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: false))))
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .previewEnvironment()
}
