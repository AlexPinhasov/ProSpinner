//
//  Constants.swift
//  ProSpinner
//
//  Created by AlexP on 6.6.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import UIKit

class Constants
{
    enum actionKeys: String
    {
        case rotate = "rotateAction"
        case shakeDiamond = "shakeDiamond"
    
    }
    
    enum DiamondsNeeded: String
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
        case StartGame = "StartGame"
        case Spinner   = "spinner"
        case ProgressBars  = "ProgressBars"
        case BuySpinner = "unlock now"
        case PlayButton = "PlayButton"
        case MuteSoundButton = "MuteSoundButton"
        case SettingsButton = "SettingsButton"
        
        case RedSuccess = "RedSuccess"
        case BlueSuccess = "BlueSuccess"
        case GreenSuccess = "GreenSuccess"
    }
    
    enum NodesInRetryView: String
    {
        case BlueDiamondLabel = "BlueDiamondLabel"
        case RedDiamondLabel = "RedDiamondLabel"
        case GreenDiamondLabel = "GreenDiamondLabel"
        case RetryButton = "RetryButton"
        case ExitButton = "ExitButton"
        case TimePassed = "TimePassed"
        case TotalDiamondsCollected = "TotalDiamondsCollected"
        case EndGameAlert = "EndGameAlert"
        case AlertViewBackground = "AlertViewBackground"
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
        
        case GrayBackground = "GrayBackground"
        case DarkBackground = "DarkBackground"
        case RedPrice = "RedPrice"
        case BluePrice = "BluePrice"
        case GreenPrice = "GreenPrice"
        case LockSprite = "LockSprite"
        case SpinnerLock = "SpinnerLock"
    }
}

extension Double
{
    var kFormatted: String
    {
        return String(format: self >= 1000 ? "$%.0fK" : "$%.0f", self >= 1000 ? self/1000 : self)
    }
}
