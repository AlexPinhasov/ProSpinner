//
//  ColorDiamondsManager.swift
//  ProSpinner
//
//  Created by AlexP on 20.5.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit
import GameplayKit

class DiamondsManager: BaseClass,
                       Animateable
{
//  MARK: Properties
    fileprivate var timer : Timer?
    
    fileprivate var originalDiamondNodeSize: CGSize = CGSize(width: 45, height: 35)
    
    fileprivate var redDiamondLocation: CGPoint!
    fileprivate var blueDiamondLocation: CGPoint!
    fileprivate var greenDiamondLocation: CGPoint!
    
    fileprivate var redDiamondLabelNodeOriginalLocation: CGPoint!
    fileprivate var blueDiamondLabelNodeOriginalLocation: CGPoint!
    fileprivate var greenDiamondLabelNodeOriginalLocation: CGPoint!
    
    fileprivate var redDiamondLabelNode: CustomSKLabelNode!
    fileprivate var blueDiamondLabelNode: CustomSKLabelNode!
    fileprivate var greenDiamondLabelNode: CustomSKLabelNode!
    fileprivate var diamondsCollectedDuringGame: DiamondsTuple = (0,0,0)
    
    fileprivate var redDiamondNode: SKSpriteNode!
    fileprivate var blueDiamondNode: SKSpriteNode!
    fileprivate var greenDiamondNode: SKSpriteNode!
    
    fileprivate var diamondsIsAtStartingPosition: Bool = true
    fileprivate var highScoreLabel: SKLabelNode?

    private var nextXLocation: CGFloat = 160.0
    private var wooshSound : SKAction

    fileprivate enum Count
    {
        case down
        case up
    }
    
    //  MARK: init
    init(inScene scene: SKScene)
    {
        wooshSound = SKAction.playSoundFileNamed("Tick.mp3", waitForCompletion: false)
        super.init()
        self.scene = scene
        highScoreLabel = self.scene?.childNode(withName: "HighScore") as? SKLabelNode
    }
    
//  MARK: Public Game methods
    func gameStarted()
    {
        log.debug("")
        fadeOutDiamondsAndTheirCount()
    }
    
    func tutorialStarted()
    {
        log.debug("")
        
    }
    
    func gameOver()
    {
        log.debug("")
        resetDiamondsTimer()
        if let diamondsInScene = scene?.children.filter({  if $0 is Diamond { return true } ; return false })
        {
            scene?.removeChildren(in: diamondsInScene)
        }
    }
    
    func configureDiamonds()
    {
        log.debug("")
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(spawnDiamonds), userInfo: nil, repeats: true)
    }

    @objc func spawnDiamonds()
    {
        log.debug("")
        guard let scene = scene else { return }
        let nextDiamond = randomizeDiamondType()
        
        switch GameStatus.Playing
        {
        case true:
            nextDiamond.position = CGPoint(x: nextXLocation, y: scene.frame.height)
            nextDiamond.zPosition = 5
            scene.addChild(nextDiamond)
            nextXLocation = calculateXLocation()
        
        case false: nextDiamond.removeAllActions()
        }
    }

    func resetDiamondsTimer()
    {
        log.debug("")
        Diamond.diamondSpeed = 4.0
        timer?.invalidate()
        fadeInDiamondAndTheirCount()
    }
    
    func getDiamondsCount() -> DiamondsTuple
    {
        log.debug("")
        return (red:Diamond.redCounter,
                blue:Diamond.blueCounter,
                green:Diamond.greenCounter)
    }
    
    func getCollectedDiamondsDuringGame() -> DiamondsTuple
    {
        log.debug("")
        return diamondsCollectedDuringGame
    }
    
    func loadDiamondCount()
    {
        log.debug("")
        loadRedDiamondCount()
        loadBlueDiamondCount()
        loadGreenDiamondCount()
        fadeInDiamondAndTheirCount()
    }
    
    func didSuccessInBuying(purchaseType :RegisteredPurchase)
    {
        var amountToAdd = 0
        switch purchaseType
        {
        case .SmallDiamondPack : amountToAdd = 100
        case .BigDiamondPack   : amountToAdd = 300
        }
        
        Diamond.redCounter += amountToAdd
        Diamond.blueCounter += amountToAdd
        Diamond.greenCounter += amountToAdd
        
        count(toDiraction: .up, for: amountToAdd, for: amountToAdd, for: amountToAdd)
    }

//  MARK: Physics mothods
    func contactBegan(for diamondNode: Diamond)
    {
        log.debug("")
        playTickSound()
        Diamond.diamondSpeed -= 0.010
        collectedDiamondOf(kind: diamondNode)
    }
    
    func playTickSound()
    {
        scene?.run(wooshSound)
    }
    
    func collectedDiamondOf(kind diamond: Diamond?)
    {
        log.debug("")
        guard let diamond = diamond else { return }
        
        switch diamond
        {
        case is redDiamond:
            diamondsCollectedDuringGame?.red += 1
            
        case is blueDiamond:
            diamondsCollectedDuringGame?.blue += 1
            
        case is greenDiamond:
            diamondsCollectedDuringGame?.green += 1
            
        default: break
        }
        updateHighScore()
    }
    
//  MARK: Diamonds Animation    
    func handleDiamondsWhenSpinner(isLocked spinnerIsLocked: Bool)
    {
        log.debug("")
        
        if spinnerIsLocked
        {
            positionDiamondsAtLockedLocation()
        }
        else
        {
            redDiamondLabelNode?.changeLabelColor(color: .black)
            blueDiamondLabelNode?.changeLabelColor(color: .black)
            greenDiamondLabelNode?.changeLabelColor(color: .black)
            returnDiamondsToStartingPosition()
        }
    }
    
    private func positionDiamondsAtLockedLocation()
    {
        log.debug()
        redDiamondNode?.run(SKAction.moveTo(y: 457 , duration: 0.2))
        blueDiamondNode?.run(SKAction.moveTo(y: 457, duration: 0.2))
        greenDiamondNode?.run(SKAction.moveTo(y: 457, duration:0.2))

    }
    
    func handleDiamondsPlayerNeedAndHaveLabels(isLocked spinnerIsLocked: Bool)
    {
        log.debug("")
        if spinnerIsLocked
        {
            positionDiamondLabelNodeAtLockedLocation()
            {
                    let spinner = ArchiveManager.currentSpinner
                    self.setTextForDiamondLabelNode(forNode: self.redDiamondLabelNode, diamondsPlayerNeed: spinner.redNeeded)
                    self.setTextForDiamondLabelNode(forNode: self.blueDiamondLabelNode, diamondsPlayerNeed: spinner.blueNeeded)
                    self.setTextForDiamondLabelNode(forNode: self.greenDiamondLabelNode, diamondsPlayerNeed: spinner.greenNeeded)
                
                    if self.shouldPulseNeededLabel()
                    {
                        self.redDiamondLabelNode?.pulseNeededDiamonds(withDuration: 0.3,delay: 0.3)
                        self.blueDiamondLabelNode?.pulseNeededDiamonds(withDuration: 0.3,delay: 0.3)
                        self.greenDiamondLabelNode?.pulseNeededDiamonds(withDuration: 0.3,delay: 0.3)
                    }
            }
        }
        else
        {
            redDiamondLabelNode?.hideSeparatorAndNeeded()
            blueDiamondLabelNode?.hideSeparatorAndNeeded()
            greenDiamondLabelNode?.hideSeparatorAndNeeded()
            
            returnDiamondsLabelNodeToStartingPosition()
        }
    }
    
    private func positionDiamondLabelNodeAtLockedLocation(completion block: @escaping () -> Void)
    {
        log.debug()
        redDiamondLabelNode?.run(SKAction.moveTo(y: 402 , duration: 0.2))
        blueDiamondLabelNode?.run(SKAction.moveTo(y: 402, duration: 0.2))
        greenDiamondLabelNode?.run(SKAction.moveTo(y: 402, duration:0.2))
        {
            block()
        }
    }
    
    private func changeDiamondsPlayerHaveLabelColor(toColor color: UIColor)
    {
        self.redDiamondLabelNode?.changeLabelColor(color: color)
        self.blueDiamondLabelNode?.changeLabelColor(color: color)
        self.greenDiamondLabelNode?.changeLabelColor(color: color)
    }
    
    private func setTextForDiamondLabelNode(forNode labelNode: CustomSKLabelNode?, diamondsPlayerNeed: Int?)
    {
        log.debug("")
        guard let diamondsPlayerNeed = diamondsPlayerNeed else { return }
        guard let labelNode = labelNode else { return }
        
        var originalPosition = CGPoint.zero
        
        switch labelNode
        {
        case redDiamondLabelNode:
            originalPosition = redDiamondLabelNodeOriginalLocation
            labelNode.diamondsPlayerHave.text? = String(Diamond.redCounter)
            
        case blueDiamondLabelNode:
            originalPosition = blueDiamondLabelNodeOriginalLocation
            labelNode.diamondsPlayerHave.text? = String(Diamond.blueCounter)
            
        case greenDiamondLabelNode:
            originalPosition = greenDiamondLabelNodeOriginalLocation
            labelNode.diamondsPlayerHave.text? = String(Diamond.greenCounter)
            
        default: break
        }
        
        labelNode.setText(diamondNeeded: diamondsPlayerNeed)
        labelNode.run(SKAction.moveTo(x: originalPosition.x - (labelNode.frameTotalWidth() / 2), duration: 0.3))
    }

    func fadeInAndScaleDiamondsCountLabels()
    {
        log.debug("")
        redDiamondLabelNode.position = redDiamondNode.position
        blueDiamondLabelNode.position = blueDiamondNode.position
        greenDiamondLabelNode.position = greenDiamondNode.position
        
        redDiamondLabelNode.run(SKAction.scale(to: 1.0, duration: 0.5))
        blueDiamondLabelNode.run(SKAction.scale(to: 1.0, duration: 0.5))
        greenDiamondLabelNode.run(SKAction.scale(to: 1.0, duration: 0.5))
        
        redDiamondLabelNode.run(SKAction.move(to: redDiamondLabelNodeOriginalLocation, duration: 0.3))
        blueDiamondLabelNode.run(SKAction.move(to: blueDiamondLabelNodeOriginalLocation, duration: 0.3))
        greenDiamondLabelNode.run(SKAction.move(to: greenDiamondLabelNodeOriginalLocation, duration: 0.3))
    }
    
    func returnDiamondsLabelNodeToStartingPosition()
    {
        redDiamondLabelNode?.run(SKAction.move(to: redDiamondLabelNodeOriginalLocation , duration: 0.4))
        blueDiamondLabelNode?.run(SKAction.move(to: blueDiamondLabelNodeOriginalLocation, duration: 0.4))
        greenDiamondLabelNode?.run(SKAction.move(to: greenDiamondLabelNodeOriginalLocation, duration:0.4))
    }
    
    func returnDiamondsToStartingPosition()
    {
        log.debug("")
        redDiamondNode.run(SKAction.move(to: redDiamondLocation, duration: 0.4))
        blueDiamondNode.run(SKAction.move(to: blueDiamondLocation, duration: 0.4))
        greenDiamondNode.run(SKAction.move(to: greenDiamondLocation, duration: 0.4))
        
    }
    
    func shouldPulseNeededLabel() -> Bool
    {
        log.debug("")
        let spinner = ArchiveManager.currentSpinner
        guard let redNeeded = spinner.redNeeded else { return  false}
        guard let blueNeeded = spinner.blueNeeded else { return  false}
        guard let greenNeeded = spinner.greenNeeded else { return  false}
        
        if let diamondsInStock = getDiamondsCount()
        {
            return diamondsInStock.red < redNeeded && diamondsInStock.blue < blueNeeded && diamondsInStock.green < greenNeeded

        }
        return false
    }
    
    func fadeOutDiamondsAndTheirCount()
    {
        log.debug("")
        // Sprite Nodes
        redDiamondNode.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
        blueDiamondNode.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
        greenDiamondNode.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
        
        // Label Nodes
        redDiamondLabelNode.run(SKAction.fadeAlpha(to: 0, duration: 0.4))
        blueDiamondLabelNode.run(SKAction.fadeAlpha(to: 0, duration: 0.4))
        greenDiamondLabelNode.run(SKAction.fadeAlpha(to: 0, duration: 0.4))
        
        highScoreLabel?.text = "0"
        highScoreLabel?.isHidden = false
        highScoreLabel?.run(SKAction.fadeAlpha(to: 0.7, duration: 0.5))
    }
    
    func fadeInDiamondAndTheirCount()
    {
        log.debug("")
        
        highScoreLabel?.run(SKAction.fadeAlpha(to: 0, duration: 0.25))
        highScoreLabel?.text = "0"
        highScoreLabel?.isHidden = true
        
        // Red Diamond
        redDiamondNode.size = originalDiamondNodeSize
        redDiamondNode.position = redDiamondLocation
        redDiamondNode.run(SKAction.fadeAlpha(to: 1.0, duration: 0.3))
        {
            self.redDiamondLabelNode.run(SKAction.fadeAlpha(to: 1.0, duration: 0.3))
        }
        
        // Blue Diamond
        blueDiamondNode.size = originalDiamondNodeSize
        blueDiamondNode.position = blueDiamondLocation
        blueDiamondNode.run(SKAction.fadeAlpha(to: 1.0, duration: 0.4))
        {
            self.blueDiamondLabelNode.run(SKAction.fadeAlpha(to: 1.0, duration: 0.3))
        }
        
        // Green Diamond
        greenDiamondNode.size = originalDiamondNodeSize
        greenDiamondNode.position = greenDiamondLocation
        greenDiamondNode.run(SKAction.fadeAlpha(to: 1.0, duration: 0.5))
        {
            self.greenDiamondLabelNode.run(SKAction.fadeAlpha(to: 1.0, duration: 0.3))
        }
    }
    
    func purchasedNewSpinner()
    {
        log.debug("")
        let spinner = ArchiveManager.currentSpinner
        guard let redNeeded = spinner.redNeeded else { return }
        guard let blueNeeded = spinner.blueNeeded else { return }
        guard let greenNeeded = spinner.greenNeeded else { return }
        
        resetNodesToNormalPlayState()
  
        count(toDiraction: .down,for: redNeeded,for: blueNeeded,for: greenNeeded)
    }
    
    private func resetNodesToNormalPlayState()
    {
        redDiamondLabelNode.hideSeparatorAndNeeded()
        blueDiamondLabelNode.hideSeparatorAndNeeded()
        greenDiamondLabelNode.hideSeparatorAndNeeded()
        
        changeDiamondsPlayerHaveLabelColor(toColor: .black)
        
        returnDiamondsToStartingPosition()
        returnDiamondsLabelNodeToStartingPosition()
    }
    
    func addCollectedDiamondsToLabelScene()
    {
        log.debug("")
        guard let diamondsCollectedDuringGame = diamondsCollectedDuringGame else { return }
        Diamond.redCounter += diamondsCollectedDuringGame.red
        Diamond.blueCounter += diamondsCollectedDuringGame.blue
        Diamond.greenCounter += diamondsCollectedDuringGame.green
        
        count(toDiraction: .up, for: diamondsCollectedDuringGame.red, for: diamondsCollectedDuringGame.blue, for: diamondsCollectedDuringGame.green)
    }
    
//  MARK: Private methods
    fileprivate func updateDiamondCount(withDiamond diamond: SKSpriteNode)
    {
        log.debug("")
        switch diamond.name ?? ""
        {
        case Constants.DiamondsName.red.rawValue   : redDiamondLabelNode.diamondsPlayerHave.text = String(Diamond.redCounter)
        case Constants.DiamondsName.blue.rawValue  : blueDiamondLabelNode.diamondsPlayerHave.text = String(Diamond.blueCounter)
        case Constants.DiamondsName.green.rawValue : greenDiamondLabelNode.diamondsPlayerHave.text = String(Diamond.greenCounter)
            
        default: break
        }
    }

    private func updateHighScore()
    {
        guard let highScoreLabel = highScoreLabel else { return }
        
        var highScore = Int(highScoreLabel.text ?? "0") ?? 0
        highScore += 1
        highScoreLabel.text = String(highScore)
    }
    
    private func randomizeDiamondType() -> Diamond
    {
        log.debug("")
        let random = arc4random_uniform(3)+1
        switch random
        {
        case Constants.DiamondIntColor.Blue.rawValue     : return blueDiamond()
        case Constants.DiamondIntColor.Red.rawValue      : return redDiamond()
        case Constants.DiamondIntColor.Green.rawValue    : return greenDiamond()
        default                             : break
        }
        return blueDiamond()
    }

    private func calculateXLocation() -> CGFloat
    {
        log.debug("")
        let leftLocation = Diamond.diamondsXPosition - 60
        return CGFloat(arc4random_uniform(120)+UInt32(leftLocation))
    }
}

extension DiamondsManager
{
    // MARK: Connect Outlets from scene
    fileprivate func loadRedDiamondCount()
    {
        log.debug("")
        if let spriteNode = self.scene?.childNode(withName: Constants.DiamondsName.red.rawValue) as? SKSpriteNode
        {
            redDiamondNode = spriteNode
            redDiamondLocation = redDiamondNode.position
        }
        
        if let labelNodePlaceHolder = self.scene?.childNode(withName: UserDefaultKeys.red.rawValue)
        {
            redDiamondLabelNodeOriginalLocation = labelNodePlaceHolder.position
            let customLabel = CustomSKLabelNode()
            customLabel.position = CGPoint(x: labelNodePlaceHolder.position.x , y: labelNodePlaceHolder.position.y)
            customLabel.name = UserDefaultKeys.red.rawValue
            scene?.removeChildren(in: [labelNodePlaceHolder])
            scene?.addChild(customLabel)
            redDiamondLabelNode = scene?.childNode(withName: UserDefaultKeys.red.rawValue) as? CustomSKLabelNode
            updateDiamondCount(withDiamond: redDiamondNode)
        }
    }
    
    fileprivate func loadBlueDiamondCount()
    {
        log.debug("")
        if let spriteNode = self.scene?.childNode(withName: Constants.DiamondsName.blue.rawValue) as? SKSpriteNode
        {
            blueDiamondNode = spriteNode
            blueDiamondLocation = blueDiamondNode.position
        }
        
        if let labelNodePlaceHolder = self.scene?.childNode(withName: UserDefaultKeys.blue.rawValue)
        {
            blueDiamondLabelNodeOriginalLocation = labelNodePlaceHolder.position
            let customLabel = CustomSKLabelNode()
            customLabel.position = CGPoint(x: labelNodePlaceHolder.position.x , y: labelNodePlaceHolder.position.y)
            customLabel.name = UserDefaultKeys.blue.rawValue
            scene?.removeChildren(in: [labelNodePlaceHolder])
            scene?.addChild(customLabel)
            blueDiamondLabelNode = scene?.childNode(withName: UserDefaultKeys.blue.rawValue) as? CustomSKLabelNode
            updateDiamondCount(withDiamond: blueDiamondNode)
        }
    }
    
    fileprivate func loadGreenDiamondCount()
    {
        log.debug("")
        if let spriteNode = self.scene?.childNode(withName: Constants.DiamondsName.green.rawValue) as? SKSpriteNode
        {
            greenDiamondNode = spriteNode
            greenDiamondLocation = greenDiamondNode.position
        }
        
        if let labelNodePlaceHolder = self.scene?.childNode(withName: UserDefaultKeys.green.rawValue)
        {
            greenDiamondLabelNodeOriginalLocation = labelNodePlaceHolder.position
            let customLabel = CustomSKLabelNode()
            customLabel.position = CGPoint(x: labelNodePlaceHolder.position.x , y: labelNodePlaceHolder.position.y)
            customLabel.name = UserDefaultKeys.green.rawValue
            scene?.removeChildren(in: [labelNodePlaceHolder])
            scene?.addChild(customLabel)
            greenDiamondLabelNode = scene?.childNode(withName: UserDefaultKeys.green.rawValue) as? CustomSKLabelNode
            updateDiamondCount(withDiamond: greenDiamondNode)
        }
    }
}

extension DiamondsManager
{
//  MARK: Count actions
    fileprivate func count(toDiraction diraction: Count,for redNeeded: Int,for blueNeeded: Int,for greenNeeded: Int)
    {
        log.debug("")
        var redCounterDecrement = SKAction()
        var blueCounterDecrement = SKAction()
        var greenCounterDecrement = SKAction()
        
        switch diraction
        {
        case .up:
            redCounterDecrement = SKAction.sequence([SKAction.wait(forDuration: 0.04),SKAction.run(redCountUpAction)])
            blueCounterDecrement = SKAction.sequence([SKAction.wait(forDuration: 0.04),SKAction.run(blueCountUpAction)])
            greenCounterDecrement = SKAction.sequence([SKAction.wait(forDuration: 0.04),SKAction.run(greenCountUpAction)])
            
        case .down:
            redCounterDecrement = SKAction.sequence([SKAction.wait(forDuration: 0.02),SKAction.run(redCountdownAction)])
            blueCounterDecrement = SKAction.sequence([SKAction.wait(forDuration: 0.02),SKAction.run(blueCountdownAction)])
            greenCounterDecrement = SKAction.sequence([SKAction.wait(forDuration: 0.02),SKAction.run(greenCountdownAction)])
        }

        redDiamondLabelNode?.run(SKAction.sequence([SKAction.wait(forDuration: 0.8),
                                                    SKAction.repeat(redCounterDecrement, count: redNeeded)]))
        
        blueDiamondLabelNode?.run(SKAction.sequence([SKAction.wait(forDuration: 0.8),
                                                     SKAction.repeat(blueCounterDecrement, count: blueNeeded)]))
        
        greenDiamondLabelNode?.run(SKAction.sequence([SKAction.wait(forDuration: 0.8),
                                                      SKAction.repeat(greenCounterDecrement, count: greenNeeded)]))
        {
            self.diamondsCollectedDuringGame = (0,0,0)
            if diraction == .down
            {
                Diamond.redCounter -= redNeeded
                Diamond.blueCounter -= blueNeeded
                Diamond.greenCounter -= greenNeeded
            }
        }
    }
    
    private func cutDiamondPlayerHave(label: SKLabelNode)
    {
        if var cleanDiamondHaveLabel = label.text?.replacingOccurrences(of: " ", with: "")
        {
            if let i = cleanDiamondHaveLabel.characters.index(of: "/")
            {
                let endIndex = cleanDiamondHaveLabel.characters.endIndex
                cleanDiamondHaveLabel.removeSubrange(i..<endIndex)
            }
        }
    }
    
    private func redCountdownAction()
    {
        log.debug("")
        if let possesText = redDiamondLabelNode!.diamondsPlayerHave.text,
            let possesInt = Int(possesText)
        {
            redDiamondLabelNode?.diamondsPlayerHave.text = String(possesInt - 1)
        }
    }
    
    private func blueCountdownAction()
    {
        log.debug("")
        if let possesText = blueDiamondLabelNode!.diamondsPlayerHave.text,
            let possesInt = Int(possesText)
        {
            blueDiamondLabelNode?.diamondsPlayerHave.text = String(possesInt - 1)
        }
    }
    
    private func greenCountdownAction()
    {
        log.debug("")
        if let possesText = greenDiamondLabelNode!.diamondsPlayerHave.text,
            let possesInt = Int(possesText)
        {
            greenDiamondLabelNode?.diamondsPlayerHave.text = String(possesInt - 1)
        }
    }
    
    private func redCountUpAction()
    {
        log.debug("")
        if let possesText = redDiamondLabelNode!.diamondsPlayerHave.text,
            let possesInt = Int(possesText)
        {
            redDiamondLabelNode?.diamondsPlayerHave.text = String(possesInt + 1)
        }
    }
    
    private func blueCountUpAction()
    {
        log.debug("")
        if let possesText = blueDiamondLabelNode!.diamondsPlayerHave.text,
            let possesInt = Int(possesText)
        {
            blueDiamondLabelNode?.diamondsPlayerHave.text = String(possesInt + 1)
        }
    }
    
    private func greenCountUpAction()
    {
        log.debug("")
        if let possesText = greenDiamondLabelNode!.diamondsPlayerHave.text,
            let possesInt = Int(possesText)
        {
            greenDiamondLabelNode?.diamondsPlayerHave.text = String(possesInt + 1)
        }
    }
}
