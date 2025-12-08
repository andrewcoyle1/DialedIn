//
//  RootBuilder.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/12/2025.
//

import SwiftUI
import SwiftfulRouting

@MainActor
struct RootBuilder: Builder {
    let interactor: RootInteractor
    let loggedInRIB: () -> any Builder
    let loggedOutRIB: () -> any Builder
        
    func build() -> AnyView {
        appView()
            .any()
    }
}
