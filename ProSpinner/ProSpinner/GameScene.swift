//
//  GameScene.swift
//  ProSpinner
//
//  Created by Alex Pinhasov on 15/05/2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit
import GameplayKit


struct PhysicsCategory
{
    static let greenDiamond : UInt32 = 1
    static let redDiamond : UInt32 = 2
    static let blueDiamond : UInt32 = 3
    
    static let greenNode : UInt32 = 4
    static let redNode : UInt32 = 5
    static let blueNode : UInt32 = 6
}

struct GameStatus
{
    static var Playing : Bool = false
}

class GameScene: SKScene,
                 SKPhysicsContactDelegate
{
    var spinnerManager  : SpinnerManager?
    var diamondsManager : DiamondsManager?
    var manuManager     : ManuManager?
    var purchaseManager : PurchaseManager?
    var tutorialManager : TutorialManager?
    var retryView       : RetryView?
    
    var spinnerNode     : SKSpriteNode = SKSpriteNode()
    
//  MARK: Scene life cycle
    override func didMove(to view: SKView)
    {
        spinnerManager = SpinnerManager(inScene: self)
        diamondsManager = DiamondsManager(inScene: self)
        manuManager = ManuManager(inScene: self)
        tutorialManager = TutorialManager(withScene: self)
        retryView = RetryView(scene: self)
        purchaseManager = PurchaseManager()
        physicsWorld.contactDelegate = self
        handleSpinnerConfiguration()
        handleManuConfiguration()
        handleDiamondConfiguration()        
    }
//  MARK: Physics Contact Delegate
    func didBegin(_ contact: SKPhysicsContact)
    {
       guard let spinnerNode = contact.bodyA.node  as? SKShapeNode else { return } // Spinner
       guard let diamondNode = contact.bodyB.node  as? Diamond  else { return } // Diamond
       guard let diamondName = diamondNode.name else { return }
       guard let spinnerName = spinnerNode.name else { return }
        
        if diamondName.contains(spinnerName)
        {
            diamondsManager?.contactBegan(for: diamondNode)
            spinnerManager?.contactBegan()
        }
        else
        {
            retryView?.gameOver()
            retryView?.setDiamondsCollected(diamonds: diamondsManager?.getCollectedDiamondsDuringGame())
            retryView?.presentRetryView()
            GameStatus.Playing = false
            manuManager?.gameOver()
            diamondsManager?.gameOver()
            spinnerManager?.gameOver()
        }
        self.removeChildren(in: [diamondNode])
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        for touch in touches
        {
            let positionInScene = touch.location(in: self)
            let touchedNode = self.atPoint(positionInScene)
            
            if let name = touchedNode.name
            {
                switch name
                {
                case Constants.NodesInScene.RightArrow.rawValue,
                     Constants.NodesInScene.ActualRightArrow.rawValue:
                        spinnerManager?.userTappedNextSpinner()
                        {
                                self.handleLockViewAppearance()
                        }
                    
                case Constants.NodesInScene.LeftArrow.rawValue,
                     Constants.NodesInScene.ActualLeftArrow.rawValue:
                        spinnerManager?.userTappedPreviousSpinner()
                        {
                                self.handleLockViewAppearance()
                        }
                    
                default: break
                }
            }
            manuManager?.RightArrowPressed(isPressed: false)
            manuManager?.LeftArrowPressed(isPressed: false)
        }
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        for touch in touches
        {
            let positionInScene = touch.location(in: self)
            let touchedNode = self.atPoint(positionInScene)
            
            if let name = touchedNode.name
            {
                switch name
                {
                case Constants.NodesInScene.StartGame.rawValue:
                    notifyGameStarted()
                    
                case Constants.NodesInScene.RightArrow.rawValue,
                     Constants.NodesInScene.ActualRightArrow.rawValue:
                    manuManager?.RightArrowPressed(isPressed: true)
                    
                case Constants.NodesInScene.LeftArrow.rawValue,
                     Constants.NodesInScene.ActualLeftArrow.rawValue:
                    manuManager?.LeftArrowPressed(isPressed: true)

                case Constants.NodesInScene.BuySpinner.rawValue:
                    handleBuySpinnerCase(for: touchedNode)
                    
                case Constants.NodesInRetryView.ExitButton.rawValue:
                    retryView?.hideRetryView()
                    diamondsManager?.addCollectedDiamondsToLabelScene()
                    
                case Constants.NodesInRetryView.RetryButton.rawValue:
                    retryView?.hideRetryView()
                    notifyGameStarted()
                    
                default: break
                }
            }
        }
        spinnerManager?.rotateToOtherDirection()
    }
    
    func notifyGameStarted()
    {
        if TutorialManager.tutorialIsInProgress
        {
            manuManager?.tutorialStarted()
            diamondsManager?.tutorialStarted()
            spinnerManager?.tutorialStarted()
        }
        else
        {
            retryView?.gameStarted()
            manuManager?.gameStarted()
            diamondsManager?.gameStarted()
            spinnerManager?.gameStarted()
        }
        
        GameStatus.Playing = true
    }
    
    func finishedReseting()
    {
        if GameStatus.Playing == false
        {
            manuManager?.showManuItems()
            handleInterstitialCount()
        }
    }

//  MARK: Private methods
    private func handleInterstitialCount()
    {
        ArchiveManager.interstitalCount += 1
        if ArchiveManager.interstitalCount >= 5
        {
            NotificationCenter.default.post(Notification(name: NSNotification.Name("interstitalCount")))
        }
    }
    private func handleBuySpinnerCase(for touchedNode: SKNode)
    {
        if let buy = touchedNode as? SKLabelNode,
               let buyCase = buy.accessibilityValue
        {
            switch buyCase
            {
            case PurchaseOptions.BuySpinnerWithCash.rawValue: break
            purchaseManager?.BuySpinner()
                
            case PurchaseOptions.BuySpinnerWithDiamonds.rawValue:
                diamondsManager?.purchasedNewSpinner()
                manuManager?.purchasedNewSpinner()
                spinnerManager?.purchasedNewSpinner()
                
            default: break
            }
        }
    }
    
    private func handleLockViewAppearance()
    {
        if ArchiveManager.spinnersArrayInDisk[ArchiveManager.currentlyAtIndex].unlocked == false
        {
            let diamondsCount = diamondsManager?.getDiamondsCount()
            diamondsManager?.handleDiamondsWhenSpinner(isLocked: true)
            manuManager?.displayProgressBars(shouldShow: true,with: diamondsCount)
            manuManager?.showProgressBarOrV(withValues: diamondsCount)
        }
        else
        {
            diamondsManager?.handleDiamondsWhenSpinner(isLocked: false)
            manuManager?.displayProgressBars(shouldShow: false, with: nil)
            //spinnerManager?.shakeSpinnerLocked(shouldShake: false)
        }
    }
    
//  MARK: Private Configuration methods
    private func handleDiamondConfiguration()
    {
        diamondsManager?.loadDiamondCount()
        Diamond.diamondsXPosition = spinnerNode.position.x
    }
    private func handleManuConfiguration()
    {
        manuManager?.configureManu()
    }

    private func handleSpinnerConfiguration()
    {
        guard let spinnerNode = spinnerManager?.configureSpinner(withPlaceHolder: self.spinnerNode) else { return }
        spinnerNode.name = Constants.NodesInScene.Spinner.rawValue
        
        self.addChild(spinnerNode)
        
        spinnerManager?.spinnerNode = self.childNode(withName: Constants.NodesInScene.Spinner.rawValue) as? SKSpriteNode
    }
}
