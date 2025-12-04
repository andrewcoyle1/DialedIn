//
//  OnboardingCompleteAccountSetupView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI
import CustomRouting

struct OnboardingCompleteAccountSetupView: View {

    @State var presenter: OnboardingCompleteAccountSetupPresenter

    var body: some View {
        List {
            Text("Intro to complete account setup - explain why the user needs to submit their data")
        }
        .navigationTitle("Welcome")
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

#Preview {
    let builder = OnbBuilder(interactor: OnbInteractor(container: DevPreview.shared.container))
    RouterView { router in
        builder.onboardingCompleteAccountSetupView(router: router)
    }
    .previewEnvironment()
}
