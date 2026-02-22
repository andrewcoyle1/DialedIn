import SwiftUI

@MainActor
protocol CorePaywallInteractor: GlobalInteractor {
    var paywallTest: PaywallTestOption { get }
    func getProducts(productIds: [String]) async throws -> [AnyProduct]
    func restorePurchase() async throws -> [PurchasedEntitlement]
    func purchaseProduct(productId: String) async throws -> [PurchasedEntitlement]
}

extension CoreInteractor: CorePaywallInteractor { }
