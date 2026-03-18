//
//  NameWorkoutView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI
import PhotosUI

struct NameWorkoutDelegate {
    var workoutTemplate: WorkoutTemplateModel?
    var onWorkoutCreated: (@Sendable (WorkoutTemplateModel) -> Void)?
}

struct NameWorkoutView: View {

    @State var presenter: NameWorkoutPresenter

    var delegate: NameWorkoutDelegate

    var body: some View {
        List {
            Section {
                TextField("Enter workout name", text: $presenter.workoutName)
            } header: {
                Text("Workout name")
            }
        }
        .navigationTitle("Name Workout")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            CallToActionButton {
                presenter.onContinuePressed(delegate: delegate)
            } label: {
                Text("Continue")
            }
            .disabled(!presenter.canSave || presenter.isSaving)
        }
    }
}

extension CoreBuilder {
    func createWorkoutView(router: AnyRouter, delegate: NameWorkoutDelegate) -> some View {
        NameWorkoutView(
            presenter: NameWorkoutPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showNameWorkoutView(delegate: NameWorkoutDelegate) {
        router.showScreen(.push) { router in
            builder.createWorkoutView(router: router, delegate: delegate)
        }
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)

    RouterView { router in
        builder.createWorkoutView(router: router, delegate: NameWorkoutDelegate())
    }
    
}
