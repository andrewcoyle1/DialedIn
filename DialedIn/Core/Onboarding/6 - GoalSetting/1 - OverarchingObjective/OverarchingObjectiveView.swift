//
//  OverarchingObjectiveView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/10/2025.
//

import SwiftUI

struct OverarchingObjectiveView: View {

    @Environment(\.colorScheme) private var colorScheme
    
    @State var presenter: OverarchingObjectivePresenter

    var body: some View {
        List {
            objectiveSection
        }
        .navigationTitle("What is your goal?")
        .toolbar {
            toolbarContent
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                presenter.onContinuePressed()
            } label: {
                Text("Continue")
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .disabled(!presenter.canContinue)
            .padding(.horizontal)
        }
    }
    
    private var objectiveSection: some View {
        Section {
            ForEach(OverarchingObjective.allCases, id: \.self) { objective in
                objectiveRow(objective)
            }
            .removeListRowFormatting()
        } header: {
            Text("Choose one")
        }
    }
    
    private func objectiveRow(_ objective: OverarchingObjective) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(objective.description)
                    .font(.headline)
                Text(objective.detailedDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer(minLength: 8)
            Image(systemName: presenter.selectedObjective == objective ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(presenter.selectedObjective == objective ? Color.accent : Color.secondary)
        }
        .padding()
        .background(colorScheme.backgroundPrimary)
        .anyButton(.press) {
            presenter.selectedObjective = objective
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
    func overarchingObjectiveView(router: AnyRouter) -> some View {
        OverarchingObjectiveView(
            presenter: OverarchingObjectivePresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }
}

extension CoreRouter {
    func showOverarchingObjectiveView() {
        router.showScreen(.push) { router in
            builder.overarchingObjectiveView(router: router)
        }
    }

}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.overarchingObjectiveView(router: router)
    }
    
}
