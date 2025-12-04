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
    let loggedInRIB: any Builder
    let loggedOutRIB: any Builder
    let interactor: RootInteractor
    
    init(interactor: RootInteractor, loggedInRIB: any Builder, loggedOutRIB: any Builder) {
        self.interactor = interactor
        self.loggedInRIB = loggedInRIB
        self.loggedOutRIB = loggedOutRIB
    }
    
    func build() -> AnyView {
        appView()
            .any()
    }
    
    private func appView() -> some View {
        AppView(
            presenter: AppPresenter(interactor: interactor),
            adaptiveMainView: {
                loggedInRIB.build()
            },
            onboardingWelcomeView: {
                loggedOutRIB.build()
            }
        )
    }
}
