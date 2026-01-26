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
                HStack {
                    Image(systemName: "clipboard")
                    Text("New Program")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .tappableBackground()
                .anyButton {
                    presenter.onNewProgramPressed()
                }
                HStack {
                    Image(systemName: "dumbbell")
                    Text("New Workout")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .tappableBackground()
                .anyButton {
                    presenter.onNewEmptyWorkoutPressed()
                }
                HStack {
                    Image(systemName: "dumbbell")
                    Text("New Exercise")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .tappableBackground()
                .anyButton {
                    presenter.onNewExercisePressed()
                }
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
    
}

#Preview {
    let container = DevPreview.shared.container
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = AddTrainingDelegate()
    
    return RouterView { router in
        builder.addTrainingView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
