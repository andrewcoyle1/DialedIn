import SwiftUI

struct ExerciseSettingsDelegate {
    var exercise: ExerciseModel
    var eventParameters: [String: Any]? {
        nil
    }
}

struct ExerciseSettingsView: View {

    @State var presenter: ExerciseSettingsPresenter
    let delegate: ExerciseSettingsDelegate

    var body: some View {
        List {
            Section {
                CustomLabelButtonView(
                    symbolName: "info.circle",
                    title: "Info",
                    subtitle: delegate.exercise.description ?? "View instructions, exercise details, and history"
                ) {
                    Button {
                        presenter.onInfoPressed()
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                }
                CustomLabelButtonView(
                    symbolName: "scalemass",
                    title: "Weights",
                    subtitle: presenter.weightsSubtitle
                ) {
                    Button {
                        presenter.onWeightsPressed()
                    } label: {
                        Text("Edit")
                    }
                    .buttonStyle(.bordered)
                }
                CustomLabelButtonView(
                    symbolName: "timer",
                    title: "Rest Timer",
                    subtitle: presenter.restSubtitle
                ) {
                    Button {
                        presenter.onRestTimerPressed()
                    } label: {
                        Text("Edit")
                    }
                    .buttonStyle(.bordered)
                }
                if delegate.exercise.laterality == .unilateral {
                    CustomLabelButtonView(
                        symbolName: "arrow.trianglehead.branch",
                        title: "Rest Between Left/Right Sets",
                        subtitle: presenter.restSubtitle
                    ) {
                        Button {
                            presenter.onRestTimerPressed()
                        } label: {
                            Text("Edit")
                        }
                        .buttonStyle(.bordered)
                    }
                }
                CustomLabelButtonView(
                    symbolName: "text.page",
                    title: "Exercise Note",
                    subtitle: presenter.noteSubtitle
                ) {
                    Button {
                        presenter.onNotePressed()
                    } label: {
                        Text("Edit")
                    }
                    .buttonStyle(.bordered)
                }
                CustomToggleView(
                    symbolName: "nosign",
                    title: "Do Not Recommend",
                    subtitle: "Exclude from automatic program suggestions",
                    bool: .constant(false)
                )
                .disabled(true)
                CustomLabelButtonView(
                    symbolName: "book.pages",
                    title: "Edit Duplicate",
                    subtitle: "To edit all available exercise properties, create a duplicate."
                ) {
                    Button {

                    } label: {
                        Image(systemName: "chevron.right")
                    }
                }
            } header: {
                Text(delegate.exercise.name)
            }
            .listSectionMargins(.top, 0)
        }
        .navigationTitle("Exercise Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = ExerciseSettingsDelegate(exercise: ExerciseModel.mock)
    
    return RouterView { router in
        builder.exerciseSettingsView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {

    func exerciseSettingsView(router: AnyRouter, delegate: ExerciseSettingsDelegate) -> some View {
        ExerciseSettingsView(
            presenter: ExerciseSettingsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                exercise: delegate.exercise
            ),
            delegate: delegate
        )
    }

}

extension CoreRouter {
    
    func showExerciseSettingsView(delegate: ExerciseSettingsDelegate) {
        router.showScreen(.push) { router in
            builder.exerciseSettingsView(router: router, delegate: delegate)
        }
    }
    
}
