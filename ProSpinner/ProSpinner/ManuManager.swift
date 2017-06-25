//
//  ManuManager.swift
//  ProSpinner
//
//  Created by AlexP on 29.5.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit

enum PurchaseOptions: String
{
    case BuySpinnerWithCash = "BuySpinnerWithCash"
    case BuySpinnerWithDiamonds = "BuySpinnerWithDiamonds"
}

struct Arrows
{
    static let rightArrowPressed = SKTexture(imageNamed: "RightButtonPressed")
    static let rightArrow        = SKTexture(imageNamed: "RightArrowButton")
    static let leftArrowPressed  = SKTexture(imageNamed: "LeftButtonPressed")
    static let leftArrow         = SKTexture(imageNamed: "LeftArrowButton")
}

class ManuManager: BaseClass,
                   Animateable
{
    fileprivate var startGame        : SKSpriteNode?
    private var settingsButton   : SKSpriteNode?
    private var muteSoundButton  : SKSpriteNode?
    
    private var leftArrowTriger  : SKSpriteNode?
    private var rightArrowTriger : SKSpriteNode?
    private var leftArrow        : SKSpriteNode?
    private var rightArrow       : SKSpriteNode?
    
    private var gameExplanation  : SKLabelNode?
    var lockedSpinnerViewManager : LockedSpinnerNodeManager?
    fileprivate var spinnerLock : SKSpriteNode?
    
    fileprivate var redSuccessV      : SKSpriteNode?
    fileprivate var blueSuccessV     : SKSpriteNode?
    fileprivate var greenSuccessV    : SKSpriteNode?
    
    // Unlock Spinner Master Node
    internal var progressBars: SKNode?
    internal var lockedSpinnerView: SKNode?
    
    internal var redProgressBarPosition = CGPoint.zero
    internal var blueProgressBarPosition = CGPoint.zero
    internal var greenProgressBarPosition = CGPoint.zero
    
//  MARK: Init methods
    init(inScene scene: SKScene?)
    {
        super.init()
        self.scene = scene
    }
    
    private func initSpriteFromScene()
    {
        log.debug("")
        // Main manu
        startGame               = scene?.childNode(withName: Constants.NodesInScene.StartGame.rawValue) as? SKSpriteNode
        leftArrowTriger         = scene?.childNode(withName: Constants.NodesInScene.LeftArrow.rawValue) as? SKSpriteNode
        rightArrowTriger        = scene?.childNode(withName: Constants.NodesInScene.RightArrow.rawValue) as? SKSpriteNode
        leftArrow               = leftArrowTriger?.childNode(withName: Constants.NodesInScene.ActualLeftArrow.rawValue) as? SKSpriteNode
        rightArrow              = rightArrowTriger?.childNode(withName: Constants.NodesInScene.ActualRightArrow.rawValue) as? SKSpriteNode
        settingsButton          = scene?.childNode(withName: Constants.NodesInScene.SettingsButton.rawValue) as? SKSpriteNode
        muteSoundButton         = scene?.childNode(withName: Constants.NodesInScene.MuteSoundButton.rawValue) as? SKSpriteNode
        
        
        progressBars            = scene?.childNode(withName: Constants.NodesInScene.ProgressBars.rawValue)
        
        gameExplanation         = scene?.childNode(withName: "gameExplanation") as? SKLabelNode
        
        redSuccessV         =  self.scene?.childNode(withName: Constants.NodesInScene.RedSuccess.rawValue) as? SKSpriteNode
        greenSuccessV       = self.scene?.childNode(withName: Constants.NodesInScene.GreenSuccess.rawValue) as? SKSpriteNode
        blueSuccessV        = self.scene?.childNode(withName: Constants.NodesInScene.BlueSuccess.rawValue) as? SKSpriteNode
        
        lockedSpinnerViewManager = self.scene?.childNode(withName: Constants.NodesInLockedSpinnerView.LockedSpinnerNode.rawValue) as? LockedSpinnerNodeManager
        lockedSpinnerViewManager?.connectOutletsToScene()
       spinnerLock = self.scene?.childNode(withName: Constants.NodesInLockedSpinnerView.SpinnerLock.rawValue) as? SKSpriteNode
    }

//  MARK: Public methods
    func configureManu()
    {
        log.debug("")
        initSpriteFromScene()
        showArrows()
        saveProgressBarPosition()
    }
    
//  MARK: Game life cycle
    func gameStarted()
    {
        log.debug("")
        hideArrows()
        hideManuItems()
        showGameExplanation()
    }
    
    func tutorialStarted()
    {
        log.debug("")
        hideArrows()
    }
    
    func gameOver()
    {
        log.debug("")
        showArrows()
    }
    
//  MARK: Spinner Locked/Unlocked master methods
    func handleSpinnerPresentedIsLocked(with diamondCount: DiamondsTuple)
    {
        log.debug("")
        removeSuccessV()
        PresentLockedSpinnerView(shouldPresent: true)
        displayProgressBars(shouldShow: true,with: diamondCount)
        showProgressBarOrV(withValues: diamondCount)
        animateSpinnerLockScaleUp()
    }
    
    func handleSpinnerPresentedIsUnlocked()
    {
        log.debug("")
        animateSpinnerLockFadeOut()
        removeSuccessV()
        displayProgressBars(shouldShow: false, with: nil)
        PresentLockedSpinnerView(shouldPresent: false)
    }
    
    
    func RightArrowPressed(isPressed pressed: Bool)
    {
        log.debug("")
        if pressed
        {
            DispatchQueue.main.async
            {
                //rightArrow?.zRotation = -3.5
                self.rightArrowTriger?.texture = Arrows.rightArrowPressed
                self.rightArrowTriger?.run(SKAction.resize(toHeight: 45, duration: 0))
            }
        }
        else
        {
            DispatchQueue.main.async
            {
                //rightArrow?.zRotation = 0
                self.rightArrowTriger?.texture = Arrows.rightArrow
                self.rightArrowTriger?.run(SKAction.resize(toHeight: 55, duration: 0))
            }
        }
    }
    
    func LeftArrowPressed(isPressed pressed: Bool)
    {
        log.debug("")
        if pressed
        {
            //leftArrow?.zRotation = 3.5
            DispatchQueue.main.async
            {
                self.leftArrowTriger?.texture = Arrows.leftArrowPressed
                self.leftArrowTriger?.run(SKAction.resize(toHeight: 45, duration: 0))
            }
        }
        else
        {
            DispatchQueue.main.async
            {
                //leftArrow?.zRotation = 0
                self.leftArrowTriger?.texture = Arrows.leftArrow
                self.leftArrowTriger?.run(SKAction.resize(toHeight: 55, duration: 0))
            }
        }
    }
    
    func PresentLockedSpinnerView(shouldPresent present: Bool)
    {
        log.debug("")
        lockedSpinnerViewManager?.presentNode(shouldPresent: present)
        lockedSpinnerViewManager?.setDiamondsPlayerNeed()
    }
    
    func decideBuyDiamondCashOrDiamonds(with diamonds: (Int,Int,Int)?)
    {
        log.debug("")
        let spinner = ArchiveManager.currentSpinner
        guard let diamonds = diamonds else { return }
        guard let redNeeded = spinner.redNeeded else { return }
        guard let blueNeeded = spinner.blueNeeded else { return }
        guard let greenNeeded = spinner.greenNeeded else { return }
        
        let redInStock = diamonds.0
        let blueInStock = diamonds.1
        let greenInStock = diamonds.2
        let playerHasEnoghDiamonds = redInStock >= redNeeded && blueInStock >= blueNeeded && greenInStock >= greenNeeded

        if playerHasEnoghDiamonds
        {
            lockedSpinnerViewManager?.userCanUnlockSpinner()
        }
        else
        {
            lockedSpinnerViewManager?.userCantUnlockSpinner()
        }
    }
    
    func purchasedNewSpinner()
    {
        log.debug("")
        lockedSpinnerViewManager?.presentNode(shouldPresent: false)
        animateSpinnerLockFadeOut()
        removeSuccessV()
        showManuItems()
    }
    
//  MARK: Private methods
    private func hideArrows()
    {
        log.debug("")
        leftArrowTriger?.run(SKAction.scale(to: 0 , duration: 0.3))
        rightArrowTriger?.run(SKAction.scale(to: 0, duration: 0.3))
    }
    
    private func showArrows()
    {
        log.debug("")
        leftArrowTriger?.size = CGSize(width: 71, height: 55)
        rightArrowTriger?.size = CGSize(width: 71, height: 55)
        leftArrowTriger?.run(SKAction.scale(to: 1, duration: 0.7))
        rightArrowTriger?.run(SKAction.scale(to: 1, duration: 0.7))
    }
    
    private func hideManuItems()
    {
        log.debug("")
        startGame?.run(SKAction.scale(to: 0, duration: 0.0))
        settingsButton?.run(SKAction.scale(to: 0, duration: 0.3))
        muteSoundButton?.run(SKAction.scale(to: 0, duration: 0.3))
    }
    
    func showManuItems()
    {
        log.debug("")
        startGame?.run(SKAction.scale(to: 1, duration: 0.0))
        settingsButton?.run(SKAction.scale(to: 1, duration: 0.5))
        muteSoundButton?.run(SKAction.scale(to: 1, duration: 0.5))
    }
    
    private func showGameExplanation()
    {
        log.debug("")
        gameExplanation?.run(SKAction.sequence([SKAction.fadeIn(withDuration: 0.2),
                                                SKAction.wait(forDuration: 2),
                                                SKAction.fadeOut(withDuration: 0.2)]))
    }
    
    func animateSpinnerLockScaleUp()
    {
        log.debug("")
        let sequene = SKAction.sequence([SKAction.scale(to: 1.25, duration: 0.3),
                                         SKAction.fadeIn(withDuration: 0.1),
                                         SKAction.scale(to: 1.0, duration: 0.2)])
        self.spinnerLock?.run(sequene)
    }
    
    func animateSpinnerLockFadeOut()
    {
        log.debug("")
        self.spinnerLock?.run(SKAction.fadeOut(withDuration: 0.2))
    }
}

extension ManuManager
{
//  MARK: Progress Bar Logic
    func displayProgressBars(shouldShow bool: Bool,with diamonds: (Int,Int,Int)?)
    {
        log.debug("")
        if bool
        {
            decideBuyDiamondCashOrDiamonds(with: diamonds)
            
            startGame?.run(SKAction.scale(to: 0.0, duration: 0.2))
            progressBars?.run(SKAction.fadeIn(withDuration: 0.4))
        }
        else
        {
            startGame?.run(SKAction.scale(to: 1.0, duration: 0.2))
            progressBars?.run(SKAction.fadeOut(withDuration: 0.2))
        }
    }
    
    func removeProgressBars()
    {
        log.debug("")
        var progressBarNodes = [SKNode]()
        if let red = progressBars?.childNode(withName: Constants.ProgressBars.red.rawValue)
        {
            progressBarNodes.append(red)
        }
        if let blue = progressBars?.childNode(withName: Constants.ProgressBars.blue.rawValue)
        {
            progressBarNodes.append(blue)
        }
        if let green = progressBars?.childNode(withName: Constants.ProgressBars.green.rawValue)
        {
            progressBarNodes.append(green)
        }
        progressBars?.removeChildren(in: progressBarNodes)
    }
    
    func removeSuccessV()
    {
        log.debug("")
        animateSuccessV(toFadeIn: false, forNode: redSuccessV)
        animateSuccessV(toFadeIn: false, forNode: blueSuccessV)
        animateSuccessV(toFadeIn: false, forNode: greenSuccessV)
    }
    
    func saveProgressBarPosition()
    {
        log.debug("")
        if let red = progressBars?.childNode(withName: Constants.ProgressBars.red.rawValue)
        {
            redProgressBarPosition = red.position
        }
        if let blue = progressBars?.childNode(withName: Constants.ProgressBars.blue.rawValue)
        {
            blueProgressBarPosition = blue.position
        }
        if let green = progressBars?.childNode(withName: Constants.ProgressBars.green.rawValue)
        {
            greenProgressBarPosition = green.position
        }
    }
    
    func showProgressBarOrV(withValues values: (red:Int,blue:Int,green:Int)?)
    {
        log.debug("")
        removeProgressBars()
        guard let diamondsCount = values else { return }
        let spinner = ArchiveManager.currentSpinner
        
        if let redNeededDiamonds = spinner.redNeeded,
           let blueNeededDiamonds = spinner.blueNeeded,
           let greenNeededDiamonds = spinner.greenNeeded
        {
            handleRedProgressBar(withDiamondsPlayerHas: diamondsCount.red, diamondsPlayerNeed: redNeededDiamonds)
            handleBlueProgressBar(withDiamondsPlayerHas: diamondsCount.blue, diamondsPlayerNeed: blueNeededDiamonds)
            handleGreenProgressBar(withDiamondsPlayerHas: diamondsCount.green, diamondsPlayerNeed: greenNeededDiamonds)
        }
    }
    
    private func animateSuccessV(toFadeIn fadeIn: Bool,forNode node: SKSpriteNode?)
    {
        log.debug("")
        if fadeIn
        {
            node?.run(SKAction.fadeIn(withDuration: 0.3))
            {
                self.pulse(node: node, scaleUpTo: 1.3, scaleDownTo: 1.0, duration: 0.3)
            }
        }
        else
        {
            node?.run(SKAction.fadeOut(withDuration: 0.1))
        }
    }
    
    private func handleRedProgressBar(withDiamondsPlayerHas diamondsPlayerHas: Int,diamondsPlayerNeed: Int)
    {
        log.debug("")
        if diamondsPlayerHas >= diamondsPlayerNeed
        {
            animateSuccessV(toFadeIn: true, forNode: redSuccessV)
        }
        else
        {
            let redProgressBar = ProgressBar(newName: Constants.ProgressBars.red.rawValue,
                                             diamondsNeeded: diamondsPlayerNeed,
                                             diamondPossesed: diamondsPlayerHas)
            redProgressBar.name = Constants.ProgressBars.red.rawValue
            redProgressBar.position = redProgressBarPosition
            progressBars?.addChild(redProgressBar)
            redProgressBar.animateProgressBar()
        }
    }
    
    private func handleBlueProgressBar(withDiamondsPlayerHas diamondsPlayerHas: Int,diamondsPlayerNeed: Int)
    {
        log.debug("")
        if diamondsPlayerHas >= diamondsPlayerNeed
        {
            animateSuccessV(toFadeIn: true, forNode: blueSuccessV)
        }
        else
        {
            let blueProgressBar = ProgressBar(newName: Constants.ProgressBars.blue.rawValue,
                                              diamondsNeeded: diamondsPlayerNeed,
                                              diamondPossesed: diamondsPlayerHas)
            blueProgressBar.name = Constants.ProgressBars.blue.rawValue
            blueProgressBar.position = blueProgressBarPosition
            progressBars?.addChild(blueProgressBar)
            blueProgressBar.animateProgressBar()
        }
    }
    
    private func handleGreenProgressBar(withDiamondsPlayerHas diamondsPlayerHas: Int,diamondsPlayerNeed: Int)
    {
        log.debug("")
        if diamondsPlayerHas >= diamondsPlayerNeed
        {
            animateSuccessV(toFadeIn: true, forNode: greenSuccessV)
        }
        else
        {
            let greenProgressBar = ProgressBar(newName: Constants.ProgressBars.green.rawValue,
                                               diamondsNeeded: diamondsPlayerNeed,
                                               diamondPossesed: diamondsPlayerHas)
            greenProgressBar.name = Constants.ProgressBars.green.rawValue
            greenProgressBar.position = greenProgressBarPosition
            progressBars?.addChild(greenProgressBar)
            greenProgressBar.animateProgressBar()
        }
    }
}
