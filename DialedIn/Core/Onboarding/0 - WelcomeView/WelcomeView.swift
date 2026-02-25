//
//  WelcomeView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/08/2025.
//

import SwiftUI

struct WelcomeDelegate {
    var eventParameters: [String: Any]? {
        nil
    }
}

struct WelcomeView: View {
    
    @State var presenter: WelcomePresenter
    let delegate: WelcomeDelegate
    
    var body: some View {
        VStack(spacing: 8) {
            ImageLoaderView(urlString: presenter.imageName)
                .ignoresSafeArea()
            
            titleSection
                .padding(.top, 8)

            Spacer()

            policyLinks
        }
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
        .padding(.bottom)
#if DEBUG || MOCK
        .toolbar {
            toolbarContent
        }
        #endif
        .safeAreaInset(edge: .bottom) {
            CallToActionButton {
                presenter.onContinuePressed()
            } label: {
                Text("Get Started")
            }
            .accessibilityIdentifier("GetStartedButton")
            .disabled(presenter.currentUser == nil)
        }
    }
    
#if DEBUG || MOCK
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
    }
#endif

    private var titleSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "gauge.with.needle.fill")
                .font(.system(size: 40))
                .foregroundStyle(Color.accent)
            Text("Dialed")
                .font(.largeTitle)
                .fontWeight(.semibold)
            Text("A better way to manage your training")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
        }
        .padding(.top, 24)
    }
    
    private var policyLinks: some View {
        HStack(spacing: 8) {
            Link(destination: URL(string: Constants.termsofServiceURL)!) {
                Text("Terms of Service")
            }
            
            Circle()
                .fill(.accent)
                .frame(width: 4, height: 4)
            
            Link(destination: URL(string: Constants.privacyPolicyURL)!) {
                Text("Privacy Policy")
            }
        }
    }
}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))

    builder.onboardingFlow()
}

extension CoreBuilder {
    
    func onboardingFlow() -> some View {
        RouterView { router in
            self.welcomeView(router: router)
        }
    }
    
    private func welcomeView(router: AnyRouter, delegate: WelcomeDelegate = WelcomeDelegate()) -> some View {
        WelcomeView(
            presenter: WelcomePresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
}
