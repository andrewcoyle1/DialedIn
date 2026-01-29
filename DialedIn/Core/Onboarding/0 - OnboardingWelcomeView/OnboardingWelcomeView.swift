//
//  OnboardingWelcomeView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/08/2025.
//

import SwiftUI
import SwiftfulRouting

struct OnboardingWelcomeView: View {
    
    @State var presenter: OnboardingWelcomePresenter

    var body: some View {
        VStack(spacing: 8) {
            ImageLoaderView(urlString: presenter.imageName)
                .ignoresSafeArea()
            titleSection
                .padding(.top, 8)

            Spacer()

            policyLinks
        }
        .padding(.bottom)
        .toolbar {
            toolbarContent
        }
        .screenAppearAnalytics(name: "Welcome")
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
                presenter.navToAppropriateView()
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
        }
    }
    
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

extension OnbBuilder {
    func onboardingWelcomeView(router: AnyRouter) -> some View {
        OnboardingWelcomeView(
            presenter: OnboardingWelcomePresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
    }
}

#Preview("Functioning") {
    let builder = OnbBuilder(interactor: OnbInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.onboardingWelcomeView(router: router)
    }
        .previewEnvironment()
}
