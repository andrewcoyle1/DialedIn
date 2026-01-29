//
//  OnboardingGenderView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct OnboardingGenderView: View {

    @State var presenter: OnboardingGenderPresenter

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    genderRow(.male)
                    genderRow(.female)
                }
                .removeListRowFormatting()
                .padding(.horizontal)
            } header: {
                Text("Select your gender")
            }
        }
        .navigationTitle("About You")
        .screenAppearAnalytics(name: "OnboardingSelectGender")
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
                presenter.navigateToDateOfBirth()
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(!presenter.canSubmit)
        }
    }
    
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
        .contentShape(Rectangle())
        .anyButton(.press) {
            presenter.selectedGender = gender
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

extension OnbBuilder {
    func onboardingGenderView(router: AnyRouter) -> some View {
        OnboardingGenderView(
            presenter: OnboardingGenderPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
    }
}

extension OnbRouter {
    func showOnboardingGenderView() {
        router.showScreen(.push) { router in
            builder.onboardingGenderView(router: router)
        }
    }
}

#Preview {
    let builder = OnbBuilder(interactor: OnbInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.onboardingGenderView(router: router)
    }
    .previewEnvironment()
}
