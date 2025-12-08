//
//  Onb.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/12/2025.
//

import SwiftUI
import SwiftfulRouting

@MainActor
struct OnbRouter: GlobalRouter {
    let router: AnyRouter
    let builder: OnbBuilder
}
