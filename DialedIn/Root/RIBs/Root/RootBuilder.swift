//
//  RootBuilder.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/12/2025.
//

import SwiftUI

@MainActor
struct RootBuilder {
    let interactor: RootInteractor
    
    init(container: DependencyContainer) {
        interactor = RootInteractor(container: container)
    }
    
    func build() -> some View {
        appView()
    }
    
    private func appView() -> some View {
        AppView(
            presenter: AppPresenter(interactor: interactor),
            adaptiveMainView: {
                Text("Main View")
//                self.adaptiveMainView()
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

