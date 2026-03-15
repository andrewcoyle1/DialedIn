//
//  OnboardingCompletedView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/08/2025.
//

import SwiftUI

struct OnboardingCompletedView: View {

    @Environment(\.colorScheme) private var colorScheme
    
    @State var presenter: OnboardingCompletedPresenter

    var body: some View {
        VStack {
            Spacer()
            content
            Spacer()
            
        }
        .safeAreaInset(edge: .bottom, content: {
            buttonSection
        })
        .background(colorScheme.backgroundSecondary)
        #if !DEBUG && !MOCK
        .navigationBarBackButtonHidden(true)
        #else
        .toolbar {
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
    
    private var content: some View {
        VStack {
            Image(systemName: "rectangle.stack.fill.badge.plus")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundStyle(.accent)
                .padding(.bottom, 16)
            Text("🎉 Onboarding Complete!")
                .font(.title)
                .bold()
                .padding(.bottom, 8)
            Text("You're ready to start compounding.")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 8)
        }
    }
    
    private var buttonSection: some View {
        CallToActionButton {
            presenter.onFinishButtonPressed()
        } label: {
            ZStack {
                if !presenter.isCompletingProfileSetup {
                    Text("Continue")
                } else {
                    ProgressView()
                        .tint(.white)
                }
            }
        }
        .accessibilityIdentifier("Continue")
        .disabled(presenter.isCompletingProfileSetup)
    }
}

extension CoreBuilder {
    func onboardingCompletedView(router: AnyRouter) -> some View {
        OnboardingCompletedView(
            presenter: OnboardingCompletedPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }
}

extension CoreRouter {
    func showOnboardingCompletedView() {
        router.showScreen(.push) { router in
            builder.onboardingCompletedView(router: router)
        }
    }
}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.onboardingCompletedView(router: router)
    }
    
}
