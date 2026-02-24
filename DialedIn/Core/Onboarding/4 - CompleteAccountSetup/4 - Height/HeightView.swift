//
//  HeightView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

struct HeightDelegate {
    let gender: Gender
    let dateOfBirth: Date
    
    init(delegate: DateOfBirthDelegate, dateOfBirth: Date) {
        self.gender = delegate.gender
        self.dateOfBirth = dateOfBirth
    }
    
    static var mock: Self {
        Self(delegate: .mock, dateOfBirth: Date.now.addingTimeInterval(days: (-365*25)))
    }
}

struct HeightView: View {

    @State var presenter: HeightPresenter

    var delegate: HeightDelegate

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
        .safeAreaInset(edge: .bottom) {
            Button {
                presenter.onContinuePressed(delegate: delegate)
            } label: {
                Text("Continue")
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .padding(.horizontal)
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
    func heightView(router: AnyRouter, delegate: HeightDelegate) -> some View {
        HeightView(
            presenter: HeightPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showHeightView(delegate: HeightDelegate) {
        router.showScreen(.push) { router in
            builder.heightView(router: router, delegate: delegate)
        }
    }
}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.heightView(
            router: router,
            delegate: .mock
        )
    }
    
}
