//
//  SearchRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/01/2026.
//

import SwiftUI

@MainActor
protocol SearchRouter {
    func showProfileViewZoom(transitionId: String?, namespace: Namespace.ID)
}

extension CoreRouter: SearchRouter { }
