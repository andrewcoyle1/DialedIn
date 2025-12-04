//
//  RootBuilder.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/12/2025.
//

import SwiftUI

@MainActor
struct RootBuilder: Buildable {
    let loggedInRIB: any Buildable
    let interactor: RootInteractor
    
    init(interactor: RootInteractor, loggedInRIB: any Buildable) {
        self.interactor = interactor
        self.loggedInRIB = loggedInRIB
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
                Text("Onboarding View")
//                RouterView { router in
//                    self.onboardingWelcomeView(router: router)
//                }
            }
        )
    }

}

