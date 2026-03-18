import SwiftUI

struct DefineWorkoutWrapperDelegate {
    let name: String
    let gymProfile: GymProfileModel
    var onWorkoutCreated: (@Sendable (WorkoutTemplateModel) -> Void)?
}

struct DefineWorkoutWrapperView<DefineWorkout: View>: View {

    @State var presenter: DefineWorkoutWrapperPresenter
    let delegate: DefineWorkoutWrapperDelegate

    @ViewBuilder var defineWorkoutView: (DefineWorkoutDelegate) -> DefineWorkout

    private var isStartWorkoutMode: Bool {
        delegate.onWorkoutCreated != nil
    }

    var body: some View {
        let defineDelegate = DefineWorkoutDelegate(
            name: delegate.name,
            gymProfile: delegate.gymProfile,
            exercises: Binding(
                get: { presenter.exercises },
                set: { presenter.exercises = $0 }
            ),
            topSectionStyle: .standaloneWorkout
        )
        defineWorkoutView(defineDelegate)
            .navigationTitle("Define Workout")
            .onAppear {
                presenter.onViewAppear()
            }
            .onDisappear {
                presenter.onViewDisappear()
            }
            .safeAreaInset(edge: .bottom) {
                CallToActionButton {
                    presenter.onConfirmPressed(delegate: self.delegate)
                } label: {
                    Text(isStartWorkoutMode ? "Start Workout" : "Save")
                }
            }
    }
}

extension CoreBuilder {
    
    func defineWorkoutWrapperView(router: AnyRouter, delegate: DefineWorkoutWrapperDelegate) -> some View {
        DefineWorkoutWrapperView(
            presenter: DefineWorkoutWrapperPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate,
            defineWorkoutView: { delegate in
                self.defineWorkoutView(router: router, delegate: delegate)
            }
        )
    }
    
}

extension CoreRouter {
    
    func showDefineWorkoutWrapperView(delegate: DefineWorkoutWrapperDelegate) {
        router.showScreen(.push) { router in
            builder.defineWorkoutWrapperView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = DefineWorkoutWrapperDelegate(name: "Sample Workout", gymProfile: GymProfileModel.mock)
    
    return RouterView { router in
        builder.defineWorkoutWrapperView(router: router, delegate: delegate)
    }
    
}

#Preview("Start Workout Mode") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = DefineWorkoutWrapperDelegate(
        name: "Sample Workout",
        gymProfile: GymProfileModel.mock,
        onWorkoutCreated: { _ in
            
        }
    )
    
    return RouterView { router in
        builder.defineWorkoutWrapperView(router: router, delegate: delegate)
    }
    
}
