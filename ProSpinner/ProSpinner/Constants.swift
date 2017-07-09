//
//  Constants.swift
//  ProSpinner
//
//  Created by AlexP on 6.6.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import UIKit
import SpriteKit

class Constants
{
    struct DiamondsTexture
    {
        static let blue     = SKTexture(imageNamed: "BlueDiamond")
        static let red      = SKTexture(imageNamed: "RedDiamond")
        static let green    = SKTexture(imageNamed: "GreenDiamond")
    }
    
    struct DiamondsCleanTexture
    {
        static let blue     = SKTexture(imageNamed: "BlueCleanDiamond")
        static let red      = SKTexture(imageNamed: "RedCleanDiamond")
        static let green    = SKTexture(imageNamed: "GreenCleanDiamond")
    }
    
    enum DiamondIntColor: UInt32
    {
        case Blue   = 1
        case Red    = 2
        case Green  = 3
    }
    
    enum DiamondsName : String
    {
        case red = "redDiamond"
        case blue = "blueDiamond"
        case green = "greenDiamond"
    }

    enum actionKeys: String
    {
        case rotate = "rotateAction"
        case shakeDiamond = "shakeDiamond"
        case MoveSuccessV = "MoveSuccessV"
    }
    
    enum DiamondsPlayerNeed: String
    {
        case red = "redNeeded"
        case blue = "blueNeeded"
        case green = "greenNeeded"
    }
    
    enum ProgressBars: String
    {
        case red = "redProgressBar"
        case blue = "blueProgressBar"
        case green = "greenProgressBar"
    }
    
    enum LockedScreenStrings: String
    {
        case DiamondsNeeded = "Diamonds Needed To Unlock"
        case UnlockSpinner = "UNLOCK SPINNER !"
    }
    
    struct DiamondProgressBarColor
    {
        static let redColor   = UIColor(red: 196/255,green: 43/255,blue: 40/255,alpha: 1.0)
        static let blueColor  = UIColor(red: 67/255,green: 188/255,blue: 212/255,alpha: 1.0)
        static let greenColor = UIColor(red: 103/255,green: 198/255,blue: 49/255,alpha: 1.0)
    }
    
    enum NodesInScene : String
    {
        case LeftArrow = "previousSpinner"
        case RightArrow = "nextSpinner"
        case ActualLeftArrow = "LeftArrow"
        case ActualRightArrow = "RightArrow"
        case Spinner   = "spinner"
        case ProgressBars  = "ProgressBars"
        case BuySpinner = "unlock now"
        
        case RedSuccess = "RedSuccess"
        case BlueSuccess = "BlueSuccess"
        case GreenSuccess = "GreenSuccess"
        
        case BreifTutorial = "BreifTutorial"
        
        case HighScoreRecord = "HighScoreRecord"
    }
    
    enum NodesInPlayNode : String
    {
        case PlayNode   = "PlayNode"
        case PlayLabel  = "PlayLabel"
        case PlayShadow = "PlayLabelShadow"
        case RightEar   = "RightEar"
        case LeftEar    = "LeftEar"
    }
    
    enum NodesInRetryView: String
    {
        case RetryView       = "RetryView"
        case BlueDiamondLabel = "BlueDiamondLabel"
        case RedDiamondLabel = "RedDiamondLabel"
        case GreenDiamondLabel = "GreenDiamondLabel"
        case RetryButton = "RetryButton"
        case RetryButtonArrow = "RetryButtonArrow"
        case ExitButton = "ExitButton"
        case MenuLines = "MenuLines"
        case TimePassed = "TimePassed"
        case TotalDiamondsCollected = "TotalDiamondsCollected"
        case EndGameAlert = "EndGameAlert"
        case AlertViewBackground = "AlertViewBackground"
    }
    
    enum NodesInStoreView: String
    {
        case StoreNode       = "StoreNode"
        case StoreView       = "StoreView"
        case StoreButton     = "StoreButton"
        case StoreButtonShadow       = "StoreButtonShadow"
        case StoreBackground = "StoreBackground"
        case storeAlert = "StoreAlert"
        case exitButton = "ExitButton"
        case bigDiamondGroupCost = "BigDiamondGroupCost"
        case smallDiamondGroupCost = "SmallDiamondGroupCost"
        case bigDiamondGroup = "BigDiamondGroup"
        case smallDiamondGroup = "SmallDiamondGroup"
        case smallPackButton = "smallPackButton"
        case bigPackButton = "bigPackButton"
    }
    
    enum NodesInPriceTags: String
    {
        case PriceTags = "PriceTags"
        case RedPriceTag = "RedPriceTag"
        case BluePriceTag = "BluePriceTag"
        case GreenPriceTag = "GreenPriceTag"
        
        case RedPin = "RedPin"
        case BluePin = "BluePin"
        case GreenPin = "GreenPin"
    }
    
    enum NodesInLockedSpinnerView: String
    {
        case LockedSpinnerNode = "LockedSpinnerNode"
        
        case LockedSpinnerBackground = "LockedSpinnerBackground"
        case RedPrice = "RedPriceLabel"
        case BluePrice = "BluePriceLabel"
        case GreenPrice = "GreenPriceLabel"
        case SpinnerLock = "SpinnerLock"
        case UnlockSpinnerButton = "UnlockSpinnerButton"
        case UnlockSpinnerButtonShadow = "UnlockSpinnerButtonShadow"
        case TopLabel = "TopLabel"
    }
    
}

typealias DiamondsTuple = (red:Int,blue:Int,green:Int)?

struct PhysicsCategory
{
    static let greenDiamond : UInt32 = 1
    static let redDiamond : UInt32 = 2
    static let blueDiamond : UInt32 = 3
    
    static let greenNode : UInt32 = 4
    static let redNode : UInt32 = 5
    static let blueNode : UInt32 = 6
}


extension Double
{
    var kFormatted: String
    {
        return String(format: self >= 1000 ? "$%.0fK" : "$%.0f", self >= 1000 ? self/1000 : self)
    }
}
