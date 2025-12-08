import SwiftUI
import SwiftfulRouting

struct CorePaywallView: View {
    
    @State var presenter: CorePaywallPresenter

    var body: some View {
        ZStack {
            switch presenter.paywallTest {
            case .custom:
                if presenter.isLoadingProducts {
                    ProgressView()
                } else if let errorMessage = presenter.loadErrorMessage {
                    VStack(spacing: 12) {
                        Text("Unable to load subscription options")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                        
                        Button("Try Again") {
                            Task { await presenter.onLoadProducts() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else if presenter.products.isEmpty {
                    VStack(spacing: 8) {
                        Text("No subscription options available right now.")
                            .font(.headline)
                        Button("Refresh") {
                            Task { await presenter.onLoadProducts() }
                        }
                    }
                } else {
                    CustomPaywallView(
                        products: presenter.products,
                        onBackButtonPressed: {
                            presenter.onBackButtonPressed()
                        },
                        onRestorePurchasePressed: {
                            presenter.onRestorePurchasePressed()
                        },
                        onPurchaseProductPressed: { product in
                            presenter.onPurchaseProductPressed(product: product)
                        }
                    )
                }
            case .revenueCat:
                RevenueCatPaywallView()
            case .storeKit:
                StoreKitPaywallView(
                    productIds: presenter.productIds,
                    onInAppPurchaseStart: presenter.onPurchaseStart,
                    onInAppPurchaseCompletion: { (product, result) in
                        presenter.onPurchaseComplete(product: product, result: result)
                    }
                )
            }
        }
        .screenAppearAnalytics(name: "Paywall")
        .task {
            await presenter.onLoadProducts()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    presenter.onBackButtonPressed()
                } label: {
                    Image(systemName: "xmark")
                }
            }
        }
    }
}

extension CoreBuilder {
    func corePaywallView(router: AnyRouter) -> some View {
        CorePaywallView(
            presenter: CorePaywallPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
}

extension CoreRouter {
    func showCorePaywall() {
        router.showScreen(.fullScreenCover) { router in
            builder.corePaywallView(router: router)
        }
    }

}

#Preview("Custom") {
    let container = DevPreview.shared.container
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(paywallTest: .custom)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    return RouterView { router in
        builder.corePaywallView(router: router)
    }
    .previewEnvironment()
}
#Preview("StoreKit") {
    let container = DevPreview.shared.container
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(paywallTest: .storeKit)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    return RouterView { router in
        builder.corePaywallView(router: router)
    }
    .previewEnvironment()
}
#Preview("RevenueCat") {
    let container = DevPreview.shared.container
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(paywallTest: .revenueCat)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    return RouterView { router in
        builder.corePaywallView(router: router)
    }
    .previewEnvironment()
}
