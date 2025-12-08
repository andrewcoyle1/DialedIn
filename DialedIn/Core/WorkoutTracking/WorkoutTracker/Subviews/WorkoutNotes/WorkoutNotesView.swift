//
//  WorkoutNotesView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/12/2025.
//

import SwiftUI

struct WorkoutNotesView: View {

    @State var presenter: WorkoutNotesPresenter
    var delegate: WorkoutNotesDelegate

    var body: some View {
        VStack {
            TextEditor(text: delegate.notes)
                .padding()

            Spacer()
        }
        .navigationTitle("Workout Notes")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    presenter.onDismissPressed()
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    delegate.onSave()
                    presenter.onDismissPressed()
                }
            }
        }
    }
}

extension CoreBuilder {
    func workoutNotesView(router: AnyRouter, delegate: WorkoutNotesDelegate) -> some View {
        WorkoutNotesView(
            presenter: WorkoutNotesPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showWorkoutNotesView(delegate: WorkoutNotesDelegate) {
        router.showScreen(.sheet) { router in
            builder.workoutNotesView(router: router, delegate: delegate)
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.workoutNotesView(
            router: router,
            delegate: WorkoutNotesDelegate(
                notes: Binding.constant(""),
                onSave: {
                    
                }
            )
        )
    }
}
