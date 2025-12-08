//
//  OnboardingWeightView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct OnboardingWeightView: View {

    @State var presenter: OnboardingWeightPresenter

    var delegate: OnboardingWeightDelegate

    var body: some View {
        List {
            pickerSection
            
            if presenter.unit == .kilograms {
                metricSection
            } else {
                imperialSection
            }
        }
        .navigationTitle("What's your weight?")
        .toolbar {
            toolbarContent
        }
    }
    
    private var pickerSection: some View {
        Section {
            Picker("Units", selection: $presenter.unit) {
                Text("Metric").tag(UnitOfWeight.kilograms)
                Text("Imperial").tag(UnitOfWeight.pounds)
            }
            .pickerStyle(.segmented)
        }
        .removeListRowFormatting()
    }
    
    private var metricSection: some View {
        Section {
            Picker("Kilograms", selection: $presenter.selectedKilograms) {
                ForEach((30...200).reversed(), id: \.self) { value in
                    Text("\(value) kg").tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)
            .clipped()
            .onChange(of: presenter.selectedKilograms) { _, _ in
                presenter.updatePoundsFromKilograms()
            }
        } header: {
            Text("Metric")
        }
        .removeListRowFormatting()
    }
    
    private var imperialSection: some View {
        Section {
            Picker("Pounds", selection: $presenter.selectedPounds) {
                ForEach((66...440).reversed(), id: \.self) { value in
                    Text("\(value) lbs").tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)
            .clipped()
            .onChange(of: presenter.selectedPounds) { _, _ in
                presenter.updateKilogramsFromPounds()
            }
        } header: {
            Text("Imperial")
        }
        .removeListRowFormatting()
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
                presenter.navigateToExerciseFrequency(userBuilder: delegate.userModelBuilder)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
        }
    }
}

extension OnbBuilder {
    func onboardingWeightView(router: AnyRouter, delegate: OnboardingWeightDelegate) -> some View {
        OnboardingWeightView(
            presenter: OnboardingWeightPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension OnbRouter {
    func showOnboardingWeightView(delegate: OnboardingWeightDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingWeightView(router: router, delegate: delegate)
        }
    }

}

#Preview {
    let builder = OnbBuilder(interactor: OnbInteractor(container: DevPreview.shared.container))
    RouterView { router in
        builder.onboardingWeightView(
            router: router,
            delegate: OnboardingWeightDelegate(userModelBuilder: UserModelBuilder.weightMock)
        )
    }
    .previewEnvironment()
}
