//
//  RootRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/12/2025.
//

import SwiftUI
import CustomRouting

@MainActor
struct RootRouter: GlobalRouter {
    let router: Router
    let builder: RootBuilder
}
