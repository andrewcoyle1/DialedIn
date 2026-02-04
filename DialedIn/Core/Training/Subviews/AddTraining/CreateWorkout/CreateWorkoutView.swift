//
//  CreateWorkoutView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI
import PhotosUI
import SwiftfulRouting

struct CreateWorkoutDelegate {
    var workoutTemplate: WorkoutTemplateModel?
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
        .toolbar {
            toolbarContent
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(role: .close) {
                presenter.cancel()
            }
        }
        
        ToolbarSpacer(.flexible, placement: .bottomBar)
        
        ToolbarItem(placement: .bottomBar) {
            Button {
                presenter.onContinuePressed()
            } label: {
                Image(systemName: "chevron.right")
            }
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container())
        RouterView { router in
            builder.createWorkoutView(router: router, delegate: CreateWorkoutDelegate(workoutTemplate: .mock))
        }
    .previewEnvironment()
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
