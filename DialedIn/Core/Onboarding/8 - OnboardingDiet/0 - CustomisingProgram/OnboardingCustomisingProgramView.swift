//
//  OnboardingCustomisingProgramView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/10/2025.
//

import SwiftUI

struct OnboardingCustomisingProgramView: View {

    @State var presenter: OnboardingCustomisingProgramPresenter

    var body: some View {
        List {
            dietSection
        }
        .navigationTitle("Customise Program")
        .toolbar {
            toolbarContent
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                presenter.navigateToPreferredDiet()
            } label: {
                Text("Continue")
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .padding(.horizontal)
        }
    }
        
    private var dietSection: some View {
        Section {
            VStack(alignment: .leading) {
                Text("Let's get to work creating a custom diet program tuned to your needs. This will evolve over time as we learn how your body responds to the diet and make the necessary changes. This can always be manually altered later if you would like a specific change.")
                Text("We'll start with a few questions to get you started.")
                    .padding(.top)
            }
            .removeListRowFormatting()
            .padding(.horizontal)
            .foregroundStyle(Color.secondary)
        } header: {
            Text("Diet Program")
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
    }
}

extension CoreBuilder {
    func onboardingCustomisingProgramView(router: AnyRouter) -> some View {
        OnboardingCustomisingProgramView(
            presenter: OnboardingCustomisingProgramPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }
}

extension CoreRouter {
    func showOnboardingCustomisingProgramView() {
        router.showScreen(.push) { router in
            builder.onboardingCustomisingProgramView(router: router)
        }
    }
}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.onboardingCustomisingProgramView(router: router)
    }
    
}
