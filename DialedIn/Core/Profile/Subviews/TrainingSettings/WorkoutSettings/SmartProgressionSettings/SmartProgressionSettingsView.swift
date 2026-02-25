import SwiftUI

struct SmartProgressionSettingsDelegate {
    var eventParameters: [String: Any]? {
        nil
    }
}

struct SmartProgressionSettingsView: View {
    
    @State var presenter: SmartProgressionSettingsPresenter
    let delegate: SmartProgressionSettingsDelegate
    
    var body: some View {
        Text("Hello, World!")
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
    let delegate = SmartProgressionSettingsDelegate()
    
    return RouterView { router in
        builder.smartProgressionSettingsView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {
    
    func smartProgressionSettingsView(router: AnyRouter, delegate: SmartProgressionSettingsDelegate) -> some View {
        SmartProgressionSettingsView(
            presenter: SmartProgressionSettingsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showSmartProgressionSettingsView(delegate: SmartProgressionSettingsDelegate) {
        router.showScreen(.push) { router in
            builder.smartProgressionSettingsView(router: router, delegate: delegate)
        }
    }
    
}
