//
//  SettingsPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI
import SwiftfulUtilities

@Observable
@MainActor
class SettingsPresenter {
    private let interactor: SettingsInteractor
    private let router: SettingsRouter
    
    private(set) var isAnonymousUser: Bool = false
    private(set) var isPremium: Bool = false
    
    let appVersion: String = SwiftfulUtilities.Utilities.appVersion ?? ""
    let appBuild: String = SwiftfulUtilities.Utilities.buildNumber ?? ""
    
    var showRatingsModal: Bool = false

    init(
        interactor: SettingsInteractor,
        router: SettingsRouter
    ) {
        self.interactor = interactor
        self.router = router
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
    
    func onSignOutPressed() {
        interactor.trackEvent(event: Event.signOutStart)
        
        Task {
            do {
                try await interactor.signOut()
                interactor.trackEvent(event: Event.signOutSuccess)
                await dismissScreen()
            } catch {
                router.showAlert(error: error)
                interactor.trackEvent(event: Event.signOutFail(error: error))
            }
        }
    }

    private func dismissScreen() async {
        router.dismissScreen()
        try? await Task.sleep(for: .seconds(1))
        interactor.updateAppState(showTabBarView: false)
    }

    func onDeleteAccountPressed() {
        interactor.trackEvent(event: Event.deleteAccountStart)

        router.showAlert(
            title: "Delete Account?",
            subtitle: "This action is permanent and cannot be undone. Your data will be deleted from our server forever.",
            buttons: {
                AnyView(
                    Button("Delete", role: .destructive, action: {
                        self.onDeleteAccountConfirmed()
                    })
                )
            }
        )
    }

    func navToManageSubscriptionView() {
        interactor.trackEvent(event: Event.navigate)
        router.showCorePaywall()
    }

    private func onDeleteAccountConfirmed() {
        interactor.trackEvent(event: Event.deleteAccountStartConfirm)

        Task {
            do {
                try await interactor.deleteAccount()
                interactor.trackEvent(event: Event.deleteAccountSuccess)
                await dismissScreen()
            } catch {
                router.showAlert(error: error)
                interactor.trackEvent(event: Event.deleteAccountFail(error: error))
            }
        }
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
        case contactUsPressed
        case ratingsPressed
        case ratingsYesPressed
        case ratingsNoPressed
        case navigate
        case dedupeWeightsStart
        case dedupeWeightsSuccess
        case dedupeWeightsFail(error: Error)

        var eventName: String {
            switch self {
            case .signOutStart:                 return "Settings_SignOut_Start"
            case .signOutSuccess:               return "Settings_SignOut_Success"
            case .signOutFail:                  return "Settings_SignOut_Fail"
            case .deleteAccountStart:           return "Settings_DeleteAccount_Start"
            case .deleteAccountStartConfirm:    return "Settings_DeleteAccount_StartConfirm"
            case .deleteAccountSuccess:         return "Settings_DeleteAccount_Success"
            case .deleteAccountFail:            return "Settings_DeleteAccount_Fail"
            case .contactUsPressed:             return "Settings_ContactUs_Press"
            case .ratingsPressed:               return "Settings_Ratings_Press"
            case .ratingsYesPressed:            return "Settings_RatingsYes_Press"
            case .ratingsNoPressed:             return "Settings_RatingsNo_Press"
            case .navigate:                     return "Settings_Navigate"
            case .dedupeWeightsStart:           return "Settings_DedupeWeights_Start"
            case .dedupeWeightsSuccess:         return "Settings_DedupeWeights_Success"
            case .dedupeWeightsFail:            return "Settings_DedupeWeights_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .signOutFail(error: let error),
                 .deleteAccountFail(error: let error),
                 .dedupeWeightsFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .signOutFail, .deleteAccountFail, .dedupeWeightsFail:
                return .severe
            case .navigate:
                return .info
            default:
                return .analytic
                
            }
        }
    }
}
