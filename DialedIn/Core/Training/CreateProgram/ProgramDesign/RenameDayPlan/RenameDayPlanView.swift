import SwiftUI
import SwiftfulRouting

struct RenameDayPlanDelegate {
    let initialName: String
    let onSave: (String) -> Void
}

struct RenameDayPlanView: View {
    @State var presenter: RenameDayPlanPresenter
    let delegate: RenameDayPlanDelegate

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
    func renameDayPlanView(router: AnyRouter, delegate: RenameDayPlanDelegate) -> some View {
        RenameDayPlanView(
            presenter: RenameDayPlanPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                initialName: delegate.initialName
            ),
            delegate: delegate
        )
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.renameDayPlanView(
            router: router,
            delegate: RenameDayPlanDelegate(
                initialName: "Day 1",
                onSave: { _ in }
            )
        )
    }
    .previewEnvironment()
}
