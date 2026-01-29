//
//  OnboardingDateOfBirthView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct OnboardingDateOfBirthView: View {

    @State var presenter: OnboardingDateOfBirthPresenter

    var delegate: OnboardingDateOfBirthDelegate

    var body: some View {
        List {
            DatePicker(selection: $presenter.dateOfBirth, displayedComponents: .date) {
                Text("When were you born?")
                    .foregroundStyle(Color.secondary)
            }
            .removeListRowFormatting()
        }
        .navigationTitle("Date of birth")
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
                presenter.navigateToOnboardingHeight(userBuilder: delegate.userModelBuilder)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
        }
    }
}

extension OnbBuilder {
    func onboardingDateOfBirthView(router: AnyRouter, delegate: OnboardingDateOfBirthDelegate) -> some View {
        OnboardingDateOfBirthView(
            presenter: OnboardingDateOfBirthPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension OnbRouter {
    func showOnboardingDateOfBirthView(delegate: OnboardingDateOfBirthDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingDateOfBirthView(router: router, delegate: delegate)
        }
    }

}

#Preview {
    let builder = OnbBuilder(interactor: OnbInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.onboardingDateOfBirthView(
            router: router,
            delegate: OnboardingDateOfBirthDelegate(
                userModelBuilder: UserModelBuilder.dobMock
            )
        )
    }
    .previewEnvironment()
}
