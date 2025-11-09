//
//  AppViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import Foundation
import SwiftfulUtilities

protocol AppInteractor {
    var auth: UserAuthInfo? { get }
    var currentUser: UserModel? { get }
    var showTabBar: Bool { get }
    func schedulePushNotificationsForNextWeek()
    func trackEvent(event: LoggableEvent)
    func logIn(auth: UserAuthInfo, image: PlatformImage?) async throws
}

extension CoreInteractor: AppInteractor { }

@Observable
@MainActor
class AppViewModel {
    private let interactor: AppInteractor
    
    var auth: UserAuthInfo? {
        interactor.auth
    }
    
    var currentUser: UserModel? {
        interactor.currentUser
    }

    var showTabBar: Bool {
        interactor.showTabBar
    }

    init(interactor: AppInteractor) {
        self.interactor = interactor
    }
    
    func schedulePushNotifications() {
        interactor.schedulePushNotificationsForNextWeek()
    }

    func showATTPromptIfNeeded() async {
        let status = await AppTrackingTransparencyHelper.requestTrackingAuthorization()
        interactor.trackEvent(event: Event.attStatus(dict: status.eventParameters))
    }
    
    func checkUserStatus() async {
        if let user = interactor.auth {
            // User is authenticated
            interactor.trackEvent(event: Event.existingAuthStart)
            
            do {
                try await interactor.logIn(auth: user, image: nil)
            } catch {
                interactor.trackEvent(event: Event.existingAuthFail(error: error))
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        } else {
            // User is not authenticated – no-op; onboarding will be shown
        }
    }

    enum Event: LoggableEvent {
        case existingAuthStart
        case existingAuthSuccess
        case existingAuthFail(error: Error)
        case anonAuthStart
        case anonAuthSuccess
        case anonAuthFail(error: Error)
        case attStatus(dict: [String: Any])

        var eventName: String {
            switch self {
            case .existingAuthStart: return "AppView_ExistingAuth_Start"
            case .existingAuthSuccess: return "AppView_ExistingAuth_Success"
            case .existingAuthFail:  return "AppView_ExistingAuth_Fail"
            case .anonAuthStart:     return "AppView_AnonAuth_Start"
            case .anonAuthSuccess:   return "AppView_AnonAuth_Success"
            case .anonAuthFail:      return "AppView_AnonAuth_Fail"
            case .attStatus:         return "AppView_ATTStatus"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .existingAuthFail(error: let error), .anonAuthFail(error: let error):
                return error.eventParameters
            case .attStatus(dict: let dict):
                return dict
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .existingAuthFail, .anonAuthFail:
                return .severe
            default:
                return .analytic

            }
        }
    }
}
