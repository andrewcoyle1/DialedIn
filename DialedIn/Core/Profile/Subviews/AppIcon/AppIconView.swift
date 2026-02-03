import SwiftUI

struct AppIconDelegate {
    
}

struct AppIconView: View {
    
    @State var presenter: AppIconPresenter
    let delegate: AppIconDelegate
    
    var body: some View {
        List {
            Group {
                CustomListCellView()
                CustomListCellView()
                CustomListCellView()
            }
            .removeListRowFormatting()
        }
        .navigationTitle("App Icon")
        .navigationBarTitleDisplayMode(.inline)
            .screenAppearAnalytics(name: "AppIconView")
    }
}

extension CoreBuilder {
    
    func appIconView(router: Router, delegate: AppIconDelegate) -> some View {
        AppIconView(
            presenter: AppIconPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showAppIconView(delegate: AppIconDelegate) {
        router.showScreen(.push) { router in
            builder.appIconView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = AppIconDelegate()
    
    return RouterView { router in
        builder.appIconView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
