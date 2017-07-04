//
//  PurchaseManager.swift
//  ProSpinner
//
//  Created by AlexP on 2.6.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import Foundation
import StoreKit

class PurchaseManager: NSObject,
                       SKProductsRequestDelegate,
                       SKPaymentTransactionObserver
{
    private var list = [SKProduct]()
    private var product = SKProduct()
    
    func restoreSpinners()
    {
        if(SKPaymentQueue.canMakePayments())
        {
            print("IAP is enabled, loading")
            let productID:NSSet = NSSet(objects: "finnci.Premium")
            let request: SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
            
            request.delegate = self
            request.start()
        } else {
            print("please enable IAPS")
        }
    }
    
    func BuySpinner()
    {
        if(SKPaymentQueue.canMakePayments())
        {
            print("IAP is enabled, loading")
            let productID:NSSet = NSSet(objects: "finnci.Premium")
            let request: SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
            
            request.delegate = self
            request.start()
        } else {
            print("please enable IAPS")
        }
    }
    
    func buyProduct()
    {
//        print("buy " + product.productIdentifier)
//        let pay = SKPayment(product: product)
//        SKPaymentQueue.default().add(self)
//        SKPaymentQueue.default().add(pay)
    }
    
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse)
    {
        print("product request")
        let myProduct = response.products
        
        for product in myProduct {
            print("product added")
            print(product.productIdentifier)
            print(product.localizedTitle)
            print(product.localizedDescription)
            print(product.price)
            
            list.append(product )
        }
        
        
        
       // if shouldBuy == 1
       // {        // Set IAPS
            for actualProduct in list
            {
                let prodID = product.productIdentifier
                if(prodID == "finnci.Premium") {
                    product = actualProduct
                    buyProduct()
                    break;
                }
            }
        //}
       // else if shouldRestore == 2
       // {  // Set IAPS
//            for actualProduct in list
//            {
//                let prodID = product.productIdentifier
//                if(prodID == "finnci.Premium") {
//                    product = actualProduct
//                    if (SKPaymentQueue.canMakePayments()) {
//                        SKPaymentQueue.default().restoreCompletedTransactions()
//                        SKPaymentQueue.default().add(self)
//                    }
//                    break;
//                }
//            }
       // }
       
    }
    
    private func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue)
    {
        print("transactions restored")
        
        for transaction in queue.transactions {
            let t: SKPaymentTransaction = transaction
            
            let prodID = t.payment.productIdentifier as String
            
            switch prodID {
            case "finnci.Premium":
                print("is premium")
                
                
            default:
                print("IAP not setup")
            }
            
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("add paymnet")
        
        for transaction:AnyObject in transactions {
            let trans = transaction as! SKPaymentTransaction
            print(trans.error as Any)
            
            switch trans.transactionState {
                
            case .purchased ,
                 .restored:
                
                print("buy, ok unlock iap here")
                print(product.productIdentifier)
                
                // Make Export available
                UserDefaults.standard.set(true, forKey: "Premium")
                
                let alert = UIAlertView()
                alert.title = "משתמש יקר"
                alert.message = "את/ה כעת משתמש פרימיום !"
                alert.addButton(withTitle: "המשך")
                alert.show()
                
                
                let prodID = product.productIdentifier as String
                
                switch prodID {
                case "finnci.Premium":
                    print("is premium")
                    
                default:
                    print("IAP not setup")
                }
                
                queue.finishTransaction(trans)
                break;
                
            case .failed:
                
                print("buy error")
                queue.finishTransaction(trans)
                break;
            default:
                print("default")
                break;
                
            }
        }
    }
    
    func finishTransaction(trans:SKPaymentTransaction)
    {
        print("finish trans")
        SKPaymentQueue.default().finishTransaction(trans)
    }
}
