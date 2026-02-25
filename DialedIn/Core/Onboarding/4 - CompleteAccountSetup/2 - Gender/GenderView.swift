//
//  GenderView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

struct GenderView: View {

    @Environment(\.colorScheme) private var colorScheme
    
    @State var presenter: GenderPresenter

    var body: some View {
        List {
            Section {
                Group {
                    genderRow(.male)
                    genderRow(.female)
                }
                .removeListRowFormatting()
            }header: {
                Text("Select your gender")
            }
        }
        .navigationTitle("About You")
        .onAppear {
            presenter.onViewAppear()
        }
        .onDisappear {
            presenter.onViewDisappear()
        }
#if DEBUG || MOCK
.toolbar {
    toolbarContent
}
#endif
        .safeAreaInset(edge: .bottom) {
            CallToActionButton {
                presenter.onContinuePressed()
            } label: {
                Text("Continue")
            }
            .accessibilityIdentifier("Continue")
            .disabled(!presenter.canSubmit)
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
    
    private func genderRow(_ gender: Gender) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(gender.description)
                    .font(.headline)
            }
            Spacer(minLength: 8)
            Image(systemName: presenter.selectedGender == gender ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(presenter.selectedGender == gender ? Color.accent : Color.secondary)
        }
        .padding()
        .background(colorScheme.backgroundPrimary)
        .anyButton(.press) {
            presenter.selectedGender = gender
        }
    }
}

extension CoreBuilder {
    func genderView(router: AnyRouter) -> some View {
        GenderView(
            presenter: GenderPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
}

extension CoreRouter {
    func showGenderView() {
        router.showScreen(.push) { router in
            builder.genderView(router: router)
        }
    }
}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.genderView(router: router)
    }
    
}
