//
//  SettingsPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class SettingsPresenter {
    private let interactor: SettingsInteractor
    private let router: SettingsRouter
    
    private(set) var isAnonymousUser: Bool = false
    private(set) var isPremium: Bool = false
    
    let appVersion: String = Utilities.appVersion ?? ""
    let appBuild: String = Utilities.buildNumber ?? ""
    
    var showRatingsModal: Bool = false

    init(
        interactor: SettingsInteractor,
        router: SettingsRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }
    
    func onViewDisappear() {
        interactor.trackEvent(event: Event.onDisappear)
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
                try await Task.sleep(for: .seconds(1))
                router.switchToOnboardingModule()
            } catch {
                router.showAlert(error: error)
                interactor.trackEvent(event: Event.signOutFail(error: error))
            }
        }
    }

    private func dismissScreen() async {
        router.dismissScreen()
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
        router.showPaywall()
    }

    func onNutritionPlanPressed() {
        interactor.trackEvent(event: Event.navigate)
        router.showPreferredDietView(isFromSettings: true)
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
        case onAppear
        case onDisappear
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
            case .onAppear:                     return "SettingsView_Appear"
            case .onDisappear:                  return "SettingsView_Disappear"
            case .signOutStart:                 return "SettingsView_SignOut_Start"
            case .signOutSuccess:               return "SettingsView_SignOut_Success"
            case .signOutFail:                  return "SettingsView_SignOut_Fail"
            case .deleteAccountStart:           return "SettingsView_DeleteAccount_Start"
            case .deleteAccountStartConfirm:    return "SettingsView_DeleteAccount_StartConfirm"
            case .deleteAccountSuccess:         return "SettingsView_DeleteAccount_Success"
            case .deleteAccountFail:            return "SettingsView_DeleteAccount_Fail"
            case .contactUsPressed:             return "SettingsView_ContactUs_Press"
            case .ratingsPressed:               return "SettingsView_Ratings_Press"
            case .ratingsYesPressed:            return "SettingsView_RatingsYes_Press"
            case .ratingsNoPressed:             return "SettingsView_RatingsNo_Press"
            case .navigate:                     return "SettingsView_Navigate"
            case .dedupeWeightsStart:           return "SettingsView_DedupeWeights_Start"
            case .dedupeWeightsSuccess:         return "SettingsView_DedupeWeights_Success"
            case .dedupeWeightsFail:            return "SettingsView_DedupeWeights_Fail"
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
