//
//  CalorieDistributionView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/10/2025.
//

import SwiftUI

struct CalorieDistributionDelegate {
    let preferredDiet: PreferredDiet
    let calorieFloor: CalorieFloor
    var isFromSettings: Bool

    init(delegate: CalorieFloorDelegate, calorieFloor: CalorieFloor) {
        self.preferredDiet = delegate.preferredDiet
        self.calorieFloor = calorieFloor
        self.isFromSettings = delegate.isFromSettings
    }
    
    static var mock: Self {
        Self(delegate: .mock, calorieFloor: .standard)
    }
}

struct CalorieDistributionView: View {

    @Environment(\.colorScheme) private var colorScheme
    
    @State var presenter: CalorieDistributionPresenter

    var delegate: CalorieDistributionDelegate

    var body: some View {
        List {
            itemSection
        }
        .navigationTitle("Calorie distribution")
#if DEBUG || MOCK
.toolbar {
    toolbarContent
}
#endif
        .safeAreaInset(edge: .bottom) {
            CallToActionButton {
                presenter.navigateToProteinIntake(delegate: delegate)
            } label: {
                Text("Continue")
            }
            .accessibilityIdentifier("Continue")
            .disabled(presenter.selectedCalorieDistribution == nil)
        }
    }
    
    private var itemSection: some View {
        Section {
            ForEach(CalorieDistribution.allCases) { type in
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(type.description)
                            .font(.headline)
                        Text(type.detailedDescription)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 8)
                    Image(systemName: presenter.selectedCalorieDistribution == type ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(presenter.selectedCalorieDistribution == type ? .accent : .secondary)
                }
                .padding()
                .background(colorScheme.backgroundPrimary)
                .anyButton {
                    presenter.selectedCalorieDistribution = type
                }
            }
            .removeListRowFormatting()
        }
    }
    
    #if DEBUG || MOCK
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
    }
    #endif
}

extension CoreBuilder {
    func calorieDistributionView(router: AnyRouter, delegate: CalorieDistributionDelegate) -> some View {
        CalorieDistributionView(
            presenter: CalorieDistributionPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showCalorieDistributionView(delegate: CalorieDistributionDelegate) {
        router.showScreen(.push) { router in
            builder.calorieDistributionView(router: router, delegate: delegate)
        }
    }
}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.calorieDistributionView(
            router: router,
            delegate: .mock
        )
    }
    
}
