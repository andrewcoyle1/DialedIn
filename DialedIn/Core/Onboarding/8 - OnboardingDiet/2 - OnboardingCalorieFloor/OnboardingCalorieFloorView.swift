//
//  OnboardingCalorieFloorView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/10/2025.
//

import SwiftUI

struct OnboardingCalorieFloorView: View {

    @Environment(\.colorScheme) private var colorScheme
    
    @State var presenter: OnboardingCalorieFloorPresenter

    var delegate: OnboardingCalorieFloorDelegate

    var body: some View {
        List {
            Section {
                ForEach(CalorieFloor.allCases) { type in
                    Section {
                        HStack(alignment: .center, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(type.description)
                                    .font(.headline)
                                Text(type.detailedDescription)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer(minLength: 8)
                            Image(systemName: presenter.selectedFloor == type ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(presenter.selectedFloor == type ? .accent : .secondary)
                        }
                        .padding()
                        .background(colorScheme.backgroundPrimary)
                        .onTapGesture { presenter.selectedFloor = type }
                    }
                }
                .removeListRowFormatting()
            }
        }
        .navigationTitle("Calorie floor")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            toolbarContent
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                presenter.navigateToTrainingType(dietPlanBuilder: delegate.dietPlanBuilder)
            } label: {
                Text("Continue")
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .disabled(presenter.selectedFloor == nil)
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
    func onboardingCalorieFloorView(router: AnyRouter, delegate: OnboardingCalorieFloorDelegate) -> some View {
        OnboardingCalorieFloorView(
            presenter: OnboardingCalorieFloorPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showOnboardingCalorieFloorView(delegate: OnboardingCalorieFloorDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingCalorieFloorView(router: router, delegate: delegate)
        }
    }

}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.onboardingCalorieFloorView(
            router: router,
            delegate: OnboardingCalorieFloorDelegate(
                dietPlanBuilder: .mock
            )
        )
    }
    
}
