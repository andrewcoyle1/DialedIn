//
//  HealthDisclaimerView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/10/2025.
//

import SwiftUI

struct HealthDisclaimerView: View {

    @State var presenter: HealthDisclaimerPresenter

    var body: some View {
        List {
            disclaimerSection
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Notice")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .safeAreaInset(edge: .bottom) {
            buttonSection
        }
        .toolbar {
            toolbarContent
        }
    }
    
    private var disclaimerSection: some View {
        Section {
            Text(presenter.disclaimerString)
        } header: {
            Text("Health Disclaimer")
        }
    }
    
    private var buttonSection: some View {
        VStack {
            Toggle(isOn: $presenter.acceptedTerms) {
                Text("I acknowledge and accept the Terms of the Health Disclaimer")
                    .font(.callout)
            }
            Toggle(isOn: $presenter.acceptedPrivacy) {
                Text("I acknowledge and accept the Terms of the Consumer Health Privacy Notice")
                    .font(.callout)
            }
            
            Button {
                presenter.onContinuePressed()
            } label: {
                Text("Continue")
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .disabled(!presenter.canContinue)

        }
        .padding()
        .background(.bar)
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
    }
}

extension CoreBuilder {
    func healthDisclaimerView(router: AnyRouter) -> some View {
        HealthDisclaimerView(
            presenter: HealthDisclaimerPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }
}

extension CoreRouter {
    func showHealthDisclaimerView() {
        router.showScreen(.push) { router in
            builder.healthDisclaimerView(router: router)
        }
    }

}

#Preview("Health Disclaimer") {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.healthDisclaimerView(router: router)
    }
    
}
