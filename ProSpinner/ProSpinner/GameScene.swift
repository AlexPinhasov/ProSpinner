//
//  GameScene.swift
//  ProSpinner
//
//  Created by Alex Pinhasov on 15/05/2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import AVFoundation
import SpriteKit
import GameplayKit
import UIKit

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
    var sideMenuView    : SideMenuView?
    var gameModeView    : GameModeView?
    
    var lastNodeTouchedName = ""
    
    var spinnerNode     : SKSpriteNode = SKSpriteNode()
    
    var selectedGameMode: GameMode?
    
//  MARK: Scene life cycle
    override func didMove(to view: SKView)
    {
        log.debug("")
        handleSwipeConfiguration()
        addObservers()
        sideMenuView?.showSideView()
        SoundController.setUpSoundEngine()        
    }
    
    private func addObservers()
    {
        log.debug()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadLockedViewAfterPurchase),
                                               name: NSNotification.Name(rawValue: NotificationName.reloadLockedViewAfterPurchase.rawValue),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(notificationsHandler),
                                               name: NSNotification.Name.UIApplicationWillResignActive,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(notificationsHandler),
                                               name: NSNotification.Name.UIApplicationDidBecomeActive,
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
            manuManager?.contactBegan()
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
            
            if GameStatus.Playing == false
            {
                storeView?.releasedButton(button: touchedNode)
                manuManager?.playNode?.playLabel?.releasedButton()
                manuManager?.storeNode?.storeButton?.releasedButton()
                manuManager?.lockedSpinnerView?.getMoreDiamondsButton?.releasedButton()
                manuManager?.demiSpinnerNode?.reviewButton?.releasedButton()
                manuManager?.gameTutorialNode?.gotItButton?.releasedButton()
            }
            
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
                    gameModeView?.presentGameModeView(completion: nil)
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
                        changeVolumeTo(value: 0.1)
                        scene?.run(SoundLibrary.spinnerUnlocked)
                        spinnerManager?.purchasedNewSpinner()
                        {
                            self.changeVolumeTo(value: 0.8)
                        }
                        handleUIForUnlockedSpinner()
                    }
                    
                case Constants.NodesInRetryView.ExitButton.rawValue,
                     Constants.NodesInRetryView.MenuLines.rawValue,
                     Constants.NodesInRetryView.AlertViewBackground.rawValue,
                     Constants.NodesInStoreView.StoreBackground.rawValue,
                     Constants.NodesInGameModeNode.GameModeBackground.rawValue:
                    
                    if storeView?.isHidden == false
                    {
                        hideStoreView()
                    }
                    else if retryView?.isHidden == false
                    {
                        selectedGameMode = nil
                        hideRetryView()
                    }
                    else if gameModeView?.isHidden == false
                    {
                        hideGameModeView()
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
                    DemiSpinnerNode.goToItunesForReview(completion: { (success) in
                        
                    })
                    
                case Constants.NodesInSideMenu.muteSound.rawValue:
                    sideMenuView?.didTapSound()
                    SoundController.playSoundIfNeeded()
                    
                case Constants.NodeInExplainGameNode.Gotit.rawValue:
                    manuManager?.hideTutorial()
                    spinnerManager?.hideTutorial()
                    notifyGameStarted()
                    
                    
                case Constants.NodesInGameModeNode.FreeSpinGameMode.rawValue,
                     Constants.NodesInGameModeNode.GameModeAlert.rawValue,
                    Constants.NodesInGameModeNode.KingHat.rawValue:
                    gameModeView?.hideGameModeView()
                    selectedGameMode = FreeSpinnerColorDropController(scene: self.scene)
                    notifyGameStarted()
                    sideMenuView?.hideSideMenu()
                    
                case Constants.NodesInGameModeNode.FixedSpinGameMode.rawValue,
                     Constants.NodesInGameModeNode.GameModeAlert.rawValue,
                     Constants.NodesInGameModeNode.CometDiamond.rawValue:
                    gameModeView?.hideGameModeView()
                    selectedGameMode = FixedSpinnerColorDropController(scene: self.scene)
                    notifyGameStarted()
                    sideMenuView?.hideSideMenu()
                    
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
                    
                case Constants.NodeInExplainGameNode.Gotit.rawValue:
                    manuManager?.gameTutorialNode?.gotItButton?.touchedUpInside()
                    
                default: break
                }
            }
            spinnerManager?.userTappedToSwitchSpinnerRotation(inPosition: positionInScene)
        }
    }
    
    func notificationsHandler(notification: NSNotification)
    {
        log.debug("")
        switch notification.name
        {
        case NSNotification.Name.UIApplicationWillResignActive:
            notifyGameEnded()
            SoundController.stopMusic()
            self.isPaused = true
        
        case NSNotification.Name.UIApplicationDidBecomeActive:
            self.isPaused = false
            SoundController.startEngineIfNeeded()
            SoundController.playSoundIfNeeded()
            
        default: break
        }
    }
    
    func notifyGameStarted()
    {
        log.debug("")
        if  ArchiveManager.gameExplantionDidShow
        {
            sideMenuView?.hideSideMenu()
            GameStatus.Playing = true
            retryView?.gameStarted()
            manuManager?.gameStarted(withGameMode: selectedGameMode)
            diamondsManager?.gameStarted(withGameMode: selectedGameMode)
            spinnerManager?.gameStarted(withGameMode: selectedGameMode)
            manuManager?.showGameExplanation(startSpining: {
                self.spinnerManager?.userTappedToSwitchSpinnerRotation(inPosition: CGPoint.zero)
                self.diamondsManager?.configureDiamonds()
            })
            CrashlyticsLogManager.gameStarted()
        }
        else
        {
            diamondsManager?.fadeOutDiamondsAndTheirCount()
            spinnerManager?.tutorialStarted()
            manuManager?.tutorialStarted()
        }
    }
    
    func notifyGameEnded()
    {
        log.debug("")
        if GameStatus.Playing
        {
            GameStatus.Playing = false
            retryView?.gameOver()
            retryView?.setDiamondsCollected(diamonds: diamondsManager?.getCollectedDiamondsDuringGame())
            retryView?.presentRetryView()
            {
                self.handleInterstitialCount()
            }
            manuManager?.gameOver()
            diamondsManager?.gameOver()
            spinnerManager?.gameOver()
            sideMenuView?.showSideView()
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
        log.debug("")
        DispatchQueue.main.async
        {
            self.handleLockViewAppearance()
        }
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
        log.debug("")
        diamondsManager?.purchasedNewSpinner()
        diamondsManager?.handleDiamondsWhenSpinner(isLocked: false)
        diamondsManager?.handleDiamondsPlayerNeedAndHaveLabels(isLocked : false)
        manuManager?.handleSpinnerPresentedIsUnlocked()
        spinnerManager?.shakeSpinnerLocked(shouldShake: false)
    }
    
    private func hideStoreView()
    {
        log.debug("")
        if storeView?.finishedPresentingView == true
        {
            enableSwipe = true
            storeView?.hideStoreView()
        }
    }

    private func hideGameModeView()
    {
        log.debug("")
        if gameModeView?.finishedPresentingView == true
        {
            enableSwipe = true
            gameModeView?.hideGameModeView()
        }
    }
    
    private func hideRetryView()
    {
        log.debug("")
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
        log.debug("")
        self.run(SoundLibrary.spinnerChangedDirection)
        spinnerManager?.userTappedNextSpinner()
            {
                self.handleLockViewAppearance()
        }
    }
    
    func userTappedPreviousSpinner()
    {
        log.debug("")
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
    
    func changeVolumeTo(value: Float)
    {
        log.debug("")
        if ArchiveManager.shouldPlaySound
        {
            self.scene?.audioEngine.mainMixerNode.outputVolume = value
        }
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
