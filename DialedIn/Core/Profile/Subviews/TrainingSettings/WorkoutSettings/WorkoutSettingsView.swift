import SwiftUI

struct WorkoutSettingsDelegate {
    var eventParameters: [String: Any]? {
        nil
    }
}

struct WorkoutSettingsView: View {
    
    @State var presenter: WorkoutSettingsPresenter
    let delegate: WorkoutSettingsDelegate
    
    var body: some View {
        List {
            Text("Workout Settings View")
        }
        .navigationTitle("Workout Settings")
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
    let delegate = WorkoutSettingsDelegate()
    
    return RouterView { router in
        builder.workoutSettingsView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {
    
    func workoutSettingsView(router: AnyRouter, delegate: WorkoutSettingsDelegate) -> some View {
        WorkoutSettingsView(
            presenter: WorkoutSettingsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showWorkoutSettingsView(delegate: WorkoutSettingsDelegate) {
        router.showScreen(.push) { router in
            builder.workoutSettingsView(router: router, delegate: delegate)
        }
    }
    
}
