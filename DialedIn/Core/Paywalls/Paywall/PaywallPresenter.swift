import SwiftUI
import StoreKit

@Observable
@MainActor
class CorePaywallPresenter {
    
    private let interactor: CorePaywallInteractor
    private let router: CorePaywallRouter
    private let onPurchaseSuccess: (@MainActor () -> Void)?

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

    init(interactor: CorePaywallInteractor, router: CorePaywallRouter, onPurchaseSuccess: (@MainActor () -> Void)? = nil) {
        self.interactor = interactor
        self.router = router
        self.onPurchaseSuccess = onPurchaseSuccess
    }
    
    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }
    
    func onViewDisappear() {
        interactor.trackEvent(event: Event.onDisappear)
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
                    router.dismissScreen()
                    onPurchaseSuccess?()
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
                    router.dismissScreen()
                    onPurchaseSuccess?()
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
                onPurchaseSuccess?()
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
    
    enum Event: LoggableEvent {
        case onAppear
        case onDisappear
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
            case .onAppear:             return "PaywallView_Appear"
            case .onDisappear:          return "PaywallView_Disappear"
            case .purchaseStart:        return "PaywallView_Purchase_Start"
            case .purchaseSuccess:      return "PaywallView_Purchase_Success"
            case .purchasePending:      return "PaywallView_Purchase_Pending"
            case .purchaseCancelled:    return "PaywallView_Purchase_Cancelled"
            case .purchaseUnknown:      return "PaywallView_Purchase_Unknown"
            case .purchaseFail:         return "PaywallView_Purchase_Fail"
            case .loadProductsStart:    return "PaywallView_Load_Start"
            case .loadProductsSuccess:  return "PaywallView_Load_Success"
            case .loadProductsFail:     return "PaywallView_Load_Fail"
            case .restorePurchaseStart: return "PaywallView_Restore_Start"
            case .backButtonPressed:    return "PaywallView_BackButton_Pressed"
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
