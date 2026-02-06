import SwiftUI

struct AddTrainingDelegate {
    var onSelectProgram: (() -> Void)?
    var onSelectWorkout: (() -> Void)?
    var onSelectExercise: (() -> Void)?
}

struct AddTrainingView: View {
    
    @State var presenter: AddTrainingPresenter
    let delegate: AddTrainingDelegate
    
    var body: some View {
        List {
            Section {
                CustomListCellView(sfSymbolName: "clipboard", title: "New Program")
                .tappableBackground()
                .anyButton {
                    presenter.onNewProgramPressed()
                }
                .removeListRowFormatting()
                
                CustomListCellView(sfSymbolName: "dumbbell", title: "New Workout")
                .tappableBackground()
                .anyButton {
                    presenter.onNewEmptyWorkoutPressed()
                }
                .removeListRowFormatting()

                CustomListCellView(sfSymbolName: "list.bullet", title: "New Exercise")
                .tappableBackground()
                .anyButton {
                    presenter.onNewExercisePressed()
                }
                .removeListRowFormatting()

            }
            .listSectionMargins(.top, 0)
        }
        .navigationTitle("Add")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
            .screenAppearAnalytics(name: "AddTrainingView")
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                presenter.dismissScreen()
            } label: {
                Image(systemName: "xmark")
            }
        }
    }
}

extension CoreBuilder {
    
    func addTrainingView(router: Router, delegate: AddTrainingDelegate) -> some View {
        AddTrainingView(
            presenter: AddTrainingPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                delegate: delegate
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showAddTrainingView(delegate: AddTrainingDelegate, onDismiss: (() -> Void)? = nil) {
        router.showScreen(.sheetConfig(config: ResizableSheetConfig(detents: [.fraction(0.25)]))) { router in
            builder.addTrainingView(router: router, delegate: delegate)
        }
    }

    func showAddTrainingViewZoom(delegate: AddTrainingDelegate, transitionId: String?, namespace: Namespace.ID) {
        router.showScreenWithZoomTransition(
            .sheetConfig(config: ResizableSheetConfig(detents: [.fraction(0.25)])),
            transitionID: transitionId,
            namespace: namespace) { router in
                builder.addTrainingView(router: router, delegate: delegate)
            }
    }

}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = AddTrainingDelegate()
    
    return RouterView { router in
        builder.addTrainingView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
