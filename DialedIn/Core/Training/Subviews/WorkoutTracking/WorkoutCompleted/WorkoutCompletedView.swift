import SwiftUI

struct WorkoutCompletedDelegate {
    
    var workoutSession: WorkoutSessionModel
    
    var eventParameters: [String: Any]? {
        nil
    }
}

struct WorkoutCompletedView: View {
    
    @State var presenter: WorkoutCompletedPresenter
    let delegate: WorkoutCompletedDelegate
    
    var body: some View {
        List {
            Text("Hello, World!")
        }
        .navigationTitle("Workout Completed")
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbarRole(.browser)
        .safeAreaInset(edge: .bottom) {
            Button {
                
            } label: {
                Text("Save Workout")
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .padding()
        }
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
    let delegate = WorkoutCompletedDelegate(workoutSession: .mock)
    
    return RouterView { router in
        builder.workoutCompletedView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {
    
    func workoutCompletedView(router: AnyRouter, delegate: WorkoutCompletedDelegate) -> some View {
        WorkoutCompletedView(
            presenter: WorkoutCompletedPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showWorkoutCompletedView(delegate: WorkoutCompletedDelegate) {
        router.showScreen(.push) { router in
            builder.workoutCompletedView(router: router, delegate: delegate)
        }
    }
    
}
