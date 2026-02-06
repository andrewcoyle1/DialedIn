import SwiftUI

struct DefineWorkoutWrapperDelegate {
    let name: String
    let gymProfile: GymProfileModel
}

struct DefineWorkoutWrapperView<DefineWorkout: View>: View {
    
    @State var presenter: DefineWorkoutWrapperPresenter
    let delegate: DefineWorkoutWrapperDelegate
    
    @ViewBuilder var defineWorkoutView: (DefineWorkoutDelegate) -> DefineWorkout
    
    var body: some View {
        let delegate = DefineWorkoutDelegate(
            name: delegate.name,
            gymProfile: delegate.gymProfile,
            exercises: Binding(
                get: { presenter.exercises },
                set: { presenter.exercises = $0 }
            ),
            topSectionStyle: .standaloneWorkout
        )
        defineWorkoutView(delegate)
            .navigationTitle("Define Workout")
            .screenAppearAnalytics(name: "DefineWorkoutWrapperView")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save", role: .confirm) {
                        presenter.onConfirmPressed(delegate: self.delegate)
                    }
                }
            }

    }
}

extension CoreBuilder {
    
    func defineWorkoutWrapperView(router: Router, delegate: DefineWorkoutWrapperDelegate) -> some View {
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
    .previewEnvironment()
}
