import SwiftUI

struct SiriDelegate {
    
}

struct SiriView: View {
    
    @State var presenter: SiriPresenter
    let delegate: SiriDelegate
    
    var body: some View {
        List {
            Section {
                Text("What can I ask Siri?")
            } header: {
                Text("Learn")
            }

            Section {
                Text("Speak Remaining Goals")
            } header: {
                Text("Log Water")
            }

            Section {
                Text("Always as for")
                Text("Ask for food name")
                Text("Energy Input")
            } header: {
                Text("Quick Add")
            }

            Section {
                Text("Speak Estimated Macros")
            } header: {
                Text("Log Beer")
            }

        }
        .navigationTitle("Siri")
        .navigationBarTitleDisplayMode(.inline)
        .screenAppearAnalytics(name: "SiriView")
    }
}

extension CoreBuilder {
    
    func siriView(router: Router, delegate: SiriDelegate) -> some View {
        SiriView(
            presenter: SiriPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showSiriView(delegate: SiriDelegate) {
        router.showScreen(.push) { router in
            builder.siriView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = SiriDelegate()
    
    return RouterView { router in
        builder.siriView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
