import SwiftUI

struct LegalDelegate {
    
}

struct LegalView: View {
    
    @State var presenter: LegalPresenter
    let delegate: LegalDelegate
    
    var body: some View {
        List {
            Section {
                Button {
                
                } label: {
                    Text("Terms of Service")
                }

                Button {
                
                } label: {
                    Text("Privacy Policy")
                }

                Button {
                
                } label: {
                    Text("Health Disclaimer")
                }

                Button {
                
                } label: {
                    Text("Consumer Health Privacy")
                }

            } header: {
                Text("Agreements")
            }
        }
        .navigationTitle("Legal")
        .navigationBarTitleDisplayMode(.inline)
        .screenAppearAnalytics(name: "LegalView")
    }
}

extension CoreBuilder {
    
    func legalView(router: Router, delegate: LegalDelegate) -> some View {
        LegalView(
            presenter: LegalPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showLegalView(delegate: LegalDelegate) {
        router.showScreen(.push) { router in
            builder.legalView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = LegalDelegate()
    
    return RouterView { router in
        builder.legalView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
