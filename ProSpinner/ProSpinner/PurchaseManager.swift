////
////  PurchaseManager.swift
////  ProSpinner
////
////  Created by AlexP on 2.6.2017.
////  Copyright © 2017 Alex Pinhasov. All rights reserved.
////
//
//import Foundation
//import StoreKit
//
//enum DiamondPack: String
//{
//    case smallPack = "SmallDiamondPack"
//    case bigPack   = "BigDiamondPack"
//}
//
//class PurchaseManager: NSObject,
//                       SKProductsRequestDelegate,
//                       SKPaymentTransactionObserver
//{
//    private var list = [SKProduct]()
//    private var product = SKProduct()
//    private var diamondPackToProccess : DiamondPack?
//    
//    func Buy(diamondPack diamondPackSize: DiamondPack)
//    {
//        if(SKPaymentQueue.canMakePayments())
//        {
//            print("IAP is enabled, loading")
//            let productID:NSSet = NSSet(objects: diamondPackSize.rawValue)
//            let request: SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
//            
//            request.delegate = self
//            request.start()
//        } else {
//            print("please enable IAPS")
//        }
//    }
//    
//    func buyProduct()
//    {
//        print("buy " + product.productIdentifier)
//        let pay = SKPayment(product: product)
//        SKPaymentQueue.default().add(self)
//        SKPaymentQueue.default().add(pay)
//    }
//    
//    
//    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse)
//    {
//        print("product request")
//        let myProduct = response.products
//        
//        for product in myProduct {
//            print("product added")
//            print(product.productIdentifier)
//            print(product.localizedTitle)
//            print(product.localizedDescription)
//            print(product.price)
//            
//            list.append(product )
//        }
//        
//        for actualProduct in list
//        {
//            let prodID = product.productIdentifier
//            if(prodID == "finnci.Premium")
//            {
//                product = actualProduct
//                buyProduct()
//                break;
//            }
//        }
//    }
//    
//    private func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue)
//    {
//        print("transactions restored")
//        
//        for transaction in queue.transactions {
//            let t: SKPaymentTransaction = transaction
//            
//            let prodID = t.payment.productIdentifier as String
//            
//            switch prodID {
//            case "finnci.Premium":
//                print("is premium")
//                
//                
//            default:
//                print("IAP not setup")
//            }
//            
//        }
//    }
//    
//    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
//        print("add paymnet")
//        
//        for transaction:AnyObject in transactions {
//            let trans = transaction as! SKPaymentTransaction
//            print(trans.error as Any)
//            
//            switch trans.transactionState {
//                
//            case .purchased ,
//                 .restored:
//                
//                print("buy, ok unlock iap here")
//                print(product.productIdentifier)
//                
//                // Make Export available
//                UserDefaults.standard.set(true, forKey: "Premium")
//                
//                let alert = UIAlertView()
//                alert.title = "משתמש יקר"
//                alert.message = "את/ה כעת משתמש פרימיום !"
//                alert.addButton(withTitle: "המשך")
//                alert.show()
//                
//                
//                let prodID = product.productIdentifier as String
//                
//                switch prodID {
//                case "finnci.Premium":
//                    print("is premium")
//                    
//                default:
//                    print("IAP not setup")
//                }
//                
//                queue.finishTransaction(trans)
//                break;
//                
//            case .failed:
//                
//                print("buy error")
//                queue.finishTransaction(trans)
//                break;
//            default:
//                print("default")
//                break;
//                
//            }
//        }
//    }
//    
//    func finishTransaction(trans:SKPaymentTransaction)
//    {
//        print("finish trans")
//        SKPaymentQueue.default().finishTransaction(trans)
//    }
//}

//
//  ViewController.swift
//  SwiftyStoreKit
//
//  Created by Andrea Bizzotto on 03/09/2015.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import StoreKit
import SwiftyStoreKit


class NetworkActivityIndicatorManager: NSObject {
    
    private static var loadingCount = 0
    
    class func networkOperationStarted() {
        
        #if os(iOS)
            if loadingCount == 0 {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }
            loadingCount += 1
        #endif
    }
    
    class func networkOperationFinished() {
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
    
    static func getInfo(_ purchase: RegisteredPurchase)
    {
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.retrieveProductsInfo([appBundleId + "." + purchase.rawValue]) { result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            self.rootViewController.showAlert(self.rootViewController.alertForProductRetrievalInfo(result))
        }
    }
    
    static func purchase(_ purchase: RegisteredPurchase)
    {
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.purchaseProduct(appBundleId + "." + purchase.rawValue, atomically: true) { result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            if case .success(let purchase) = result {
                // Deliver content from server, then:
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
            }
            if let alert = self.rootViewController.alertForPurchaseResult(result) {
                PurchaseManager.rootViewController.showAlert(alert)
            }
        }
    }
    
//    @IBAction func restorePurchases()
//    {
//        NetworkActivityIndicatorManager.networkOperationStarted()
//        SwiftyStoreKit.restorePurchases(atomically: true) { results in
//            NetworkActivityIndicatorManager.networkOperationFinished()
//            
//            for purchase in results.restoredPurchases where purchase.needsFinishTransaction {
//                // Deliver content from server, then:
//                SwiftyStoreKit.finishTransaction(purchase.transaction)
//            }
//            PurchaseManager.rootViewController.showAlert(PurchaseManager.rootViewController.alertForRestorePurchases(results))
//        }
//    }
//    
//    @IBAction func verifyReceipt()
//    {
//        NetworkActivityIndicatorManager.networkOperationStarted()
//        verifyReceipt { result in
//            NetworkActivityIndicatorManager.networkOperationFinished()
//            self.rootViewController.showAlert(self.rootViewController.alertForVerifyReceipt(result))
//        }
//    }
//    
//    static func verifyReceipt(completion: @escaping (VerifyReceiptResult) -> Void) {
//        
//        let appleValidator = AppleReceiptValidator(service: .production)
//        let password = "your-shared-secret"
//        SwiftyStoreKit.verifyReceipt(using: appleValidator, password: password, completion: completion)
//    }
    
//    static func verifyPurchase(_ purchase: RegisteredPurchase) {
//        
//        NetworkActivityIndicatorManager.networkOperationStarted()
//        verifyReceipt { result in
//            NetworkActivityIndicatorManager.networkOperationFinished()
//            
//            switch result {
//            case .success(let receipt):
//                
//                let productId = self.appBundleId + "." + purchase.rawValue
//                
//                switch purchase
//                {
//                case .SmallDiamondPack:
//                    let purchaseResult = SwiftyStoreKit.verifySubscription(
//                        type: .autoRenewable,
//                        productId: productId,
//                        inReceipt: receipt,
//                        validUntil: Date()
//                    )
//                    self.rootViewController.showAlert(self.rootViewController.alertForVerifySubscription(purchaseResult))
//                    
//                case .BigDiamondPack:
//                    let purchaseResult = SwiftyStoreKit.verifySubscription(
//                        type: .nonRenewing(validDuration: 60),
//                        productId: productId,
//                        inReceipt: receipt,
//                        validUntil: Date()
//                    )
//                    self.rootViewController.showAlert(self.rootViewController.alertForVerifySubscription(purchaseResult))
//                }
//                
//            case .error:
//                self.rootViewController.showAlert(self.rootViewController.alertForVerifyReceipt(result))
//            }
//        }
//    }
}

// MARK: User facing alerts
extension UIViewController
{
    
    func alertWithTitle(_ title: String, message: String) -> UIAlertController {
        
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
    func alertForPurchaseResult(_ result: PurchaseResult) -> UIAlertController? {
        switch result {
        case .success(let purchase):
            print("Purchase Success: \(purchase.productId)")
            return alertWithTitle("Thank You", message: "Purchase completed")
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

