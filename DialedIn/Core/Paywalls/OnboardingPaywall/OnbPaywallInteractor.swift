import SwiftUI

@MainActor
protocol OnbPaywallInteractor {
    var paywallTest: PaywallTestOption { get }
    
    func trackEvent(event: LoggableEvent)
    func getProducts(productIds: [String]) async throws -> [AnyProduct]
    func restorePurchase() async throws -> [PurchasedEntitlement]
    func purchaseProduct(productId: String) async throws -> [PurchasedEntitlement]
}

extension OnbInteractor: OnbPaywallInteractor { }
