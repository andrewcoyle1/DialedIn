//
//  OnboardingActivityView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct OnboardingActivityView: View {

    @State var presenter: OnboardingActivityPresenter

    var delegate: OnboardingActivityDelegate

    var body: some View {
        List {
            dailyActivitySection
        }
        .navigationTitle("Activity Level")
        .toolbar {
            toolbarContent
        }
    }
    
    private var dailyActivitySection: some View {
        Section {
            VStack(alignment: .leading, spacing: 16) {
                Text("What's your daily activity level outside of exercise?")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)
                
                ForEach(ActivityLevel.allCases, id: \.self) { level in
                    activityRow(level)
                }
            }
            .removeListRowFormatting()
            .padding(.horizontal)
        } header: {
            Text("Daily Activity")
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
                presenter.navigateToCardioFitness(userBuilder: delegate.userModelBuilder)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(!presenter.canSubmit)
        }
    }
    
    private func activityRow(_ level: ActivityLevel) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(level.description)
                    .font(.headline)
                Text(level.detailDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer(minLength: 8)
            Image(systemName: presenter.selectedActivityLevel == level ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(presenter.selectedActivityLevel == level ? Color.accent : Color.secondary)
        }
        .contentShape(Rectangle())
        .anyButton(.press) {
            presenter.selectedActivityLevel = level
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

extension OnbBuilder {
    func onboardingActivityView(router: AnyRouter, delegate: OnboardingActivityDelegate) -> some View {
        OnboardingActivityView(
            presenter: OnboardingActivityPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension OnbRouter {
    func showOnboardingActivityView(delegate: OnboardingActivityDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingActivityView(router: router, delegate: delegate)
        }
    }

}

#Preview {
    let builder = OnbBuilder(interactor: OnbInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.onboardingActivityView(
            router: router,
            delegate: OnboardingActivityDelegate(userModelBuilder: UserModelBuilder.activityLevelMock)
        )
    }
    .previewEnvironment()
}
