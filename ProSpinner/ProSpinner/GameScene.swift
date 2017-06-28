//
//  GameScene.swift
//  ProSpinner
//
//  Created by Alex Pinhasov on 15/05/2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit
import GameplayKit

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
    var storeView       : StoreView?
    
    var spinnerNode     : SKSpriteNode = SKSpriteNode()
    
//  MARK: Scene life cycle
    override func didMove(to view: SKView)
    {
        log.debug("")
        spinnerManager = SpinnerManager(inScene: self)
        diamondsManager = DiamondsManager(inScene: self)
        manuManager = ManuManager(inScene: self)
        tutorialManager = TutorialManager(withScene: self)
        retryView = RetryView(scene: self)
        storeView = StoreView(scene: self)
        
        purchaseManager = PurchaseManager()
        physicsWorld.contactDelegate = self
        handleSpinnerConfiguration()
        handleManuConfiguration()
        handleDiamondConfiguration()
        handleSwipeConfiguration()
    }
//  MARK: Physics Contact Delegate
    func didBegin(_ contact: SKPhysicsContact)
    {
        log.debug("")
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
        log.debug("")
        
        
        for touch in touches
        {
            let positionInScene = touch.location(in: self)
            let touchedNode = self.atPoint(positionInScene)
            
            storeView?.releasedButton(button: touchedNode)
            manuManager?.RightArrowPressed(isPressed: false)
            manuManager?.LeftArrowPressed(isPressed: false)
            
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
                    
                case Constants.NodesInRetryView.ExitButton.rawValue:
                    retryView?.hideRetryView()
                    storeView?.hideStoreView()
                    diamondsManager?.addCollectedDiamondsToLabelScene()
                    
                case Constants.NodesInStoreView.smallPackButton.rawValue,
                     Constants.NodesInStoreView.bigPackButton.rawValue:
                    
                    purchaseManager?.buyProduct()
                    
                default: break
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        log.debug("")
        for touch in touches
        {
            let positionInScene = touch.location(in: self)
            let touchedNode = self.atPoint(positionInScene)
            
            if let name = touchedNode.name
            {
                switch name
                {
                case Constants.NodesInScene.PlayLabel.rawValue:
                    notifyGameStarted()
                    
                case Constants.NodesInScene.RightArrow.rawValue,
                     Constants.NodesInScene.ActualRightArrow.rawValue:
                    manuManager?.RightArrowPressed(isPressed: true)
                    
                case Constants.NodesInScene.LeftArrow.rawValue,
                     Constants.NodesInScene.ActualLeftArrow.rawValue:
                    manuManager?.LeftArrowPressed(isPressed: true)

                case Constants.NodesInScene.BuySpinner.rawValue:
                    handleBuySpinnerCase(for: touchedNode)
                    
                case Constants.NodesInRetryView.RetryButton.rawValue:
                    retryView?.hideRetryView()
                    notifyGameStarted()
                    
                case Constants.NodesInScene.StoreButton.rawValue:
                    storeView?.presentStoreView()
                    
                case Constants.NodesInLockedSpinnerView.ViewInfoLabel.rawValue,
                     Constants.NodesInLockedSpinnerView.unlockRedBack.rawValue:
                    
                    let canUnlockSpinner = manuManager?.lockedSpinnerViewManager?.userRequestedToUnlockSpinner(andPressedNode: touchedNode)
                    if canUnlockSpinner == true
                    {
                        spinnerManager?.purchasedNewSpinner()
                        diamondsManager?.purchasedNewSpinner()
                        manuManager?.purchasedNewSpinner()
                    }
                    
                case Constants.NodesInStoreView.smallPackButton.rawValue,
                     Constants.NodesInStoreView.bigPackButton.rawValue:
                    
                    storeView?.touchedUpForButton(buttonNode: touchedNode)
                    
                default: break
                }
            }
        }
        spinnerManager?.rotateToOtherDirection()
    }
    
    func notifyGameStarted()
    {
        log.debug("")
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
        log.debug("")
        if GameStatus.Playing == false
        {
            manuManager?.showManuItems()
            handleInterstitialCount()
        }
    }

//  MARK: Private methods
    private func handleInterstitialCount()
    {
        log.debug("")
        ArchiveManager.interstitalCount += 1
        if ArchiveManager.interstitalCount >= 5
        {
            NotificationCenter.default.post(Notification(name: NSNotification.Name("interstitalCount")))
        }
    }
    private func handleBuySpinnerCase(for touchedNode: SKNode)
    {
        log.debug("")
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
        log.debug("")
        if ArchiveManager.spinnersArrayInDisk[ArchiveManager.currentlyAtIndex].unlocked == false
        {
            let diamondsCount = diamondsManager?.getDiamondsCount()
            diamondsManager?.handleDiamondsWhenSpinner(isLocked: true)
            manuManager?.handleSpinnerPresentedIsLocked(with: diamondsCount)
            spinnerManager?.shakeSpinnerLocked(shouldShake: true)
        }
        else
        {
            diamondsManager?.handleDiamondsWhenSpinner(isLocked: false)
            manuManager?.handleSpinnerPresentedIsUnlocked()
            spinnerManager?.shakeSpinnerLocked(shouldShake: false)
        }
    }
    
//  MARK: Private Configuration methods
    private func handleDiamondConfiguration()
    {
        log.debug("")
        diamondsManager?.loadDiamondCount()
        Diamond.diamondsXPosition = spinnerNode.position.x
    }
    
    private func handleManuConfiguration()
    {
        log.debug("")
        manuManager?.configureManu()
    }

    private func handleSpinnerConfiguration()
    {
        log.debug("")
        guard let spinnerNode = spinnerManager?.configureSpinner(withPlaceHolder: self.spinnerNode) else { return }
        spinnerNode.name = Constants.NodesInScene.Spinner.rawValue
        
        self.addChild(spinnerNode)
        
        spinnerManager?.spinnerNode = self.childNode(withName: Constants.NodesInScene.Spinner.rawValue) as? SKSpriteNode
    }
    
    func userSwipedRight()
    {
        log.debug("")
        if GameStatus.Playing == false
        {
            spinnerManager?.userTappedNextSpinner()
            {
                    self.handleLockViewAppearance()
            }
        }
    }
    
    func userSwipedLeft()
    {
        log.debug("")
        if GameStatus.Playing == false
        {
            spinnerManager?.userTappedPreviousSpinner()
            {
                    self.handleLockViewAppearance()
            }
        }
    }
    
    private func handleSwipeConfiguration()
    {
        log.debug("")
        let swipeRight: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(userSwipedRight))
        swipeRight.direction = .right
        view?.addGestureRecognizer(swipeRight)
        
        let swipeLeft: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(userSwipedLeft))
        swipeLeft.direction = .left
        view?.addGestureRecognizer(swipeLeft)
    }
}
