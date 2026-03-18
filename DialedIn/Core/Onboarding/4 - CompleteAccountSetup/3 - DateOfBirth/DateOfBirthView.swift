//
//  DateOfBirthView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

struct DateOfBirthDelegate {
    let gender: Gender
    
    static var mock: Self {
        Self(gender: .male)
    }
}

struct DateOfBirthView: View {

    @State var presenter: DateOfBirthPresenter

    var delegate: DateOfBirthDelegate

    var body: some View {
        List {
            DatePicker(selection: $presenter.dateOfBirth, displayedComponents: .date) {
                Text("When were you born?")
                    .foregroundStyle(Color.secondary)
            }
            .removeListRowFormatting()
        }
        .navigationTitle("Date of birth")
        #if DEBUG || MOCK
        .toolbar {
            toolbarContent
        }
        #endif
        .safeAreaInset(edge: .bottom) {
            CallToActionButton {
                presenter.onContinuePressed(delegate: delegate)
            } label: {
                Text("Continue")
            }
            .accessibilityIdentifier("Continue")
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
    func dateOfBirthView(router: AnyRouter, delegate: DateOfBirthDelegate) -> some View {
        DateOfBirthView(
            presenter: DateOfBirthPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showDateOfBirthView(delegate: DateOfBirthDelegate) {
        router.showScreen(.push) { router in
            builder.dateOfBirthView(router: router, delegate: delegate)
        }
    }

}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.dateOfBirthView(
            router: router,
            delegate: .mock
        )
    }
}
