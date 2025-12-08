//
//  OnbBuilder.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/12/2025.
//

import SwiftUI
import SwiftfulRouting

@MainActor
struct OnbBuilder: Builder {
    let interactor: OnbInteractor
        
    func build() -> AnyView {
        onboardingWelcomeView()
            .any()
    }
}
