//
//  OnboardingPreferredDietView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/10/2025.
//

import SwiftUI

struct OnboardingPreferredDietView: View {

    @Environment(\.colorScheme) private var colorScheme
    
    @State var presenter: OnboardingPreferredDietPresenter

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
        .toolbar {
            toolbarContent
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                presenter.navigateToCalorieFloor()
            } label: {
                Text("Continue")
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .disabled(presenter.selectedDiet == nil)
            .padding(.horizontal)
        }
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
    func onboardingPreferredDietView(router: AnyRouter) -> some View {
        OnboardingPreferredDietView(
            presenter: OnboardingPreferredDietPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }
}

extension CoreRouter {
    func showOnboardingPreferredDietView() {
        router.showScreen(.push) { router in
            builder.onboardingPreferredDietView(router: router)
        }
    }
}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.onboardingPreferredDietView(
            router: router
        )
    }
    
}
