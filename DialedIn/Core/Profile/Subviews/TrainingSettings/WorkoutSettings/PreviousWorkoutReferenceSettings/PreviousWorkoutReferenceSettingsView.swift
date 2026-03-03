import SwiftUI

struct PreviousWorkoutReferenceSettingsDelegate {
    var eventParameters: [String: Any]? {
        nil
    }
}

struct PreviousWorkoutReferenceSettingsView: View {
    
    @State var presenter: PreviousWorkoutReferenceSettingsPresenter
    let delegate: PreviousWorkoutReferenceSettingsDelegate
    
    var body: some View {
        List {
            Text("Hello, World!")
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
    let delegate = PreviousWorkoutReferenceSettingsDelegate()
    
    return RouterView { router in
        builder.previousWorkoutReferenceSettingsView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {
    func previousWorkoutReferenceSettingsView(router: AnyRouter, delegate: PreviousWorkoutReferenceSettingsDelegate) -> some View {
        PreviousWorkoutReferenceSettingsView(
            presenter: PreviousWorkoutReferenceSettingsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showPreviousWorkoutReferenceSettingsView(delegate: PreviousWorkoutReferenceSettingsDelegate) {
        router.showScreen(.push) { router in
            builder.previousWorkoutReferenceSettingsView(router: router, delegate: delegate)
        }
    }
    
}
