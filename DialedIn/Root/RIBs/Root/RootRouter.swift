//
//  RootRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/12/2025.
//

import SwiftUI
import SwiftfulRouting

@MainActor
struct RootRouter: GlobalRouter {
    
    let router: AnyRouter
    let builder: RootBuilder
}
