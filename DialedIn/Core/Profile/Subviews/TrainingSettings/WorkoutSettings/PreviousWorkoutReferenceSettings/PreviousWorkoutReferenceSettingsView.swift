import SwiftUI

struct PrevWORefSettingsDelegate {
    var eventParameters: [String: Any]? {
        nil
    }
}

struct PreviousWorkoutReferenceSettingsView: View {
    
    @State var presenter: PrevWORefSettingsPresenter
    let delegate: PrevWORefSettingsDelegate
    
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
    let delegate = PrevWORefSettingsDelegate()
    
    return RouterView { router in
        builder.previousWorkoutReferenceSettingsView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {
    func previousWorkoutReferenceSettingsView(router: AnyRouter, delegate: PrevWORefSettingsDelegate) -> some View {
        PreviousWorkoutReferenceSettingsView(
            presenter: PrevWORefSettingsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showPreviousWorkoutReferenceSettingsView(delegate: PrevWORefSettingsDelegate) {
        router.showScreen(.push) { router in
            builder.previousWorkoutReferenceSettingsView(router: router, delegate: delegate)
        }
    }
    
}
