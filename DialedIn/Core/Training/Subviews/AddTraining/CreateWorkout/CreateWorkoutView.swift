//
//  CreateWorkoutView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI
import PhotosUI

struct CreateWorkoutDelegate {
    var workoutTemplate: WorkoutTemplateModel?
    var onWorkoutCreated: (@Sendable (WorkoutTemplateModel) -> Void)?
}

struct CreateWorkoutView: View {

    @State var presenter: CreateWorkoutPresenter

    var delegate: CreateWorkoutDelegate

    var body: some View {
        VStack(spacing: 0) {
            ImageLoaderView()
                .ignoresSafeArea()
                .frame(maxHeight: 400)
            VStack(alignment: .leading) {
                Text("Create Workout")
                    .font(.title)
                    .fontWeight(.bold)
                Text("You will create a new workout for you library.")
            }
            .padding(.top)
            .frame(maxWidth: .infinity)
            Spacer()
        }
        .safeAreaInset(edge: .bottom) {
            CallToActionButton {
                presenter.onContinuePressed(delegate: delegate)
            } label: {
                Text("Continue")
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(role: .close) {
                    presenter.cancel()
                }
            }
        }
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
        RouterView { router in
            builder.createWorkoutView(router: router, delegate: CreateWorkoutDelegate(workoutTemplate: .mock))
        }
    
}

extension CoreBuilder {
    func createWorkoutView(router: AnyRouter, delegate: CreateWorkoutDelegate) -> some View {
        CreateWorkoutView(
            presenter: CreateWorkoutPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showCreateWorkoutView(delegate: CreateWorkoutDelegate) {
        router.showScreen(.fullScreenCover) { router in
            builder.createWorkoutView(router: router, delegate: delegate)
        }
    }
}
