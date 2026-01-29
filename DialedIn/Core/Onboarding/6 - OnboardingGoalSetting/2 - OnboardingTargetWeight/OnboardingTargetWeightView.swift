//
//  OnboardingTargetWeightView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct OnboardingTargetWeightView: View {

    @State var presenter: OnboardingTargetWeightPresenter

    var delegate: OnboardingTargetWeightDelegate

    var body: some View {
        List {
            if presenter.didInitialize && presenter.weightUnit == .kilograms {
                kilogramsSection
            } else if presenter.didInitialize {
                poundsSection
            } else {
                loadingSection
            }
        }
        .navigationTitle("Target Weight")
        .onFirstAppear {
            presenter.onAppear(weightGoalBuilder: delegate.weightGoalBuilder)
        }
        .toolbar {
            toolbarSection
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarSection: some ToolbarContent {
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
                presenter.navigateToWeightRate(weightGoalBuilder: delegate.weightGoalBuilder)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(!presenter.canContinue)
        }
    }
    
    private var kilogramsSection: some View {
        Section {
            Picker("Kilograms", selection: $presenter.selectedKilograms) {
                ForEach(presenter.kilogramRange(weightGoalBuilder: delegate.weightGoalBuilder).reversed(), id: \.self) { value in
                    Text("\(value) kg").tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)
            .clipped()
            .onChange(of: presenter.selectedKilograms) { _, _ in
                presenter.updateFromKilograms()
            }
        } header: {
            Text("Metric")
        }
        .removeListRowFormatting()
    }
    
    private var poundsSection: some View {
        Section {
            Picker("Pounds", selection: $presenter.selectedPounds) {
                ForEach(presenter.poundRange(weightGoalBuilder: delegate.weightGoalBuilder).reversed(), id: \.self) { value in
                    Text("\(value) lbs").tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)
            .clipped()
            .onChange(of: presenter.selectedPounds) { _, _ in
                presenter.updateFromPounds()
            }
        } header: {
            Text("Imperial")
        }
        .removeListRowFormatting()
    }
    
    private var loadingSection: some View {
        Section {
            ProgressView()
                .frame(height: 150)
                .frame(maxWidth: .infinity)
        }
        .removeListRowFormatting()
    }
}

extension OnbBuilder {
    func onboardingTargetWeightView(router: AnyRouter, delegate: OnboardingTargetWeightDelegate) -> some View {
        OnboardingTargetWeightView(
            presenter: OnboardingTargetWeightPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension OnbRouter {
    func showOnboardingTargetWeightView(delegate: OnboardingTargetWeightDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingTargetWeightView(router: router, delegate: delegate)
        }
    }
}

#Preview("Gain Weight") {
    let builder = OnbBuilder(interactor: OnbInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.onboardingTargetWeightView(
            router: router,
            delegate: OnboardingTargetWeightDelegate(weightGoalBuilder: .targetWeightMock)
        )
    }
    .previewEnvironment()
}

#Preview("Lose Weight") {
    let builder = OnbBuilder(interactor: OnbInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.onboardingTargetWeightView(
            router: router,
            delegate: OnboardingTargetWeightDelegate(weightGoalBuilder: .targetWeightMock)
        )
    }
    .previewEnvironment()
}
