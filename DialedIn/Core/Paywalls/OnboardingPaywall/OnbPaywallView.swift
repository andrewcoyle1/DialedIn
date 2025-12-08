import SwiftUI
import SwiftfulRouting

struct OnbPaywallView: View {
    
    @State var presenter: OnbPaywallPresenter

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
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    presenter.onSkipForNowPressed()
                } label: {
                    Text("Skip")
                }
            }
        }

    }
}

extension OnbBuilder {
    func onbPaywallView(router: AnyRouter) -> some View {
        OnbPaywallView(
            presenter: OnbPaywallPresenter(
                interactor: interactor,
                router: OnbRouter(router: router, builder: self)
            )
        )
    }
}

extension OnbRouter {
    func showOnbPaywall() {
        router.showScreen(.push) { router in
            builder.onbPaywallView(router: router)
        }
    }
}

#Preview("Custom") {
    let container = DevPreview.shared.container
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(paywallTest: .custom)))
    let builder = OnbBuilder(interactor: OnbInteractor(container: container))

    return RouterView { router in
        builder.onbPaywallView(router: router)
    }
    .previewEnvironment()
}
#Preview("StoreKit") {
    let container = DevPreview.shared.container
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(paywallTest: .storeKit)))
    let builder = OnbBuilder(interactor: OnbInteractor(container: container))

    return RouterView { router in
        builder.onbPaywallView(router: router)
    }
    .previewEnvironment()
}
#Preview("RevenueCat") {
    let container = DevPreview.shared.container
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(paywallTest: .revenueCat)))
    let builder = OnbBuilder(interactor: OnbInteractor(container: container))

    return RouterView { router in
        builder.onbPaywallView(router: router)
    }
    .previewEnvironment()
}
