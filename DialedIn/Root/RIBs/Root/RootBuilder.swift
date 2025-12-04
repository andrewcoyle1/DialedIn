//
//  RootBuilder.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/12/2025.
//

import SwiftUI
import CustomRouting

@MainActor
struct RootBuilder: Builder {
    let interactor: RootInteractor
    let loggedInRIB: () -> any Builder
    let loggedOutRIB: () -> any Builder
        
    func build() -> AnyView {
        appView()
            .any()
    }
    
    private func appView() -> some View {
        AppView(
            presenter: AppPresenter(interactor: interactor),
            adaptiveMainView: {
                loggedInRIB().build()
            },
            onboardingWelcomeView: {
                loggedOutRIB().build()
            }
        )
    }
}
