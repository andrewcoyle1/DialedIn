//
//  OnboardingHeightView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct OnboardingHeightView: View {

    @State var presenter: OnboardingHeightPresenter

    var delegate: OnboardingHeightDelegate

    var body: some View {
        List {
            pickerSection
            if presenter.unit == .centimeters {
                metricSection
            } else {
                imperialSection
            }
        }
        .navigationTitle("How tall are you?")
        .toolbar {
            toolbarContent
        }
    }
    
    private var pickerSection: some View {
        Section {
            Picker("Units", selection: $presenter.unit) {
                Text("Metric").tag(UnitOfLength.centimeters)
                Text("Imperial").tag(UnitOfLength.inches)
            }
            .pickerStyle(.segmented)
        }
        .removeListRowFormatting()
        
    }
    
    private var metricSection: some View {
        Section {
            VStack {
                Picker("Centimeters", selection: $presenter.selectedCentimeters) {
                    ForEach((100...250).reversed(), id: \.self) { value in
                        Text("\(value) cm").tag(value)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                .frame(maxWidth: 150)
                .clipped()
                .onChange(of: presenter.selectedCentimeters) { _, _ in
                    presenter.updateImperialFromCentimeters()
                }
            }
            .frame(maxWidth: .infinity)
        } header: {
            Text("Metric")
        }
        .removeListRowFormatting()
    }
    
    private var imperialSection: some View {
        Section {
            HStack(spacing: 12) {
                Spacer(minLength: 0)

                Picker("Feet", selection: $presenter.selectedFeet) {
                    ForEach((3...8).reversed(), id: \.self) { feet in
                        Text("\(feet) ft").tag(feet)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                .frame(maxWidth: 150)
                .clipped()
                .onChange(of: presenter.selectedFeet) { _, _ in
                    presenter.updateCentimetersFromImperial()
                }
                Spacer(minLength: 0)

                Picker("Inches", selection: $presenter.selectedInches) {
                    ForEach((0...11).reversed(), id: \.self) { inch in
                        Text("\(inch) in").tag(inch)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                .frame(maxWidth: 150)
                .clipped()
                .onChange(of: presenter.selectedInches) { _, _ in
                    presenter.updateCentimetersFromImperial()
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
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
                presenter.navigateToWeightView(userBuilder: delegate.userModelBuilder)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
        }
    }
}

#Preview {
    let builder = OnbBuilder(interactor: OnbInteractor(container: DevPreview.shared.container))
    RouterView { router in
        builder.onboardingHeightView(
            router: router,
            delegate: OnboardingHeightDelegate(userModelBuilder: UserModelBuilder.heightMock)
        )
    }
    .previewEnvironment()
}
