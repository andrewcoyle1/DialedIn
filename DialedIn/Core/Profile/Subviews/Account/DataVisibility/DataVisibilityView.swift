import SwiftUI

struct DataVisibilityDelegate {
    
}

struct DataVisibilityView: View {
    
    @State var presenter: DataVisibilityPresenter
    let delegate: DataVisibilityDelegate
    
    var body: some View {
        List {
            Section {
                Text("Hello, World!")
            } header: {
                Text("Visibility Settings")
            }
        }
        .navigationTitle("Data Visibility")
        .navigationBarTitleDisplayMode(.inline)
            .screenAppearAnalytics(name: "DataVisibilityView")
    }
}

extension CoreBuilder {
    
    func dataVisibilityView(router: Router, delegate: DataVisibilityDelegate) -> some View {
        DataVisibilityView(
            presenter: DataVisibilityPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showDataVisibilityView(delegate: DataVisibilityDelegate) {
        router.showScreen(.push) { router in
            builder.dataVisibilityView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = DataVisibilityDelegate()
    
    return RouterView { router in
        builder.dataVisibilityView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
