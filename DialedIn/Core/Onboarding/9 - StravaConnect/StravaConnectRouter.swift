//
//  StravaConnectRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 09/03/2026.
//

@MainActor
protocol StravaConnectRouter: GlobalRouter {
    func showOnboardingCompletedView()
}

extension CoreRouter: StravaConnectRouter { }
