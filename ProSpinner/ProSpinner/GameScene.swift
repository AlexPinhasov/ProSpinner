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
                 SKPhysicsContactDelegate,UIGestureRecognizerDelegate
{
    var spinnerManager  : SpinnerManager?
    var diamondsManager : DiamondsManager?
    var manuManager     : ManuManager?
    var purchaseManager : PurchaseManager?
    var tutorialManager : TutorialManager?
    var retryView       : RetryView?
    var storeView       : StoreView?
    
    var enableSwipe = true
    
    var spinnerNode     : SKSpriteNode = SKSpriteNode()
    
//  MARK: Scene life cycle
    override func didMove(to view: SKView)
    {
        log.debug("")
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
            enableSwipe = false
            GameStatus.Playing = false
            retryView?.gameOver()
            retryView?.setDiamondsCollected(diamonds: diamondsManager?.getCollectedDiamondsDuringGame())
            retryView?.presentRetryView()
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
            
            manuManager?.playNode?.playLabel?.releasedButton()
            manuManager?.storeNode?.storeButton?.releasedButton()
            
            manuManager?.RightArrowPressed(isPressed: false)
            manuManager?.LeftArrowPressed(isPressed: false)
            
            if let name = touchedNode.name
            {
                switch name
                {
                case Constants.NodesInPlayNode.PlayLabel.rawValue:
                    notifyGameStarted()
                    enableSwipe = false
                    
                case Constants.NodesInStoreView.StoreButton.rawValue:
                    storeView?.presentStoreView()
                    enableSwipe = false
                    
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
                    
                case Constants.NodesInRetryView.ExitButton.rawValue,
                     Constants.NodesInRetryView.MenuLines.rawValue:
                    enableSwipe = true
                    retryView?.hideRetryView()
                    storeView?.hideStoreView()
                    diamondsManager?.addCollectedDiamondsToLabelScene()
                    
                case Constants.NodesInStoreView.smallPackButton.rawValue,
                     Constants.NodesInStoreView.bigPackButton.rawValue:
                    
                    purchaseManager?.buyProduct()
                    
                case Constants.NodesInRetryView.RetryButton.rawValue,
                     Constants.NodesInRetryView.RetryButtonArrow.rawValue:
                    retryView?.hideRetryView()
                    notifyGameStarted()
                    
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
                case Constants.NodesInPlayNode.PlayLabel.rawValue:
                    manuManager?.playNode?.playLabel?.touchedUpInside()
                    
                case Constants.NodesInScene.RightArrow.rawValue:
                    manuManager?.RightArrowPressed(isPressed: true)
                    
                case Constants.NodesInScene.LeftArrow.rawValue:
                    manuManager?.LeftArrowPressed(isPressed: true)

                case Constants.NodesInScene.BuySpinner.rawValue:
                    handleBuySpinnerCase(for: touchedNode)
                    
                case Constants.NodesInStoreView.StoreButton.rawValue:
                    manuManager?.storeNode?.storeButton?.touchedUpInside()
                    
                case Constants.NodesInLockedSpinnerView.ViewInfoLabel.rawValue,
                     Constants.NodesInLockedSpinnerView.BottomLockedView.rawValue,
                     Constants.NodesInLockedSpinnerView.TopLockedView.rawValue:
                    
                    let canUnlockSpinner = manuManager?.lockedSpinnerView?.userRequestedToUnlockSpinner()
                    if canUnlockSpinner == true
                    {
                        spinnerManager?.purchasedNewSpinner()
                        diamondsManager?.purchasedNewSpinner()
                        manuManager?.purchasedNewSpinner()
                    }
                    
                case Constants.NodesInStoreView.smallPackButton.rawValue,
                     Constants.NodesInStoreView.smallDiamondGroupCost.rawValue:
                    
                    storeView?.touchedUpSmallPackButton()
                    
                case Constants.NodesInStoreView.bigPackButton.rawValue,
                     Constants.NodesInStoreView.bigDiamondGroupCost.rawValue:
                    
                    storeView?.touchedUpBigPackButton()
                    
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
            GameStatus.Playing = true
            retryView?.gameStarted()
            manuManager?.gameStarted()
            diamondsManager?.gameStarted()
            spinnerManager?.gameStarted()
            manuManager?.showGameExplanation(startSpining: {
                self.spinnerManager?.rotateToOtherDirection()
                self.diamondsManager?.configureDiamonds()
            })
        }
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
    func handleDiamondConfiguration()
    {
        log.debug("")
        diamondsManager?.loadDiamondCount()
        Diamond.diamondsXPosition = spinnerNode.position.x
    }
    
    func handleManuConfiguration()
    {
        log.debug("")
        manuManager?.configureManu()
    }

    func handleSpinnerConfiguration()
    {
        log.debug("")
        guard let spinnerNode = spinnerManager?.configureSpinner(withPlaceHolder: self.spinnerNode) else { return }
        spinnerNode.name = Constants.NodesInScene.Spinner.rawValue
        
        self.addChild(spinnerNode)
        
        spinnerManager?.spinnerNode = self.childNode(withName: Constants.NodesInScene.Spinner.rawValue) as? SKSpriteNode
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        log.debug("")

        if let gesture = gestureRecognizer as? UISwipeGestureRecognizer, enableSwipe == true
        {
            switch gesture.direction
            {
            case UISwipeGestureRecognizerDirection.left:

            spinnerManager?.userTappedPreviousSpinner()
            {
                self.handleLockViewAppearance()
            }
                
            case UISwipeGestureRecognizerDirection.right:
                
            spinnerManager?.userTappedNextSpinner()
            {
                self.handleLockViewAppearance()
            }
                
            default: break
            }
        }
        return enableSwipe
    }
    
    func handleSwipeConfiguration()
    {
        log.debug("")
        let swipeRight = UISwipeGestureRecognizer(target: self, action: nil)
        swipeRight.direction = .right
        swipeRight.delegate = self
        view?.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: nil)
        swipeLeft.direction = .left
        swipeLeft.delegate = self
        view?.addGestureRecognizer(swipeLeft)
    }
}
