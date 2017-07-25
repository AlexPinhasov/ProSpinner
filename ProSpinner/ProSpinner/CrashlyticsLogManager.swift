//
//  CrashlyticsLogManager.swift
//  ProSpinner
//
//  Created by Alex Pinhasov on 12/07/2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import Crashlytics
import SwiftyStoreKit

class CrashlyticsLogManager
{
    static var AllowEvents = true
    
    static func gameStarted()
    {
        if AllowEvents
        {
            DispatchQueue.background.async
            {
                Answers.logLevelStart("Game Started",
                                      customAttributes: [:])
            }
           
        }
    }
    
    static func gameEnded(withScore score: NSNumber?)
    {
        if AllowEvents
        {
            DispatchQueue.background.async
            {
                Answers.logLevelEnd("GameEnded", score: score, success: nil, customAttributes: nil)
            }
        }
    }
    
    static func logPurchase(withProduct product: PurchaseDetails)
    {
        if AllowEvents
        {
            DispatchQueue.background.async
            {
                let locale = Locale.current
                let currencyCode = locale.currencyCode!
                
                Answers.logPurchase(withPrice: product.product.price,
                                    currency: currencyCode,
                                    success: true,
                                    itemName: product.product.localizedTitle,
                                    itemType: nil,
                                    itemId: product.productId,
                                    customAttributes: [:])
            }
        }
    }
    
    static func logSpinnerUnlocked()
    {
        if AllowEvents
        {
            DispatchQueue.background.async
            {
                let unlockSpinnerNumber = ArchiveManager.currentSpinner.id ?? -1
                
                Answers.logCustomEvent(withName: "Spinner Unlock #No:",
                                       customAttributes: ["SpinnerID": unlockSpinnerNumber ])
            }
        }
    }
}
