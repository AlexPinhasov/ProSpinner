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
    fileprivate var diamondsCollectedDuringGame: (red: Int, blue: Int, green: Int) = (0,0,0)
    
    fileprivate var redDiamondNode: SKSpriteNode!
    fileprivate var blueDiamondNode: SKSpriteNode!
    fileprivate var greenDiamondNode: SKSpriteNode!
    fileprivate var diamondsIsAtStartingPosition: Bool = true
    fileprivate var LabelsIsAtStartingPosition: Bool = true

    private var nextXLocation: CGFloat = 160.0
    
    fileprivate enum Count
    {
        case down
        case up
    }
    
    //  MARK: init
    init(inScene scene: SKScene)
    {
        super.init()
        self.scene = scene
    }
    
//  MARK: Public Game methods
    func gameStarted()
    {
        configureDiamonds()
    }
    
    func tutorialStarted()
    {
        
    }
    
    func gameOver()
    {
        resetDiamondsTimer()
        if let diamondsInScene = scene?.children.filter({  if $0 is Diamond { return true } ; return false })
        {
            scene?.removeChildren(in: diamondsInScene)
        }
    }
    
    func configureDiamonds()
    {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(spawnDiamonds), userInfo: nil, repeats: true)
        fadeOutDiamondsAndTheirCount()
    }

    @objc func spawnDiamonds()
    {
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
        Diamond.diamondSpeed = 4.0
        timer?.invalidate()
        fadeInDiamondAndTheirCount()
    }
    
    func getDiamondsCount() -> (red: Int, blue: Int, green: Int)
    {
        return (red:Diamond.redCounter,
                blue:Diamond.blueCounter,
                green:Diamond.greenCounter)
    }
    
    func getCollectedDiamondsDuringGame() -> (red: Int, blue: Int, green: Int)
    {
        return diamondsCollectedDuringGame
    }

//  MARK: Physics mothods
    func contactBegan(for diamondNode: Diamond)
    {
        playTickSound()
        Diamond.diamondSpeed -= 0.010
        collectedDiamondOf(kind: diamondNode)
    }
    
    func playTickSound()
    {
        let wooshSound = SKAction.playSoundFileNamed("Tick.mp3", waitForCompletion: false)
        scene?.run(wooshSound)
    }
    
    func collectedDiamondOf(kind diamond: Diamond?)
    {
        guard let diamond = diamond else { return }
        
        switch diamond
        {
        case is redDiamond:
            diamondsCollectedDuringGame.red += 1
            
        case is blueDiamond:
            diamondsCollectedDuringGame.blue += 1
            
        case is greenDiamond:
            diamondsCollectedDuringGame.green += 1
            
        default: break
        }
        //updateDiamondCount(withDiamond: diamond)
    }
    
    func loadDiamondCount()
    {
        loadRedDiamondCount()
        loadBlueDiamondCount()
        loadGreenDiamondCount()
        fadeInDiamondAndTheirCount()
    }
    
//  MARK: Diamonds Animation
    func handleDiamondsWhenSpinner(isLocked spinnerIsLocked: Bool)
    {
        returnDiamondsToStartingPosition()
        handleDiamondsNeededAndPossesLabels(whenSpinnerIsLocked :spinnerIsLocked)
        
        if spinnerIsLocked && diamondsIsAtStartingPosition
        {
            
            diamondsIsAtStartingPosition = false
            let redEndPoint     = CGPoint(x: redDiamondLocation.x , y: redDiamondLocation.y - 10)
            let blueEndPoint    = CGPoint(x: blueDiamondLocation.x , y: blueDiamondLocation.y - 10)
            let greenEndPoint   = CGPoint(x: greenDiamondLocation.x , y: greenDiamondLocation.y - 10)

            pulse(node: redDiamondNode, scaleUpTo: 1.2, scaleDownTo: 1.0, duration: 0.2)
            pulse(node: blueDiamondNode, scaleUpTo: 1.2, scaleDownTo: 1.0, duration: 0.3)
            pulse(node: greenDiamondNode, scaleUpTo: 1.2, scaleDownTo: 1.0, duration: 0.4)
            
            let bounceDiamond = shouldBounceDiamonds()
            let redSequenceCount = bounceDiamond?.red == true ? 3 : 0
            let blueSequenceCount = bounceDiamond?.blue == true ? 3 : 0
            let greenSequenceCount = bounceDiamond?.green == true ? 3 : 0
            
            
            let greenSequence = SKAction.sequence([SKAction.move(to: greenEndPoint, duration: 0.8),
                                                 SKAction.move(to: greenDiamondLocation, duration: 0.8)])
            
            greenDiamondNode.run(SKAction.repeat(greenSequence, count: greenSequenceCount))
            
            
            let redSequence = SKAction.sequence([SKAction.move(to: redEndPoint, duration: 0.8),
                                                   SKAction.move(to: redDiamondLocation, duration: 0.8)])
            
            redDiamondNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.2),
                                                 SKAction.repeat(redSequence, count: redSequenceCount)]))
            
            let blueSequence = SKAction.sequence([SKAction.move(to: blueEndPoint, duration: 0.8),
                                                   SKAction.move(to: blueDiamondLocation, duration: 0.8)])
            
            blueDiamondNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.3),
                                                   SKAction.repeat(blueSequence, count: blueSequenceCount)]))
            {
                self.diamondsIsAtStartingPosition = true
            }
            
//            redDiamondLabelNode.run(SKAction.scale(to: 0.0, duration: 0.1))
//            blueDiamondLabelNode.run(SKAction.scale(to: 0.0, duration: 0.1))
//            greenDiamondLabelNode.run(SKAction.scale(to: 0.0, duration: 0.1))
        }
        else
        {
            if diamondsIsAtStartingPosition
            {
                fadeInDiamondAndTheirCount()
            }
        }
    }
    
    func handleDiamondsNeededAndPossesLabels(whenSpinnerIsLocked isLocked: Bool)
    {
        let spinner = ArchiveManager.currentSpinner
        
        if isLocked
        {
            redDiamondLabelNode?.setText(diamondNeeded: spinner.redNeeded)
            blueDiamondLabelNode?.setText(diamondNeeded: spinner.blueNeeded)
            greenDiamondLabelNode?.setText(diamondNeeded: spinner.greenNeeded)
            
            redDiamondLabelNode?.pulseNeededDiamonds(withDuration: 0.3,delay: 0.3)
            blueDiamondLabelNode?.pulseNeededDiamonds(withDuration: 0.3,delay: 0.3)
            greenDiamondLabelNode?.pulseNeededDiamonds(withDuration: 0.3,delay: 0.3)
            
            if LabelsIsAtStartingPosition
            {
                blueDiamondLabelNode?.run(SKAction.move(to: CGPoint(x: blueDiamondLabelNode.position.x - 19, y: blueDiamondLabelNode.position.y), duration: 0.3))
                redDiamondLabelNode?.run(SKAction.move(to: CGPoint(x: redDiamondLabelNode.position.x - 19, y: redDiamondLabelNode.position.y), duration: 0.3))
                greenDiamondLabelNode?.run(SKAction.move(to: CGPoint(x: greenDiamondLabelNode.position.x - 19, y: greenDiamondLabelNode.position.y), duration: 0.3))
                LabelsIsAtStartingPosition = false
            }
        }
        else
        {
            redDiamondLabelNode?.hideSeparatorAndNeeded()
            blueDiamondLabelNode?.hideSeparatorAndNeeded()
            greenDiamondLabelNode?.hideSeparatorAndNeeded()
            
            if LabelsIsAtStartingPosition == false
            {
                redDiamondLabelNode?.run(SKAction.move(to: redDiamondLabelNodeOriginalLocation , duration: 0.3))
                blueDiamondLabelNode?.run(SKAction.move(to: blueDiamondLabelNodeOriginalLocation, duration: 0.3))
                greenDiamondLabelNode?.run(SKAction.move(to: greenDiamondLabelNodeOriginalLocation, duration:0.3))
                LabelsIsAtStartingPosition = true
            }
        }
        
    }
    
    func fadeInAndScaleDiamondsCountLabels()
    {
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
    
    func returnDiamondsToStartingPosition()
    {
        redDiamondNode.removeAllActions()
        blueDiamondNode.removeAllActions()
        greenDiamondNode.removeAllActions()
        redDiamondNode.run(SKAction.move(to: redDiamondLocation, duration: 0.4))
        {
            self.diamondsIsAtStartingPosition = true
        }
        blueDiamondNode.run(SKAction.move(to: blueDiamondLocation, duration: 0.4))
        greenDiamondNode.run(SKAction.move(to: greenDiamondLocation, duration: 0.4))
        
    }
    
    func shouldBounceDiamonds() -> (red: Bool, blue: Bool, green: Bool)?
    {
        let spinner = ArchiveManager.currentSpinner
        guard let redNeeded = spinner.redNeeded else { return  nil}
        guard let blueNeeded = spinner.blueNeeded else { return  nil}
        guard let greenNeeded = spinner.greenNeeded else { return  nil}
        
        let diamondsInStock = getDiamondsCount()
        
        var enoughRedDiamonds = (red: false,blue: false,green: false)
        
        if diamondsInStock.red < redNeeded
        {
            enoughRedDiamonds.red = true
        }
        if diamondsInStock.blue < blueNeeded
        {
            enoughRedDiamonds.blue = true
        }
        if diamondsInStock.green < greenNeeded
        {
            enoughRedDiamonds.green = true
        }
        
        return enoughRedDiamonds
    }
    
    func fadeOutDiamondsAndTheirCount()
    {
        // Sprite Nodes
        redDiamondNode.run(SKAction.fadeAlpha(to: 0.3, duration: 0.3))
        blueDiamondNode.run(SKAction.fadeAlpha(to: 0.3, duration: 0.3))
        greenDiamondNode.run(SKAction.fadeAlpha(to: 0.3, duration: 0.3))
        
        // Label Nodes
        redDiamondLabelNode.run(SKAction.fadeAlpha(to: 0.4, duration: 0.4))
        blueDiamondLabelNode.run(SKAction.fadeAlpha(to: 0.4, duration: 0.4))
        greenDiamondLabelNode.run(SKAction.fadeAlpha(to: 0.4, duration: 0.4))
    }
    
    func fadeInDiamondAndTheirCount()
    {
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
        let spinner = ArchiveManager.currentSpinner
        guard let redNeeded = spinner.redNeeded else { return }
        guard let blueNeeded = spinner.blueNeeded else { return }
        guard let greenNeeded = spinner.greenNeeded else { return }
  
        count(toDiraction: .down,for: redNeeded,for: blueNeeded,for: greenNeeded)
        // When Finished should update values in disk
    }
    
    func addCollectedDiamondsToLabelScene()
    {
        Diamond.redCounter += diamondsCollectedDuringGame.red
        Diamond.blueCounter += diamondsCollectedDuringGame.blue
        Diamond.greenCounter += diamondsCollectedDuringGame.green
        
        count(toDiraction: .up, for: diamondsCollectedDuringGame.red, for: diamondsCollectedDuringGame.blue, for: diamondsCollectedDuringGame.green)
    }
    
//  MARK: Private methods
    fileprivate func updateDiamondCount(withDiamond diamond: SKSpriteNode)
    {
        switch diamond.name ?? ""
        {
        case DiamondsName.red.rawValue   : redDiamondLabelNode.diamondsPlayerHave.text = String(Diamond.redCounter)
        case DiamondsName.blue.rawValue  : blueDiamondLabelNode.diamondsPlayerHave.text = String(Diamond.blueCounter)
        case DiamondsName.green.rawValue : greenDiamondLabelNode.diamondsPlayerHave.text = String(Diamond.greenCounter)
            
        default: break
        }
    }

    private func randomizeDiamondType() -> Diamond
    {
        let random = arc4random_uniform(3)+1
        switch random
        {
        case DiamondColor.Blue.rawValue     : return blueDiamond()
        case DiamondColor.Red.rawValue      : return redDiamond()
        case DiamondColor.Green.rawValue    : return greenDiamond()
        default                             : break
        }
        return blueDiamond()
    }

    private func calculateXLocation() -> CGFloat
    {
        let leftLocation = Diamond.diamondsXPosition - 60
        return CGFloat(arc4random_uniform(120)+UInt32(leftLocation))
    }
    
}

extension DiamondsManager
{
    // MARK: Connect Outlets from scene
    fileprivate func loadRedDiamondCount()
    {
        if let spriteNode = self.scene?.childNode(withName: DiamondsName.red.rawValue) as? SKSpriteNode
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
        if let spriteNode = self.scene?.childNode(withName: DiamondsName.blue.rawValue) as? SKSpriteNode
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
        if let spriteNode = self.scene?.childNode(withName: DiamondsName.green.rawValue) as? SKSpriteNode
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
        }
    }
    
    private func redCountdownAction()
    {
        if let possesText = redDiamondLabelNode!.diamondsPlayerHave.text,
            let possesInt = Int(possesText)
        {
            redDiamondLabelNode?.diamondsPlayerHave.text = String(possesInt - 1)
        }
    }
    
    private func blueCountdownAction()
    {
        if let possesText = blueDiamondLabelNode!.diamondsPlayerHave.text,
            let possesInt = Int(possesText)
        {
            blueDiamondLabelNode?.diamondsPlayerHave.text = String(possesInt - 1)
        }
    }
    
    private func greenCountdownAction()
    {
        if let possesText = greenDiamondLabelNode!.diamondsPlayerHave.text,
            let possesInt = Int(possesText)
        {
            greenDiamondLabelNode?.diamondsPlayerHave.text = String(possesInt - 1)
        }
    }
    
    private func redCountUpAction()
    {
        if let possesText = redDiamondLabelNode!.diamondsPlayerHave.text,
            let possesInt = Int(possesText)
        {
            redDiamondLabelNode?.diamondsPlayerHave.text = String(possesInt + 1)
        }
    }
    
    private func blueCountUpAction()
    {
        if let possesText = blueDiamondLabelNode!.diamondsPlayerHave.text,
            let possesInt = Int(possesText)
        {
            blueDiamondLabelNode?.diamondsPlayerHave.text = String(possesInt + 1)
        }
    }
    
    private func greenCountUpAction()
    {
        if let possesText = greenDiamondLabelNode!.diamondsPlayerHave.text,
            let possesInt = Int(possesText)
        {
            greenDiamondLabelNode?.diamondsPlayerHave.text = String(possesInt + 1)
        }
    }
}
