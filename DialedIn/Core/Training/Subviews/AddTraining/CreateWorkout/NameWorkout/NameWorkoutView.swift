//
//  NameWorkoutView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI
import PhotosUI
import SwiftfulRouting

struct NameWorkoutDelegate {
    var workoutTemplate: WorkoutTemplateModel?
}

struct NameWorkoutView: View {

    @State var presenter: NameWorkoutPresenter

    var delegate: NameWorkoutDelegate

    var body: some View {
        List {
            nameSection
        }
        .navigationTitle("Name Workout")
        .toolbar {
            toolbarContent
        }
    }
    
    private var nameSection: some View {
        Section {
            TextField("Enter workout name", text: $presenter.workoutName)
        } header: {
            Text("Workout name")
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {

        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                presenter.onContinuePressed()
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
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
    let builder = CoreBuilder(container: DevPreview.shared.container())

    RouterView { router in
        builder.createWorkoutView(router: router, delegate: NameWorkoutDelegate())
    }
    .previewEnvironment()
}
