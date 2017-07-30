import UIKit
import StoreKit
import SwiftyStoreKit
import Crashlytics

class NetworkActivityIndicatorManager: NSObject
{
    private static var loadingCount = 0
    
    class func networkOperationStarted()
    {
        #if os(iOS)
            if loadingCount == 0 {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }
            loadingCount += 1
        #endif
    }
    
    class func networkOperationFinished()
    {
        #if os(iOS)
            if loadingCount > 0 {
                loadingCount -= 1
            }
            if loadingCount == 0 {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        #endif
    }
}

enum RegisteredPurchase: String
{
    case SmallDiamondPack = "SmallDiamondPack"
    case BigDiamondPack = "BigDiamondPack"
}

class PurchaseManager
{
    static let appBundleId = "com.APStudios.ProSpinner"
    static var rootViewController: UIViewController!
    
    static func getInfo(completion block: @escaping (RetrieveResults) -> Void)
    {
        log.debug("")
        let productSet : Set<String> = [appBundleId + "." + RegisteredPurchase.SmallDiamondPack.rawValue,
                                        appBundleId + "." + RegisteredPurchase.BigDiamondPack.rawValue]

        DispatchQueue.background.async
        {
            NetworkActivityIndicatorManager.networkOperationStarted()
            SwiftyStoreKit.retrieveProductsInfo(productSet) { result in
                NetworkActivityIndicatorManager.networkOperationFinished()
                
                block(result)
            }
        }
    }
    
    static func purchase(_ registeredPurchase: RegisteredPurchase,completion block: @escaping (RegisteredPurchase, Bool) -> Void)
    {
        log.debug("")
        rootViewController.view.isUserInteractionEnabled = false

        NetworkActivityIndicatorManager.networkOperationStarted()
        DispatchQueue.background.async
        {
            SwiftyStoreKit.purchaseProduct(appBundleId + "." + registeredPurchase.rawValue, atomically: true) { result in
                NetworkActivityIndicatorManager.networkOperationFinished()
                
                rootViewController.view.isUserInteractionEnabled = true
                if case .success(let purchase) = result
                {
                    block(registeredPurchase , true)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.reloadLockedViewAfterPurchase.rawValue), object: nil)
                    CrashlyticsLogManager.logPurchase(withProduct : purchase)
                    
                    if purchase.needsFinishTransaction
                    {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                }
                else if case .error = result
                {
                    block(registeredPurchase , false)
                }
                
                if let alert = self.rootViewController.alertForPurchaseResult(result) {
                    PurchaseManager.rootViewController.showAlert(alert)
                }
            }
        }
    }
}

// MARK: User facing alerts
extension UIViewController
{
    
    func alertWithTitle(_ title: String, message: String) -> UIAlertController {
        log.debug("")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alert
    }
    
    func showAlert(_ alert: UIAlertController) {
        guard self.presentedViewController != nil else {
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
    func alertForProductRetrievalInfo(_ result: RetrieveResults) -> UIAlertController {
        log.debug("")
        if let product = result.retrievedProducts.first {
            let priceString = product.localizedPrice!
            return alertWithTitle(product.localizedTitle, message: "\(product.localizedDescription) - \(priceString)")
        } else if let invalidProductId = result.invalidProductIDs.first {
            return alertWithTitle("Could not retrieve product info", message: "Invalid product identifier: \(invalidProductId)")
        } else {
            let errorString = result.error?.localizedDescription ?? "Unknown error. Please contact support"
            return alertWithTitle("Could not retrieve product info", message: errorString)
        }
    }
    
    // swiftlint:disable cyclomatic_complexity
    func alertForPurchaseResult(_ result: PurchaseResult) -> UIAlertController?
    {
        log.debug("")
        switch result
        {
        case .success(let purchase):
            print("Purchase Success: \(purchase.productId)")
            return nil
            
        case .error(let error):
            print("Purchase Failed: \(error)")
            switch error.code {
            case .unknown: return alertWithTitle("Purchase failed", message: "Unknown error. Please contact support")
            case .clientInvalid: // client is not allowed to issue the request, etc.
                return alertWithTitle("Purchase failed", message: "Not allowed to make the payment")
            case .paymentCancelled: // user cancelled the request, etc.
                return nil
            case .paymentInvalid: // purchase identifier was invalid, etc.
                return alertWithTitle("Purchase failed", message: "The purchase identifier was invalid")
            case .paymentNotAllowed: // this device is not allowed to make the payment
                return alertWithTitle("Purchase failed", message: "The device is not allowed to make the payment")
            case .storeProductNotAvailable: // Product is not available in the current storefront
                return alertWithTitle("Purchase failed", message: "The product is not available in the current storefront")
            case .cloudServicePermissionDenied: // user has not allowed access to cloud service information
                return alertWithTitle("Purchase failed", message: "Access to cloud service information is not allowed")
            case .cloudServiceNetworkConnectionFailed: // the device could not connect to the nework
                return alertWithTitle("Purchase failed", message: "Could not connect to the network")
            case .cloudServiceRevoked: // user has revoked permission to use this cloud service
                return alertWithTitle("Purchase failed", message: "Cloud service was revoked")
            }
        }
    }
    
    func alertForRestorePurchases(_ results: RestoreResults) -> UIAlertController {
        
        log.debug("")
        if results.restoreFailedPurchases.count > 0 {
            print("Restore Failed: \(results.restoreFailedPurchases)")
            return alertWithTitle("Restore failed", message: "Unknown error. Please contact support")
        } else if results.restoredPurchases.count > 0 {
            print("Restore Success: \(results.restoredPurchases)")
            return alertWithTitle("Purchases Restored", message: "All purchases have been restored")
        } else {
            print("Nothing to Restore")
            return alertWithTitle("Nothing to restore", message: "No previous purchases were found")
        }
    }
    
    func alertForVerifyReceipt(_ result: VerifyReceiptResult) -> UIAlertController {
        
        log.debug("")
        switch result {
        case .success(let receipt):
            print("Verify receipt Success: \(receipt)")
            return alertWithTitle("Receipt verified", message: "Receipt verified remotely")
        case .error(let error):
            print("Verify receipt Failed: \(error)")
            switch error {
            case .noReceiptData:
                return alertWithTitle("Receipt verification", message: "No receipt data. Try again.")
            case .networkError(let error):
                return alertWithTitle("Receipt verification", message: "Network error while verifying receipt: \(error)")
            default:
                return alertWithTitle("Receipt verification", message: "Receipt verification failed: \(error)")
            }
        }
    }
    
    func alertForVerifySubscription(_ result: VerifySubscriptionResult) -> UIAlertController {
        
        log.debug("")
        switch result {
        case .purchased(let expiryDate):
            print("Product is valid until \(expiryDate)")
            return alertWithTitle("Product is purchased", message: "Product is valid until \(expiryDate)")
        case .expired(let expiryDate):
            print("Product is expired since \(expiryDate)")
            return alertWithTitle("Product expired", message: "Product is expired since \(expiryDate)")
        case .notPurchased:
            print("This product has never been purchased")
            return alertWithTitle("Not purchased", message: "This product has never been purchased")
        }
    }
    
    func alertForVerifyPurchase(_ result: VerifyPurchaseResult) -> UIAlertController {
        
        log.debug("")
        switch result {
        case .purchased:
            print("Product is purchased")
            return alertWithTitle("Product is purchased", message: "Product will not expire")
        case .notPurchased:
            print("This product has never been purchased")
            return alertWithTitle("Not purchased", message: "This product has never been purchased")
        }
    }
}

