import SwiftUI

struct IntegrationsDelegate {
    
}

struct IntegrationsView: View {
    
    @State var presenter: IntegrationsPresenter
    let delegate: IntegrationsDelegate
    
    var body: some View {
        List {
            Section {
                Text("Hello, World!")
            } header: {
                Text("Available Integrations")
            }
        }
        .navigationTitle("Integrations")
        .navigationBarTitleDisplayMode(.inline)
        .screenAppearAnalytics(name: "IntegrationsView")
    }
}

extension CoreBuilder {
    
    func integrationsView(router: Router, delegate: IntegrationsDelegate) -> some View {
        IntegrationsView(
            presenter: IntegrationsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showIntegrationsView(delegate: IntegrationsDelegate) {
        router.showScreen(.push) { router in
            builder.integrationsView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = IntegrationsDelegate()
    
    return RouterView { router in
        builder.integrationsView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
