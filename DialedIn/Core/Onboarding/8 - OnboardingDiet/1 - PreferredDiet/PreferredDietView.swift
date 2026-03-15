//
//  PreferredDietView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/10/2025.
//

import SwiftUI

struct PreferredDietView: View {

    @Environment(\.colorScheme) private var colorScheme
    
    @State var presenter: PreferredDietPresenter

    var body: some View {
        List {
            Section {
                ForEach(PreferredDiet.allCases) { diet in
                    HStack(alignment: .center, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(diet.description)
                                .font(.headline)
                            Text(diet.detailedDescription)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 8)
                        Image(systemName: presenter.selectedDiet == diet ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(presenter.selectedDiet == diet ? .accent : .secondary)
                    }
                    .padding()
                    .background(colorScheme.backgroundPrimary)
                    .anyButton {
                        presenter.selectedDiet = diet
                    }
                }
                .removeListRowFormatting()
            }
        }
        .navigationTitle("Choose your diet")
        #if DEBUG || MOCK
        .toolbar {
            toolbarContent
        }
        #endif
        .safeAreaInset(edge: .bottom) {
            CallToActionButton {
                presenter.navigateToCalorieFloor()
            } label: {
                Text("Continue")
            }
            .accessibilityIdentifier("Continue")
            .disabled(presenter.selectedDiet == nil)
            .padding(.bottom)
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
    func preferredDietView(router: AnyRouter, isFromSettings: Bool = false) -> some View {
        PreferredDietView(
            presenter: PreferredDietPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                isFromSettings: isFromSettings
            )
        )
    }
}

extension CoreRouter {
    func showPreferredDietView() {
        router.showScreen(.push) { router in
            builder.preferredDietView(router: router)
        }
    }

    func showPreferredDietView(isFromSettings: Bool) {
        router.showScreen(.push) { router in
            builder.preferredDietView(router: router, isFromSettings: isFromSettings)
        }
    }
}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.preferredDietView(
            router: router
        )
    }
    
}
