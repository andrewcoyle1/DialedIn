//
//  CalorieFloorView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/10/2025.
//

import SwiftUI

struct CalorieFloorDelegate {
    let preferredDiet: PreferredDiet
    var isFromSettings: Bool = false

    static var mock: Self {
        Self(preferredDiet: .balanced)
    }
}

struct CalorieFloorView: View {

    @Environment(\.colorScheme) private var colorScheme
    
    @State var presenter: CalorieFloorPresenter

    var delegate: CalorieFloorDelegate

    var body: some View {
        List {
            Section {
                ForEach(CalorieFloor.allCases) { type in
                    typeRow(type)
                }
                .removeListRowFormatting()
            }
        }
        .navigationTitle("Calorie floor")
        .navigationBarTitleDisplayMode(.large)
        #if DEBUG || MOCK
        .toolbar {
            toolbarContent
        }
        #endif
        .safeAreaInset(edge: .bottom) {
            CallToActionButton {
                presenter.onContinuePressed(delegate: delegate)
            } label: {
                Text("Continue")
            }
            .accessibilityIdentifier("Continue")
            .disabled(presenter.selectedFloor == nil)
            .padding(.bottom)
        }
    }
    
    private func typeRow(_ type: CalorieFloor) -> some View {
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
    func calorieFloorView(router: AnyRouter, delegate: CalorieFloorDelegate) -> some View {
        CalorieFloorView(
            presenter: CalorieFloorPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showCalorieFloorView(delegate: CalorieFloorDelegate) {
        router.showScreen(.push) { router in
            builder.calorieFloorView(router: router, delegate: delegate)
        }
    }

}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.calorieFloorView(
            router: router,
            delegate: .mock
        )
    }
    
}
