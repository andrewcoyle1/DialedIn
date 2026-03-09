//
//  CustomisingDietProgramView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/10/2025.
//

import SwiftUI

struct CustomisingDietProgramView: View {

    @State var presenter: CustomisingDietProgramPresenter

    var body: some View {
        List {
            dietSection
        }
        .navigationTitle("Customise Program")
#if DEBUG || MOCK
.toolbar {
    toolbarContent
}
#endif
        .safeAreaInset(edge: .bottom) {
            CallToActionButton {
                presenter.navigateToPreferredDiet()
            } label: {
                Text("Continue")
            }
            .accessibilityIdentifier("Continue")
        }
    }
        
    private var dietSection: some View {
        Section {
            Text("Let's get to work creating a custom diet program tuned to your needs. This will evolve over time as we learn how your body responds to the diet and make the necessary changes. This can always be manually altered later if you would like a specific change.")
        } header: {
            Text("Diet Program")
        } footer: {
            Text("We'll start with a few questions to get you started.")
        }
    }
    
    #if DEBUG || MOCK
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
    }
    #endif
}

extension CoreBuilder {
    func customisingDietProgramView(router: AnyRouter) -> some View {
        CustomisingDietProgramView(
            presenter: CustomisingDietProgramPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }
}

extension CoreRouter {
    func showCustomisingDietProgramView() {
        router.showScreen(.push) { router in
            builder.customisingDietProgramView(router: router)
        }
    }
}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.customisingDietProgramView(router: router)
    }
    
}
