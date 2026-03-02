import SwiftUI

struct RenameWorkoutTemplateModelDelegate {
    let initialName: String
    let onSave: (String) -> Void
}

struct RenameWorkoutTemplateModelView: View {
    @State var presenter: RenameWorkoutTemplateModelPresenter
    let delegate: RenameWorkoutTemplateModelDelegate

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Day name", text: $presenter.nameText)
                        .textFieldStyle(.roundedBorder)
                }
            }
            .navigationTitle("Rename Day")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
        }
        .presentationDetents([.fraction(0.25), .fraction(0.4)])
        .presentationDragIndicator(.visible)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
                presenter.onCancelPressed()
            }
        }

        ToolbarItem(placement: .confirmationAction) {
            Button("Save") {
                presenter.onSavePressed(onSave: delegate.onSave)
            }
            .disabled(!presenter.canSave)
        }
    }
}

extension CoreBuilder {
    func renameWorkoutTemplateModelView(router: AnyRouter, delegate: RenameWorkoutTemplateModelDelegate) -> some View {
        RenameWorkoutTemplateModelView(
            presenter: RenameWorkoutTemplateModelPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                initialName: delegate.initialName
            ),
            delegate: delegate
        )
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    RouterView { router in
        builder.renameWorkoutTemplateModelView(
            router: router,
            delegate: RenameWorkoutTemplateModelDelegate(
                initialName: "Day 1",
                onSave: { _ in }
            )
        )
    }
    
}
