//
//  OnboardingHeightView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI
import CustomRouting

struct OnboardingHeightViewDelegate {
    var userModelBuilder: UserModelBuilder
}

struct OnboardingHeightView: View {

    @State var viewModel: OnboardingHeightViewModel

    var delegate: OnboardingHeightViewDelegate

    var body: some View {
        List {
            pickerSection
            if viewModel.unit == .centimeters {
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
            Picker("Units", selection: $viewModel.unit) {
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
                Picker("Centimeters", selection: $viewModel.selectedCentimeters) {
                    ForEach((100...250).reversed(), id: \.self) { value in
                        Text("\(value) cm").tag(value)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                .frame(maxWidth: 150)
                .clipped()
                .onChange(of: viewModel.selectedCentimeters) { _, _ in
                    viewModel.updateImperialFromCentimeters()
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

                Picker("Feet", selection: $viewModel.selectedFeet) {
                    ForEach((3...8).reversed(), id: \.self) { feet in
                        Text("\(feet) ft").tag(feet)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                .frame(maxWidth: 150)
                .clipped()
                .onChange(of: viewModel.selectedFeet) { _, _ in
                    viewModel.updateCentimetersFromImperial()
                }
                Spacer(minLength: 0)

                Picker("Inches", selection: $viewModel.selectedInches) {
                    ForEach((0...11).reversed(), id: \.self) { inch in
                        Text("\(inch) in").tag(inch)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                .frame(maxWidth: 150)
                .clipped()
                .onChange(of: viewModel.selectedInches) { _, _ in
                    viewModel.updateCentimetersFromImperial()
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
                viewModel.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                viewModel.navigateToWeightView(userBuilder: delegate.userModelBuilder)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.onboardingHeightView(
            router: router,
            delegate: OnboardingHeightViewDelegate(userModelBuilder: UserModelBuilder.heightMock)
        )
    }
    .previewEnvironment()
}
