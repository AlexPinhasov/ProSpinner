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
    var playNode                 : PlayNode?
    var storeNode                : StoreNode?
    var lockedSpinnerView        : LockedSpinnerNode?
    var demiSpinnerNode          : DemiSpinnerNode?
    var gameTutorialNode         : TutorialNode?
    var speedBarNode             : SpeedBarNode?
    
    private var leftArrow        : SKSpriteNode?
    private var rightArrow       : SKSpriteNode?
    
    fileprivate var gameExplanation  : SKNode?
    fileprivate var spinnerLock  : SKSpriteNode?
    
    var soundNode                : SKSpriteNode?
    fileprivate var highScoreRecord  : SKLabelNode?
    
    // Unlock Spinner Master Node
    internal var progressBars: SKNode?
    
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
        playNode                = scene?.childNode(withName: Constants.NodesInPlayNode.PlayNode.rawValue) as? PlayNode
        storeNode               = scene?.childNode(withName: Constants.NodesInStoreView.StoreNode.rawValue) as? StoreNode
        
        highScoreRecord         = scene?.childNode(withName: Constants.NodesInScene.HighScoreRecord.rawValue) as? SKLabelNode
        
        leftArrow               = scene?.childNode(withName: Constants.NodesInScene.LeftArrow.rawValue) as? SKSpriteNode
        rightArrow              = scene?.childNode(withName: Constants.NodesInScene.RightArrow.rawValue) as? SKSpriteNode

        demiSpinnerNode         = scene?.childNode(withName: Constants.NodesInScene.DemiSpinnerNode.rawValue) as? DemiSpinnerNode
        
        progressBars            = scene?.childNode(withName: Constants.NodesInScene.ProgressBars.rawValue)
        speedBarNode            = scene?.childNode(withName: Constants.NodesInSpeedbarNode.SpeedBarNode.rawValue) as? SpeedBarNode
        
        gameExplanation         = scene?.childNode(withName: Constants.NodesInScene.BreifTutorial.rawValue)
        
        lockedSpinnerView       = scene?.childNode(withName: Constants.NodesInLockedSpinnerView.LockedSpinnerNode.rawValue) as? LockedSpinnerNode
        
        spinnerLock             = scene?.childNode(withName: Constants.NodesInLockedSpinnerView.SpinnerLock.rawValue) as? SKSpriteNode
    }

//  MARK: Public methods
    func configureManu()
    {
        log.debug("")
        initSpriteFromScene()
        showArrows()
        saveProgressBarPosition()
        updateHighScore()
    }
    
//  MARK: Game life cycle
    func gameStarted()
    {
        log.debug("")
        hideArrows()
        hideManuItems()
        speedBarNode?.showSpeedProgressBar()
    }
    
    func tutorialStarted()
    {
        log.debug("")
        hideArrows()
        hideManuItems()
        showTutorial()
    }
    
    func gameOver()
    {
        log.debug("")
        showArrows()
        updateHighScore()
        speedBarNode?.removeSpeedProgressBar()
    }
    
    func contactBegan()
    {
        speedBarNode?.updateSpeedProgressBar()
    }
    
//  MARK: Spinner Locked/Unlocked master methods
    func handleSpinnerPresentedIsLocked(with diamondCount: DiamondsTuple)
    {
        log.debug("")
        hideDemiSpinnerNode()
        PresentLockedSpinnerView(shouldPresent: true)
        displayProgressBars(shouldShow: true,with: diamondCount)
        showProgressBarOrV(withValues: diamondCount)
        animateSpinnerLockScaleUp()
        pointDirectionArrowsMoveAction()
    }
    
    func handleSpinnerPresentedIsUnlocked()
    {
        log.debug("")
        hideDemiSpinnerNode()
        animateSpinnerLockFadeOut()
        displayProgressBars(shouldShow: false, with: nil)
        PresentLockedSpinnerView(shouldPresent: false)
        pointDirectionArrowsMoveAction()
    }

    func PresentLockedSpinnerView(shouldPresent present: Bool)
    {
        log.debug("")
        lockedSpinnerView?.presentNode(shouldPresent: present)
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
        
        let playerHasEnoughRed = redInStock >= redNeeded
        let playerHasEnoughBlue = blueInStock >= blueNeeded
        let playerHasEnoughGreen = greenInStock >= greenNeeded
        
        lockedSpinnerView?.playerHasEnoughDiamondsOfKind(diamonds: (playerHasEnoughRed,playerHasEnoughBlue,playerHasEnoughGreen))
    }
    
    func purchasedNewSpinner()
    {
        log.debug("")
        lockedSpinnerView?.presentNode(shouldPresent: false)
        animateSpinnerLockFadeOut()
        showManuItems()
    }
    
//  MARK: Private methods
    private func hideArrows()
    {
        log.debug("")
        leftArrow?.run(SKAction.scale(to: 0 , duration: 0.3))
        rightArrow?.run(SKAction.scale(to: 0, duration: 0.3))
    }
    
    private func showArrows()
    {
        log.debug("")
        leftArrow?.run(SKAction.scale(to: 1, duration: 0.7))
        rightArrow?.run(SKAction.scale(to: 1, duration: 0.7))
        {
            self.pointDirectionArrowsMoveAction()
        }
    }
    
    private func updateHighScore()
    {
        log.debug("")
        let highScorePrefix = "High Score: "
        let actualHighScore = String(ArchiveManager.highScoreRecord)
        
        self.highScoreRecord?.text = highScorePrefix + actualHighScore
    }
    
    private func pointDirectionArrowsMoveAction()
    {
        log.debug("")
        let moveRightArrow_Right = SKAction.moveTo(x: 282, duration: 0.2)
        let moveRightArrow_Left = SKAction.moveTo(x: 272, duration: 0.2)
        
        let moveLeftArrow_Left = SKAction.moveTo(x: 36, duration: 0.2)
        let moveLeftArrow_Right = SKAction.moveTo(x: 46, duration: 0.2)
        
        let rightArrowSequence = SKAction.sequence([moveRightArrow_Right,moveRightArrow_Left,moveRightArrow_Right,moveRightArrow_Left])
        let leftArrowSequence = SKAction.sequence([moveLeftArrow_Left,moveLeftArrow_Right,moveLeftArrow_Left,moveLeftArrow_Right])
        
        rightArrow?.run(rightArrowSequence)
        leftArrow?.run(leftArrowSequence)
        {
            NotificationCenter.default.post(name: NSNotification.Name(NotifictionKey.loadingFinish.rawValue), object: nil)
        }
    }
    
    func hideManuItems()
    {
        log.debug("")
        playNode?.hideNode()
        storeNode?.hideNode()
        soundNode?.run(SKAction.fadeOut(withDuration: 0.5))
        highScoreRecord?.run(SKAction.fadeOut(withDuration: 0.3))
    }
    
    func showManuItems()
    {
        log.debug("")
        if ArchiveManager.currentSpinner.id == ArchiveManager.comingMoreSpinnerId
        {
            hideManuItems()
            showDemiSpinnerNode()
        }
        else
        {
            hideDemiSpinnerNode()
            playNode?.showNode()
            storeNode?.showNode()
            soundNode?.run(SKAction.fadeIn(withDuration: 0.5))
            highScoreRecord?.run(SKAction.fadeIn(withDuration: 0.4))
        }
    }
    
    func showDemiSpinnerNode()
    {
        log.debug("")
        demiSpinnerNode?.removeAllActions()
        if demiSpinnerNode?.alpha == 0
        {
            demiSpinnerNode?.isHidden = false
            demiSpinnerNode?.run(SKAction.sequence([SKAction.wait(forDuration: 0.3)  ,SKAction.fadeIn(withDuration: 0.2)]))
        }
    }
    
    func hideDemiSpinnerNode()
    {
        log.debug("")
        demiSpinnerNode?.removeAllActions()
        demiSpinnerNode?.run(SKAction.fadeOut(withDuration: 0.1))
        {
            self.demiSpinnerNode?.isHidden = true
        }
    }
    
    func showGameExplanation(startSpining: @escaping () -> Void)
    {
        log.debug("")
        
        if gameExplanation?.position.y != 0
        {
            gameExplanation?.run(SKAction.fadeOut(withDuration: 0.2))
            {
                self.gameExplanation?.position.y = 0
                startSpining()
            }
        }
        else
        {
            let fadeIn = SKAction.fadeIn(withDuration: 0.3)
            let wait = SKAction.wait(forDuration: 1.4)
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            
            gameExplanation?.run(SKAction.sequence([ fadeIn,wait,fadeOut ]))
            {
                startSpining()
            }
        }
}

    func showTutorial()
    {
        log.debug("")
        ArchiveManager.gameExplantionDidShow = true
        gameExplanation?.position.y = 95
        gameTutorialNode = self.scene?.childNode(withName: Constants.NodeInExplainGameNode.TutorialNode.rawValue) as? TutorialNode
        gameExplanation?.run(SKAction.fadeIn(withDuration: 0.5))
        gameTutorialNode?.showNode()
    }
    
    func hideTutorial()
    {
        log.debug("")
        gameTutorialNode?.hideNode()
        {
            self.gameTutorialNode = nil
        }
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
            
            hideManuItems()
            progressBars?.run(SKAction.fadeIn(withDuration: 0.4))
        }
        else
        {
            showManuItems()
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
            
        }
        else
        {
            let redProgressBarShape = ProgressBarShape(progressBarName: Constants.ProgressBars.red.rawValue,
                                                       alignment: .horizontal,
                                                       progressBarWidth: 60,
                                                       progressBarHeight: 4,
                                                       color: Constants.DiamondProgressBarColor.redColor,
                                                       anchorPointX: -38,
                                                       anchorPointY: 2,
                                                       cornerRadius: 2)
            
            let redProgressBar = ProgressBar(progressBarShape: redProgressBarShape,
                                             incramentValue: diamondsPlayerHas,
                                             totalValue: diamondsPlayerNeed)
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
            
        }
        else
        {
            let blueProgressBarShape = ProgressBarShape(progressBarName: Constants.ProgressBars.blue.rawValue,
                                                       alignment: .horizontal,
                                                       progressBarWidth: 60,
                                                       progressBarHeight: 4,
                                                       color: Constants.DiamondProgressBarColor.blueColor,
                                                       anchorPointX: -38,
                                                       anchorPointY: 2,
                                                       cornerRadius: 2)
            
            let blueProgressBar = ProgressBar(progressBarShape: blueProgressBarShape,
                                              incramentValue: diamondsPlayerHas,
                                              totalValue: diamondsPlayerNeed)
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
            
        }
        else
        {
            let greenProgressBarShape = ProgressBarShape(progressBarName: Constants.ProgressBars.green.rawValue,
                                                       alignment: .horizontal,
                                                       progressBarWidth: 60,
                                                       progressBarHeight: 4,
                                                       color: Constants.DiamondProgressBarColor.greenColor,
                                                       anchorPointX: -38,
                                                       anchorPointY: 2,
                                                       cornerRadius: 2)
            
            let greenProgressBar = ProgressBar(progressBarShape: greenProgressBarShape,
                                               incramentValue: diamondsPlayerHas,
                                               totalValue: diamondsPlayerNeed)
            greenProgressBar.name = Constants.ProgressBars.green.rawValue
            greenProgressBar.position = greenProgressBarPosition
            progressBars?.addChild(greenProgressBar)
            greenProgressBar.animateProgressBar()
        }
    }
}
