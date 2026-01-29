//
//  OnboardingCompleteAccountSetupView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct OnboardingCompleteAccountSetupView: View {

    @State var presenter: OnboardingCompleteAccountSetupPresenter

    var body: some View {
        List {
            Section {
                Text("In order to for us to help you on your fitness journey, we need to know a few things about you. These will help us tailor our recommendations to your needs.")
            } header: {
                Text("The Basics")
            }
        }
        .navigationTitle("Complete Account")
        .navigationBarBackButtonHidden()
        .toolbar {
            toolbarContent
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                presenter.handleNavigation()
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
        }
    }
}

extension OnbBuilder {
    func onboardingCompleteAccountSetupView(router: AnyRouter) -> some View {
        OnboardingCompleteAccountSetupView(
            presenter: OnboardingCompleteAccountSetupPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
    }
}

extension OnbRouter {
    func showOnboardingCompleteAccountSetupView() {
        router.showScreen(.push) { router in
            builder.onboardingCompleteAccountSetupView(router: router)
        }
    }
}

#Preview {
    let builder = OnbBuilder(interactor: OnbInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.onboardingCompleteAccountSetupView(router: router)
    }
    .previewEnvironment()
}
