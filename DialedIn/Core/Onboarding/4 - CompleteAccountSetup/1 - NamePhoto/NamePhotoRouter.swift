//
//  NamePhotoRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol NamePhotoRouter: GlobalRouter {
#if DEV || MOCK
func showDevSettingsView()
#endif
    func showGenderView()
}

extension CoreRouter: NamePhotoRouter { }
