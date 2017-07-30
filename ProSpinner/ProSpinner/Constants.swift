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
        case red    = "redDiamond"
        case blue   = "blueDiamond"
        case green  = "greenDiamond"
    }

    enum actionKeys: String
    {
        case rotate         = "rotateAction"
        case shakeDiamond   = "shakeDiamond"
        case MoveSuccessV   = "MoveSuccessV"
    }
    
    enum DiamondsPlayerNeed: String
    {
        case red    = "redNeeded"
        case blue   = "blueNeeded"
        case green  = "greenNeeded"
    }
    
    enum ProgressBars: String
    {
        case red    = "redProgressBar"
        case blue   = "blueProgressBar"
        case green  = "greenProgressBar"
    }
    
    struct DiamondProgressBarColor
    {
        static let redColor   = UIColor(red: 196/255,green: 43/255,blue: 40/255,alpha: 1.0)
        static let blueColor  = UIColor(red: 67/255,green: 188/255,blue: 212/255,alpha: 1.0)
        static let greenColor = UIColor(red: 103/255,green: 198/255,blue: 49/255,alpha: 1.0)
        static let manuGreenBlue = UIColor(red: 0/255,green: 68/255,blue: 65/255,alpha: 1.0)
    }
    
    enum NodesInScene : String
    {
        case LeftArrow          = "previousSpinner"
        case RightArrow         = "nextSpinner"
        case Spinner            = "spinner"
        case ProgressBars       = "ProgressBars"
        
        case RedSuccess         = "RedSuccess"
        case BlueSuccess        = "BlueSuccess"
        case GreenSuccess       = "GreenSuccess"
        
        case BreifTutorial      = "BreifTutorial"
        
        case HighScoreRecord    = "HighScoreRecord"
        
        case DemiSpinnerNode    = "DemiSpinnerNode"
        case ReviewButton       = "reviewButton"
        case ReviewButtonShadow = "reviewButtonShadow"
        
    }
    
    enum NodeInExplainGameNode : String
    {
        case TutorialNode = "TutorialNode"
        case ExplainGameImage = "ExplainGameImage"
        case Gotit = "Gotit"
        case GotitShadow = "GotitShadow"
    }
    
    enum NodesInPlayNode : String
    {
        case PlayNode   = "PlayNode"
        case PlayLabel  = "PlayLabel"
        case PlayShadow = "PlayLabelShadow"
        case RightEar   = "RightEar"
        case LeftEar    = "LeftEar"
        case kingHat    = "kingHat"
    }
    
    enum NodesInSpeedbarNode : String
    {
        case SpeedBarNode = "SpeedBarNode"
        case SpeedProgressBar = "SpeedProgressBar"
        case CurrentSpeed = "CurrentSpeed"
        case crownGlow = "crownGlow"
    }
    
    enum NodesInRetryView: String
    {
        case RetryView          = "RetryView"
        case BlueDiamondLabel   = "BlueDiamondLabel"
        case RedDiamondLabel    = "RedDiamondLabel"
        case GreenDiamondLabel  = "GreenDiamondLabel"
        case RetryButton        = "RetryButton"
        case RetryButtonArrow   = "RetryButtonArrow"
        case ExitButton         = "ExitButton"
        case MenuLines          = "MenuLines"
        case TimePassed         = "TimePassed"
        case TotalDiamondsCollected = "TotalDiamondsCollected"
        case EndGameAlert           = "EndGameAlert"
        case AlertViewBackground    = "AlertViewBackground"
        case ShareFacebook          = "ShareFacebook"
    }
    
    enum NodesInStoreView: String
    {
        case StoreNode              = "StoreNode"
        case StoreView              = "StoreView"
        case StoreButton            = "StoreButton"
        case StoreButtonShadow      = "StoreButtonShadow"
        case StoreBackground        = "StoreBackground"
        case storeAlert             = "StoreAlert"
        case exitButton             = "ExitButton"
        case bigDiamondGroupCost    = "BigDiamondGroupCost"
        case smallDiamondGroupCost  = "SmallDiamondGroupCost"
        case bigDiamondGroup        = "BigDiamondGroup"
        case smallDiamondGroup      = "SmallDiamondGroup"
        case smallPackButton        = "smallPackButton"
        case bigPackButton          = "bigPackButton"
    }
    
    enum NodesInSideMenu: String
    {
        case SideMenu              = "SideMenu"
        case muteSound             = "muteSound"
        case sideMenuBackground    = "sideMenuBackground"
    }
    
    enum NodesInLockedSpinnerView: String
    {
        case LockedSpinnerNode          = "LockedSpinnerNode"
        
        case LockedSpinnerBackground    = "LockedSpinnerBackground"
        case UnlockSpinnerButtonGrayout = "UnlockSpinnerButtonGrayout"
        case RedPrice                   = "RedPriceLabel"
        case BluePrice                  = "BluePriceLabel"
        case GreenPrice                 = "GreenPriceLabel"
        case SpinnerLock                = "SpinnerLock"
        case UnlockSpinnerButton        = "UnlockSpinnerButton"
        case UnlockSpinnerButtonShadow  = "UnlockSpinnerButtonShadow"
        case GetMoreDiamondsButton      = "StoreButton"
        case GetMoreDiamondsButtonShadow = "getMoreDiamondsButtonShadow"
        case TopLabel                   = "TopLabel"
    }
    
    enum NodesInLockedWhenPurchase: String
    {
        case StorePurchaseInProgressAlert   = "StorePurchaseInProgressAlert"
        case RedToRecive                    = "redToRecive"
        case BlueToRecive                   = "blueToRecive"
        case GreenToRecive                  = "greenToRecive"
        case PackageRequested               = "packageRequested"
        case loadingSpinner                 = "loadingSpinner"
    }
    
    enum NodesInGameModeNode: String
    {
        case GameModeNode = "GameModeNode"
        case GameModeBackground = "GameModeBackground"
        case GameModeAlert = "GameModeAlert"
        case FreeSpinNode = "FreeSpinNode"
        case FixedSpinNode = "FixedSpinNode"
        case FreeSpinGameMode = "FreeSpinGameMode"
        case FixedSpinGameMode = "FixedSpinGameMode"
        case selectGame = "selectGame"
        case CometDiamond = "CometDiamond"
        case KingHat = "KingHat"
        case FixedGameModeBackground = "FixedGameModeBackground"
        case FixedHighScoreLabel = "FixedHighScoreLabel"
        case FreeHighScoreLabel = "FreeHighScoreLabel"
        case freeText = "freeText"
        case fixedText = "fixedText"
    }
}

let applicationReviewUrl = URL(string: "itms-apps://itunes.apple.com/app/id1257742091") // ProSpinner
let applicationItunesUrl = URL(string: "https://itunes.apple.com/us/app/ProSpinner---The-Best-Fidget-Spinner-Game/id1257742091&mt=8")

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

public extension DispatchQueue {
    
    static var `default`: DispatchQueue {
        return DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
    }
    
    static var initiated: DispatchQueue {
        return DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated)
    }
    
    static var interactive: DispatchQueue {
        return DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive)
    }
    
    static var utility: DispatchQueue {
        return DispatchQueue.global(qos: DispatchQoS.QoSClass.utility)
    }
    
    static var background: DispatchQueue {
        return DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
    }
    
    static func concurrent(label: String, qos: DispatchQoS = .default, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency = .inherit, target: DispatchQueue? = nil) -> DispatchQueue {
        return DispatchQueue(label: label, qos: qos, attributes: [.concurrent], autoreleaseFrequency: autoreleaseFrequency, target: target)
    }
    
    static var currentQoSClass: DispatchQoS.QoSClass {
        return DispatchQoS.QoSClass(rawValue: qos_class_self()) ?? .unspecified
    }
}
