//
//  CompleteAccountSetupRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol CompleteAccountSetupRouter {
    func showDevSettingsView()
    func showNamePhotoView()
}

extension CoreRouter: CompleteAccountSetupRouter { }
