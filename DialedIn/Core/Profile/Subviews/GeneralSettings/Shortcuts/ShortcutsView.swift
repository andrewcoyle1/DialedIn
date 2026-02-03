import SwiftUI

struct ShortcutsDelegate {
    
}

struct ShortcutsView: View {
    
    @State var presenter: ShortcutsPresenter
    let delegate: ShortcutsDelegate
    
    var body: some View {
        List {
            Section {
                Text("Hello, World!")
            } header: {
                Text("Toolbar")
            }
        }
        .navigationTitle("Shortcuts")
        .navigationBarTitleDisplayMode(.inline)
        .screenAppearAnalytics(name: "ShortcutsView")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .confirm) {
                    
                }
            }
        }
    }
}

extension CoreBuilder {
    
    func shortcutsView(router: Router, delegate: ShortcutsDelegate) -> some View {
        ShortcutsView(
            presenter: ShortcutsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showShortcutsView(delegate: ShortcutsDelegate) {
        router.showScreen(.push) { router in
            builder.shortcutsView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = ShortcutsDelegate()
    
    return RouterView { router in
        builder.shortcutsView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
