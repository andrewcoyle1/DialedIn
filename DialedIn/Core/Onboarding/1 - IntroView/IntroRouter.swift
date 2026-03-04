//
//  IntroRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol IntroRouter: GlobalRouter {
#if DEV || MOCK
func showDevSettingsView()
#endif
    func showAuthView()
}

extension CoreRouter: IntroRouter { }
