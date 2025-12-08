import SwiftUI
import StoreKit

@Observable
@MainActor
class OnbPaywallPresenter {
    
    private let interactor: OnbPaywallInteractor
    private let router: OnbPaywallRouter
    
    private(set) var products: [AnyProduct] = []
    private(set) var productIds: [String] = EntitlementOption.allProductIds
    private(set) var isLoadingProducts: Bool = false
    private(set) var loadErrorMessage: String?
    
    var paywallTest: PaywallTestOption {
        interactor.paywallTest
    }

    enum PaywallLoadError: LocalizedError {
        case noProductsReturned
        
        var errorDescription: String? {
            switch self {
            case .noProductsReturned:
                return "No products returned from the store."
            }
        }
    }

    init(interactor: OnbPaywallInteractor, router: OnbPaywallRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onLoadProducts() async {
        isLoadingProducts = true
        loadErrorMessage = nil
        interactor.trackEvent(event: Event.loadProductsStart(variant: paywallTest))
        
        do {
            let fetchedProducts = try await interactor.getProducts(productIds: productIds)
            products = fetchedProducts
            
            if fetchedProducts.isEmpty {
                loadErrorMessage = "No subscription options are available right now. Please try again in a moment."
                interactor.trackEvent(event: Event.loadProductsFail(error: PaywallLoadError.noProductsReturned, variant: paywallTest))
            } else {
                interactor.trackEvent(event: Event.loadProductsSuccess(count: fetchedProducts.count, variant: paywallTest))
            }
        } catch {
            loadErrorMessage = error.localizedDescription
            interactor.trackEvent(event: Event.loadProductsFail(error: error, variant: paywallTest))
            router.showAlert(error: error)
        }
        
        isLoadingProducts = false
    }
    func onBackButtonPressed() {
        interactor.trackEvent(event: Event.backButtonPressed)
        router.dismissScreen()
    }
    
    func onRestorePurchasePressed() {
        interactor.trackEvent(event: Event.restorePurchaseStart)

        Task {
            do {
                let entitlements = try await interactor.restorePurchase()
                
                if entitlements.hasActiveEntitlement {
                    router.showOnboardingCompleteAccountSetupView()
                }
            } catch {
                router.showAlert(error: error)
            }
        }
    }
    
    func onPurchaseProductPressed(product: AnyProduct) {
        interactor.trackEvent(event: Event.purchaseStart(product: product))

        Task {
            do {
                let entitlements = try await interactor.purchaseProduct(productId: product.id)
                interactor.trackEvent(event: Event.purchaseSuccess(product: product))

                if entitlements.hasActiveEntitlement {
                    router.showOnboardingCompleteAccountSetupView()
                }
            } catch {
                interactor.trackEvent(event: Event.purchaseFail(error: error))
                router.showAlert(error: error)
            }
        }
    }
    
    func onPurchaseStart(product: StoreKit.Product) {
        let product = AnyProduct(storeKitProduct: product)
        interactor.trackEvent(event: Event.purchaseStart(product: product))
    }
    
    func onPurchaseComplete(product: StoreKit.Product, result: Result<Product.PurchaseResult, any Error>) {
        let product = AnyProduct(storeKitProduct: product)

        switch result {
        case .success(let value):
            switch value {
            case .success:
                interactor.trackEvent(event: Event.purchaseSuccess(product: product))
                router.dismissScreen()
            case .pending:
                interactor.trackEvent(event: Event.purchasePending(product: product))
            case .userCancelled:
                interactor.trackEvent(event: Event.purchaseCancelled(product: product))
            default:
                interactor.trackEvent(event: Event.purchaseUnknown(product: product))
            }
        case .failure(let error):
            interactor.trackEvent(event: Event.purchaseFail(error: error))
        }
    }
    
    func onSkipForNowPressed() {
        router.showOnboardingCompleteAccountSetupView()
    }
    
    enum Event: LoggableEvent {
        case purchaseStart(product: AnyProduct)
        case purchaseSuccess(product: AnyProduct)
        case purchasePending(product: AnyProduct)
        case purchaseCancelled(product: AnyProduct)
        case purchaseUnknown(product: AnyProduct)
        case purchaseFail(error: Error)
        case loadProductsStart(variant: PaywallTestOption)
        case loadProductsSuccess(count: Int, variant: PaywallTestOption)
        case loadProductsFail(error: Error, variant: PaywallTestOption)
        case restorePurchaseStart
        case backButtonPressed

        var eventName: String {
            switch self {
            case .purchaseStart:          return "Paywall_Purchase_Start"
            case .purchaseSuccess:        return "Paywall_Purchase_Success"
            case .purchasePending:        return "Paywall_Purchase_Pending"
            case .purchaseCancelled:      return "Paywall_Purchase_Cancelled"
            case .purchaseUnknown:        return "Paywall_Purchase_Unknown"
            case .purchaseFail:           return "Paywall_Purchase_Fail"
            case .loadProductsStart:      return "Paywall_Load_Start"
            case .loadProductsSuccess:    return "Paywall_Load_Success"
            case .loadProductsFail:       return "Paywall_Load_Fail"
            case .restorePurchaseStart:   return "Paywall_Restore_Start"
            case .backButtonPressed:      return "Paywall_BackButton_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .purchaseStart(product: let product), .purchaseSuccess(product: let product), .purchasePending(product: let product), .purchaseCancelled(product: let product), .purchaseUnknown(product: let product):
                return product.eventParameters
            case .purchaseFail(error: let error):
                return error.eventParameters
            case .loadProductsStart(variant: let variant):
                return [
                    "paywallVariant": variant.rawValue
                ]
            case .loadProductsSuccess(count: let count, variant: let variant):
                return [
                    "productCount": count,
                    "paywallVariant": variant.rawValue
                ]
            case .loadProductsFail(error: let error, variant: let variant):
                return [
                    "paywallVariant": variant.rawValue,
                    "errorDescription": error.localizedDescription
                ]
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .purchaseFail:
                return .severe
            case .loadProductsFail:
                return .severe
            default:
                return .analytic
            }
        }
    }

}
