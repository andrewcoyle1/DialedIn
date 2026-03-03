import SwiftUI

struct CustomiseAnalyticsDelegate {
    
}

struct CustomiseAnalyticsView: View {
    
    @State var presenter: CustomiseAnalyticsPresenter
    let delegate: CustomiseAnalyticsDelegate
    
    var body: some View {
        List {
            Text("Hello, World!")
        }
        .navigationTitle("Customise Analytics")
        .onAppear {
            presenter.onViewAppear()
        }
        .onDisappear {
            presenter.onViewDisappear()
        }
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
    
    func customiseAnalyticsView(router: AnyRouter, delegate: CustomiseAnalyticsDelegate) -> some View {
        CustomiseAnalyticsView(
            presenter: CustomiseAnalyticsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showCustomiseAnalyticsView(delegate: CustomiseAnalyticsDelegate) {
        router.showScreen(.push) { router in
            builder.customiseAnalyticsView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = CustomiseAnalyticsDelegate()
    
    return RouterView { router in
        builder.customiseAnalyticsView(router: router, delegate: delegate)
    }
    
}
