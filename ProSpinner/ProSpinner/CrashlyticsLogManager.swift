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
    static var AllowEvents = false
    
    static func gameStarted()
    {
        if AllowEvents
        {
            Answers.logLevelStart("Game Started",
                                  customAttributes: [:])
        }
    }
    
    static func gameEnded(withScore score: NSNumber?)
    {
        if AllowEvents
        {
            Answers.logLevelEnd("GameEnded", score: score, success: nil, customAttributes: nil)
        }
    }
    
    static func logPurchase(withProduct product: PurchaseDetails)
    {
        if AllowEvents
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
    
    static func logSpinnerUnlocked()
    {
        if AllowEvents
        {
            let unlockSpinnerNumber = ArchiveManager.currentSpinner.id ?? -1
            
            Answers.logCustomEvent(withName: "Spinner Unlock #No:",
                                   customAttributes: ["SpinnerID": unlockSpinnerNumber ])
        }
    }
}
