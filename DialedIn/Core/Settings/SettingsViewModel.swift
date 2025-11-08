//
//  SettingsViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI
import SwiftfulUtilities

protocol SettingsInteractor {
    var auth: UserAuthInfo? { get }
    func signOut() throws
    func logOut()
    func deleteCurrentUser() async throws
    func deleteUserProfile()
    func deleteAccount() async throws
    func reauthenticateApple() async throws
    func updateAppState(showTabBarView: Bool)
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: SettingsInteractor { }

@Observable
@MainActor
class SettingsViewModel {
    private let interactor: SettingsInteractor
    
    private(set) var isAnonymousUser: Bool = false
    private(set) var isPremium: Bool = false
    
    let appVersion: String = SwiftfulUtilities.Utilities.appVersion ?? ""
    let appBuild: String = SwiftfulUtilities.Utilities.buildNumber ?? ""
    
    var showRatingsModal: Bool = false
    var showCreateAccountView: Bool = false
    var showAlert: AnyAppAlert?
    
    init(
        interactor: SettingsInteractor
    ) {
        self.interactor = interactor
    }
    
    func onRatingsButtonPressed() {
        interactor.trackEvent(event: Event.ratingsPressed)
        showRatingsModal = true
    }

    func onEnjoyingAppYesPressed() {
        interactor.trackEvent(event: Event.ratingsYesPressed)
        showRatingsModal = false
        AppStoreRatingsHelper.requestRatingsReview()
    }

    func onEnjoyingAppNoPressed() {
        interactor.trackEvent(event: Event.ratingsNoPressed)
        showRatingsModal = false
    }

    func onContactUsPressed() {
        interactor.trackEvent(event: Event.contactUsPressed)
        let email = "andrewcoyle.1@outlook.com"
        let emailString = "mailto:\(email)"
        guard let url = URL(string: emailString), UIApplication.shared.canOpenURL(url) else {
            return
        }

        UIApplication.shared.open(url)
    }
    
    /// Business Logic
    
    func setAnonymousAccountStatus() {
        isAnonymousUser = interactor.auth?.isAnonymous == true
    }
    
    func onSignOutPressed(onDismiss: @escaping () -> Void) {
        interactor.trackEvent(event: Event.signOutStart)
        Task {
            do {
                try interactor.signOut()
                interactor.logOut()
                interactor.trackEvent(event: Event.signOutSuccess)

                onDismiss()
                interactor.updateAppState(showTabBarView: false)
            } catch {
                interactor.trackEvent(event: Event.signOutFail(error: error))

                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    private func dismissScreen(onDismiss: @escaping () -> Void) async {
        onDismiss()
    }
    
    func onDeleteAccountPressed(onDismiss: @escaping () -> Void) {
        interactor.trackEvent(event: Event.deleteAccountStart)
        nonisolated(unsafe) let onDismissCopy = onDismiss

        showAlert = AnyAppAlert(
            title: "Delete Account?",
            subtitle: "This action is permanent and cannot be undone. Your data will be deleted from our server forever.",
            buttons: {
                AnyView(
                    Button("Delete", role: .destructive, action: {
                        self.onDeleteAccountConfirmed(onDismiss: onDismissCopy)
                    })
                )
            }
        )
    }
    
    private func onDeleteAccountConfirmed(onDismiss: @escaping () -> Void) {
        interactor.trackEvent(event: Event.deleteAccountStartConfirm)

        Task {
            do {
                // Require recent authentication before destructive deletion
                try await interactor.reauthenticateApple()
                // Ensure app-side data removal completes while auth still valid,
                // then remove auth account.
                try await interactor.deleteCurrentUser()
                try await interactor.deleteAccount()
                
                interactor.deleteUserProfile()
                interactor.trackEvent(event: Event.deleteAccountSuccess)

                onDismiss()
                interactor.updateAppState(showTabBarView: false)
            } catch {
                interactor.trackEvent(event: Event.deleteAccountFail(error: error))
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    func onCreateAccountPressed() {
        interactor.trackEvent(event: Event.createAccountPressed)

        showCreateAccountView = true
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
}
