import SwiftUI

struct StrategySettingsDelegate {
    
}

struct StrategySettingsView: View {
    
    @State var presenter: StrategySettingsPresenter
    let delegate: StrategySettingsDelegate
    
    var body: some View {
        List {
            Section {
                Text("Hello, World!")
            } header: {
                Text("General")
            }

            Section {
                Text("Hello, World!")
            } header: {
                Text("Coaching Modules")
            }
        }
        .navigationTitle("Strategy")
        .navigationBarTitleDisplayMode(.inline)
        .screenAppearAnalytics(name: "StrategySettingsView")
    }
}

extension CoreBuilder {
    
    func strategySettingsView(router: Router, delegate: StrategySettingsDelegate) -> some View {
        StrategySettingsView(
            presenter: StrategySettingsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showStrategySettingsView(delegate: StrategySettingsDelegate) {
        router.showScreen(.push) { router in
            builder.strategySettingsView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = StrategySettingsDelegate()
    
    return RouterView { router in
        builder.strategySettingsView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
