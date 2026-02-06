import SwiftUI

struct LicencesDelegate {
    
}

struct LicencesView: View {
    
    @State var presenter: LicencesPresenter
    let delegate: LicencesDelegate
    
    var body: some View {
        List {
            Text("Hello, World!")
        }
        .navigationTitle("Licences")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    presenter.onDismissPressed()
                } label: {
                    Image(systemName: "xmark")
                }
            }
        }
        .screenAppearAnalytics(name: "LicencesView")
    }
}

extension CoreBuilder {
    
    func licencesView(router: Router, delegate: LicencesDelegate) -> some View {
        LicencesView(
            presenter: LicencesPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showLicencesView(delegate: LicencesDelegate) {
        router.showScreen(.fullScreenCover) { router in
            builder.licencesView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = LicencesDelegate()
    
    return RouterView { router in
        builder.licencesView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
