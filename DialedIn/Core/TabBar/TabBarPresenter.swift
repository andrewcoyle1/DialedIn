//
//  TabBarPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class TabBarPresenter {
    
    private let interactor: TabBarInteractor
    private let router: TabBarRouter

    var activeSession: WorkoutSessionModel? {
        interactor.activeSession
    }
    
    var draftMeal: MealLogModel? {
        interactor.draftMeal
    }
    
    var showTabAccessory: Bool {
        activeSession != nil || draftMeal != nil
    }
    
    var tabAccessoryWidth: CGFloat = 400

    /// Which tab is showing, keyed by `TabBarScreen.title`. Held here so a `compound://` link or a
    /// push notification can change it; the `TabView` had no selection binding at all before, so
    /// nothing outside the app could steer it.
    var selectedTabTitle: String = DeepLink.Tab.dashboard.title

    /// Applies a destination arriving from outside the app.
    func handle(_ deepLink: DeepLink) {
        switch deepLink {
        case .tab(let tab):
            interactor.trackEvent(
                eventName: "TabBarView_DeepLink_Tab",
                parameters: ["tab": tab.rawValue],
                type: .analytic
            )
            selectedTabTitle = tab.title
        }
    }

    /// Unrecognised links are tracked and dropped rather than guessed at — landing somewhere
    /// arbitrary is worse than doing nothing.
    func onOpenURL(_ url: URL) {
        guard let deepLink = DeepLink(url: url) else {
            interactor.trackEvent(
                eventName: "TabBarView_DeepLink_Unrecognised",
                parameters: ["url": url.absoluteString],
                type: .warning
            )
            return
        }
        handle(deepLink)
    }

    func onPushNotificationReceived(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let deepLink = DeepLink(pushUserInfo: userInfo)
        else {
            return
        }
        handle(deepLink)
    }

    init(
        interactor: TabBarInteractor,
        router: TabBarRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
}
