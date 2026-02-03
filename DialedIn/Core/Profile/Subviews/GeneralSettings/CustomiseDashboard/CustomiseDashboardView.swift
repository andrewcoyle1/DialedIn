import SwiftUI

struct CustomiseDashboardDelegate {
    
}

struct CustomiseDashboardView: View {
    
    @State var presenter: CustomiseDashboardPresenter
    let delegate: CustomiseDashboardDelegate
    
    var body: some View {
        List {
            Text("Hello, World!")
        }
        .navigationTitle("Customise Dashboard")
        .screenAppearAnalytics(name: "CustomiseDashboardView")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .confirm) {
                    
                }
            }
        }
    }
}

extension CoreBuilder {
    
    func customiseDashboardView(router: Router, delegate: CustomiseDashboardDelegate) -> some View {
        CustomiseDashboardView(
            presenter: CustomiseDashboardPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showCustomiseDashboardView(delegate: CustomiseDashboardDelegate) {
        router.showScreen(.push) { router in
            builder.customiseDashboardView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = CustomiseDashboardDelegate()
    
    return RouterView { router in
        builder.customiseDashboardView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
