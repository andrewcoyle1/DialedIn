//
//  CoreRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/11/2025.
//

import SwiftUI
import SwiftfulRouting

@MainActor
struct CoreRouter: GlobalRouter {

    let router: AnyRouter
    let builder: CoreBuilder
}
