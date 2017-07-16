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

var enableSwipe = true

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
    
    var lastNodeTouchedName = ""
    
    var spinnerNode     : SKSpriteNode = SKSpriteNode()
    
    var backgroundMusic: SKAudioNode!
    
//  MARK: Scene life cycle
    override func didMove(to view: SKView)
    {
        log.debug("")
        handleSwipeConfiguration()
        addObservers()
        configureSound()
    }
    
    private func addObservers()
    {
        log.debug()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadLockedViewAfterPurchase),
                                               name: NSNotification.Name(rawValue: NotificationName.reloadLockedViewAfterPurchase.rawValue),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(notifyGameEnded),
                                               name: NSNotification.Name.UIApplicationDidEnterBackground,
                                               object: nil)
    }
//  MARK: Physics Contact Delegate
    func didBegin(_ contact: SKPhysicsContact)
    {
        log.debug("")
       guard let spinnerNode = contact.bodyA.node  as? SKShapeNode else { return } // Spinner
       guard let diamondShapeNode = contact.bodyB.node  as? SKShapeNode  else { return } // Physics Body Shape
       guard let diamondNode = diamondShapeNode.parent  as? Diamond  else { return } // Diamond
       guard let diamondName = diamondNode.name else { return }
       guard let spinnerName = spinnerNode.name else { return }
        
        if diamondName.contains(spinnerName)
        {
            diamondsManager?.contactBegan(for: diamondNode)
            spinnerManager?.contactBegan()
        }
        else
        {
            notifyGameEnded()
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
            manuManager?.lockedSpinnerView?.getMoreDiamondsButton?.releasedButton()
            manuManager?.demiSpinnerNode?.reviewButton?.releasedButton()
            
            if manuManager?.lockedSpinnerView?.userCanUnlockSpinner == true
            {
                manuManager?.lockedSpinnerView?.unlockSpinnerButton?.releasedButton()
            }
            
            if let name = touchedNode.name, spinnerManager?.currentlySwitchingSpinner == false
            {
                guard lastNodeTouchedName == name else { return }
                switch name
                {
                case Constants.NodesInPlayNode.PlayLabel.rawValue:
                    notifyGameStarted()
                    enableSwipe = false
                    
                case Constants.NodesInStoreView.StoreButton.rawValue:
                    storeView?.presentStoreView()
                    enableSwipe = false
                    
                case Constants.NodesInScene.RightArrow.rawValue:
                    userTappedNextSpinner()
                    
                case Constants.NodesInScene.LeftArrow.rawValue:
                    userTappedPreviousSpinner()
                    
                case Constants.NodesInLockedSpinnerView.UnlockSpinnerButton.rawValue,
                     Constants.NodesInLockedSpinnerView.UnlockSpinnerButtonGrayout.rawValue:
                    
                    if manuManager?.lockedSpinnerView?.userCanUnlockSpinner == true
                    {
                        changeVolumeTo(value: 0.1, duration: 1.0)
                        scene?.run(SoundLibrary.spinnerUnlocked)
                        spinnerManager?.purchasedNewSpinner()
                        {
                            self.changeVolumeTo(value: 0.6, duration: 1)
                        }
                        handleUIForUnlockedSpinner()
                    }
                    
                case Constants.NodesInRetryView.ExitButton.rawValue,
                     Constants.NodesInRetryView.MenuLines.rawValue,
                     Constants.NodesInRetryView.AlertViewBackground.rawValue,
                     Constants.NodesInStoreView.StoreBackground.rawValue:
                    
                    if storeView?.isHidden == false
                    {
                        hideStoreView()
                    }
                    else if retryView?.isHidden == false
                    {
                        hideRetryView()
                    }
                    
                case Constants.NodesInStoreView.smallPackButton.rawValue,
                     Constants.NodesInStoreView.smallDiamondGroupCost.rawValue:
                    
                    storeView?.configurePurchaseAlert(registeredPurchase: .SmallDiamondPack)
                    PurchaseManager.purchase(.SmallDiamondPack, completion: { (registeredPurchase,success) in
                        
                        if success
                        {
                            self.storeView?.hideStoreView()
                            self.diamondsManager?.didSuccessInBuying(purchaseType: .SmallDiamondPack)
                            enableSwipe = true
                        }
                        self.storeView?.resetLoadingPurchase()
                    })

                case Constants.NodesInStoreView.bigPackButton.rawValue,
                     Constants.NodesInStoreView.bigDiamondGroupCost.rawValue:
                    
                    storeView?.configurePurchaseAlert(registeredPurchase: .BigDiamondPack)
                    PurchaseManager.purchase(.BigDiamondPack, completion: { (registeredPurchase,success) in
                        
                        if success
                        {
                            self.storeView?.hideStoreView()
                            self.diamondsManager?.didSuccessInBuying(purchaseType: .BigDiamondPack)
                            enableSwipe = true
                        }
                        self.storeView?.resetLoadingPurchase()
                    })
                    
                case Constants.NodesInRetryView.RetryButton.rawValue,
                     Constants.NodesInRetryView.RetryButtonArrow.rawValue:
                    retryView?.hideRetryView()
                    notifyGameStarted()
                    
                case Constants.NodesInRetryView.ShareFacebook.rawValue:
                    retryView?.shareWithFacebook()
                    
                case Constants.NodesInScene.ReviewButton.rawValue:
                    manuManager?.demiSpinnerNode?.goToItunesForReview(completion: { (success) in
                        
                    })
                    
                case Constants.NodesInScene.muteSound.rawValue:
                    ArchiveManager.shouldPlaySound = !ArchiveManager.shouldPlaySound
                    playSoundIfNeeded()
                    
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
            
            if let name = touchedNode.name, spinnerManager?.currentlySwitchingSpinner == false
            {
                lastNodeTouchedName = name
                switch name
                {
                case Constants.NodesInPlayNode.PlayLabel.rawValue:
                    manuManager?.playNode?.playLabel?.touchedUpInside()
                    
                case Constants.NodesInStoreView.StoreButton.rawValue:
                    manuManager?.lockedSpinnerView?.getMoreDiamondsButton?.touchedUpInside()
                    manuManager?.storeNode?.storeButton?.touchedUpInside()

                case Constants.NodesInLockedSpinnerView.UnlockSpinnerButton.rawValue,
                     Constants.NodesInLockedSpinnerView.UnlockSpinnerButtonGrayout.rawValue:
                    
                    if manuManager?.lockedSpinnerView?.userCanUnlockSpinner == false
                    {
                        manuManager?.lockedSpinnerView?.shakeUnlockButton()
                    }
                    else
                    {
                        manuManager?.lockedSpinnerView?.unlockSpinnerButton?.touchedUpInside()
                    }
                    
                case Constants.NodesInStoreView.smallPackButton.rawValue,
                     Constants.NodesInStoreView.smallDiamondGroupCost.rawValue:
                    
                    storeView?.touchedUpSmallPackButton()
                    
                case Constants.NodesInStoreView.bigPackButton.rawValue,
                     Constants.NodesInStoreView.bigDiamondGroupCost.rawValue:
                    
                    storeView?.touchedUpBigPackButton()
                    
                case Constants.NodesInScene.ReviewButton.rawValue:
                    manuManager?.demiSpinnerNode?.reviewButton?.touchedUpInside()
                    
                    
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
            changeVolumeTo(value: 0.05, duration: 1.5)
            GameStatus.Playing = true
            retryView?.gameStarted()
            manuManager?.gameStarted()
            diamondsManager?.gameStarted()
            spinnerManager?.gameStarted()
            manuManager?.showGameExplanation(startSpining: {
                self.spinnerManager?.rotateToOtherDirection()
                self.diamondsManager?.configureDiamonds()
            })
            CrashlyticsLogManager.gameStarted()
        }
    }
    
    func notifyGameEnded()
    {
        if GameStatus.Playing
        {
            GameStatus.Playing = false
            changeVolumeTo(value: 0.6, duration: 1.5)
            retryView?.gameOver()
            retryView?.setDiamondsCollected(diamonds: diamondsManager?.getCollectedDiamondsDuringGame())
            retryView?.presentRetryView()
            {
                self.handleInterstitialCount()
            }
            manuManager?.gameOver()
            diamondsManager?.gameOver()
            spinnerManager?.gameOver()
        }
    }
    
    func finishedReseting()
    {
        log.debug("")
        if GameStatus.Playing == false
        {
            manuManager?.showManuItems()
        }
    }

//  MARK: Private methods
    private func configureSound()
    {
        if let musicURL = Bundle.main.url(forResource: "BackgroundMusic", withExtension: "wav")
        {
            backgroundMusic = SKAudioNode(url: musicURL)
            addChild(backgroundMusic)
            backgroundMusic?.run(SKAction.stop())
            backgroundMusic?.run(SKAction.changeVolume(to: 0, duration: 0))
            playSoundIfNeeded()
        }
    }
    
    private func playSoundIfNeeded()
    {
        if ArchiveManager.shouldPlaySound
        {
            backgroundMusic?.run(SKAction.play())
            backgroundMusic?.run(SKAction.changeVolume(to: 0.6, duration: 5))
        }
        else
        {
            backgroundMusic?.run(SKAction.stop())
        }
    }
    
    func changeVolumeTo(value: Float ,duration: TimeInterval)
    {
        if ArchiveManager.shouldPlaySound
        {
            backgroundMusic?.run(SKAction.changeVolume(to: value, duration: duration))
        }
    }
    
    private func handleInterstitialCount()
    {
        log.debug("")
        ArchiveManager.interstitalCount += 1
        if ArchiveManager.interstitalCount >= 3
        {
            NotificationCenter.default.post(Notification(name: NSNotification.Name("interstitalCount")))
        }
    }

    func reloadLockedViewAfterPurchase()
    {
        handleLockViewAppearance()
    }
    
    private func handleLockViewAppearance()
    {
        log.debug("")
        if ArchiveManager.spinnersArrayInDisk[ArchiveManager.currentlyAtIndex].unlocked == false
        {
            let diamondsCount = diamondsManager?.getDiamondsCount()
            diamondsManager?.handleDiamondsWhenSpinner(isLocked: true)
            diamondsManager?.handleDiamondsPlayerNeedAndHaveLabels(isLocked :true)
            manuManager?.handleSpinnerPresentedIsLocked(with: diamondsCount)
            spinnerManager?.shakeSpinnerLocked(shouldShake: true)
        }
        else
        {
            diamondsManager?.handleDiamondsWhenSpinner(isLocked: false)
            diamondsManager?.handleDiamondsPlayerNeedAndHaveLabels(isLocked : false)
            manuManager?.handleSpinnerPresentedIsUnlocked()
            spinnerManager?.shakeSpinnerLocked(shouldShake: false)
        }
    }
    
    private func handleUIForUnlockedSpinner()
    {
        diamondsManager?.purchasedNewSpinner()
        diamondsManager?.handleDiamondsWhenSpinner(isLocked: false)
        diamondsManager?.handleDiamondsPlayerNeedAndHaveLabels(isLocked : false)
        manuManager?.handleSpinnerPresentedIsUnlocked()
        spinnerManager?.shakeSpinnerLocked(shouldShake: false)
    }
    
    private func hideStoreView()
    {
        if storeView?.finishedPresentingView == true
        {
            enableSwipe = true
            storeView?.hideStoreView()
        }
    }
    
    private func hideRetryView()
    {
        if retryView?.finishedPresentingView == true && GameStatus.Playing == false
        {
            enableSwipe = true
            spinnerManager?.scaleUpSpinner()
            retryView?.hideRetryView()
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
    
    func userTappedNextSpinner()
    {
        self.run(SoundLibrary.spinnerChangedDirection)
        spinnerManager?.userTappedNextSpinner()
            {
                self.handleLockViewAppearance()
        }
    }
    
    func userTappedPreviousSpinner()
    {
        self.run(SoundLibrary.spinnerChangedDirection)
        spinnerManager?.userTappedPreviousSpinner()
            {
                self.handleLockViewAppearance()
        }
    }
    
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        log.debug("")

        if let gesture = gestureRecognizer as? UISwipeGestureRecognizer, enableSwipe == true
        {
            switch gesture.direction
            {
            case UISwipeGestureRecognizerDirection.right: userTappedNextSpinner()
            case UISwipeGestureRecognizerDirection.left: userTappedPreviousSpinner()
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
