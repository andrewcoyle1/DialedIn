//
//  DashboardViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import Foundation

protocol DashboardInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: DashboardInteractor { }

@MainActor
protocol DashboardRouter {
    func showNotificationsView()
    func showDevSettingsView()
}

extension CoreRouter: DashboardRouter { }

@Observable
@MainActor
class DashboardViewModel {
    private let interactor: DashboardInteractor
    private let router: DashboardRouter

    var showNotifications: Bool = false
    var isShowingInspector: Bool = false
    private(set) var contributionChartData: [Double] = []
    private(set) var chartEndDate: Date = Date()
        
    init(
        interactor: DashboardInteractor,
        router: DashboardRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func handleDeepLink(url: URL) {
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            // no query items
            print("NO QUERY ITEMS!")
            return
        }
        
        for queryItem in queryItems {
            print(queryItem.name)
        }
        
    }
    
    func onPushNotificationsPressed() {
        interactor.trackEvent(event: Event.onNotificationsPressed)
        router.showNotificationsView()
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case onNotificationsPressed

        var eventName: String {
            switch self {
            case .onNotificationsPressed:   return "Dashboard_NotificationsPressed"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            default:
                return .analytic

            }
        }
    }
}
