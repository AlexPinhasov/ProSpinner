//
//  SpinnerManager.swift
//  ProSpinner
//
//  Created by AlexP on 20.5.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import Foundation
import SpriteKit
import SpriteKit_Spring

class SpinnerManager: BaseClass,
                      Animateable
{
    fileprivate var diraction : Diraction = .Right
    fileprivate var spinnerSpeed = 1.2
    fileprivate var spiningToStratingPosition = false
    fileprivate var rotateAction: SKAction?
    fileprivate var currentlySwitchingSpinner: Bool = false
    
    fileprivate let rotateRightAngle = (CGFloat.pi * 2)
    fileprivate let rotateLeftAngle = -(CGFloat.pi * 2)
    
    var spinnerNode : SKSpriteNode?
    

//  MARK: Private enums
    fileprivate enum Diraction
    {
        case Left
        case Right
    }
    
    private enum SpinnerEdgeColors: String
    {
        case green = "green"
        case red    = "red"
        case blue   = "blue"
    }
    
    private enum LocalStrings: String
    {
        case spinnerNode = "spinner"
    }
    
//  MARK: init
    init(inScene scene: SKScene)
    {
        super.init()
        self.scene = scene
        initNodesFromScene()
    }
    
    func initNodesFromScene()
    {
        
    }
    
//  MARK: Public methods
    func gameStarted()
    {
        log.debug("")
        _ = scaleDownSpinner()
    }
    
    func tutorialStarted()
    {
        log.debug("")
        _ = scaleDownSpinner()
        TutorialManager.changeZposition(to: 0)
        TutorialManager.fadeInScreen()
        //TutorialManager.present(sprite)
        //rotateSpinnerTutorial()
    }
    
    func gameOver()
    {
        log.debug("")
        resetSpinner()
    }
    
    func configureSpinner(withPlaceHolder spinner: SKSpriteNode) -> SKSpriteNode
    {
        log.debug("")
        guard let spinnerNode = self.scene?.childNode(withName: LocalStrings.spinnerNode.rawValue) as? SKSpriteNode  else { return SKSpriteNode() }

        configureSpinnerColorNodes(for: spinnerNode,andNew: spinner)
    
        let spinnersInMemory = ArchiveManager.spinnersArrayInDisk
        for (index,eachSpinner) in spinnersInMemory.enumerated() where eachSpinner.mainSpinner == true
        {
            if let textureExist = eachSpinner.texture
            {
                spinner.texture = textureExist
            }
            
            if index >= 0 && index < spinnersInMemory.count
            {
                ArchiveManager.currentlyAtIndex = index
            }
            break
        }
        
        spinner.position = spinnerNode.position
        scene?.removeChildren(in: [spinnerNode])
        spinner.size = CGSize(width: 450, height: 450)
        spinner.anchorPoint = CGPoint(x: 0.501, y: 0.499)
        spinner.zPosition = 1
        return spinner
    }

    func configureSpinnerColorNodes(for spinnerNode: SKSpriteNode,andNew spinner: SKSpriteNode)
    {
        log.debug("")
        for coloredCirculNode in spinnerNode.children
        {
            let coloredNode = applyPhysicsAndName(for: coloredCirculNode)
            spinner.addChild(coloredNode)
        }
    }
    
    func rotateToOtherDirection()
    {
        log.debug("")
        guard spiningToStratingPosition == false else { return }
        
        switch GameStatus.Playing
        {
        case true:
            spinnerNode?.removeAction(forKey: Constants.actionKeys.rotate.rawValue)

            switch diraction
            {
            case .Left:
                diraction = .Right
                rotateAction = SKAction.rotate(byAngle: rotateRightAngle, duration: spinnerSpeed)
                
            case .Right:
                diraction = .Left
                rotateAction = SKAction.rotate(byAngle: rotateLeftAngle, duration: spinnerSpeed)
            }
            let wooshSound = SKAction.playSoundFileNamed("Woosh.mp3", waitForCompletion: false)
            spinnerNode?.run(wooshSound)
            if rotateAction != nil
            {
                spinnerNode?.run(SKAction.repeatForever(rotateAction!),withKey: Constants.actionKeys.rotate.rawValue)
            }

            
        case false:
            spinnerNode?.removeAction(forKey: Constants.actionKeys.rotate.rawValue)
        }
        
    }
    func contactBegan()
    {
        log.debug("")
        spinnerSpeed -= 0.0010
        pulseSpinner()
    }

    private func pulseSpinner()
    {
        log.debug("")
        pulse(node: spinnerNode, scaleUpTo: 0.65, scaleDownTo: 0.6, duration: 0.20)
    }
    
    func scaleDownSpinner() -> SKAction
    {
        log.debug("")
        let scaleAction = SKAction.scale(to: 0.6, duration: 0.2)
        spinnerNode?.run(scaleAction)
        return scaleAction
    }
    
    func scaleUpSpinner() -> SKAction
    {
        log.debug("")
        let scaleAction = SKAction.scale(to: 1, duration: 0.2)
        spinnerNode?.run(scaleAction)
        return scaleAction
    }
    
    func resetSpinner()
    {
        log.debug("")
        spinnerSpeed = 1.2
        spiningToStratingPosition = true
        spinnerNode?.removeAllActions()
        let rotateAction = SKAction.rotate(toAngle: 0.0, duration: spinnerSpeed)
        spinnerNode?.run(rotateAction)
        {
            self.spiningToStratingPosition = false
            if let scene = self.scene as? GameScene
            {
                scene.finishedReseting()
                _ = self.scaleUpSpinner()
            }
        }
    }
    
    func purchasedNewSpinner()
    {
        log.debug("")
        ArchiveManager.currentSpinnerHasBeenUnlocked()
        spinnerNode?.removeAllActions()
        rotateToStartingPosition()
        grayOutSpinnerIfLocked()
    }
    

//  MARK: Private methods
    private func rotateToStartingPosition()
    {
        log.debug("")
        spinnerNode?.run(SKAction.rotate(toAngle: 0.0, duration: 0.1))
    }
    
    private func applyPhysicsAndName(for circulNode: SKNode) -> SKNode
    {
        log.debug("")
        guard let circulNode = circulNode as? SKShapeNode else { return SKNode()}
        
        if let name = circulNode.name
        {
            var physicsCategory : UInt32! = 1
            var TouchEventFor : UInt32! = 1
            var colorSelected = String()
            
            switch name
            {
            case SpinnerEdgeColors.green.rawValue:
                TouchEventFor = PhysicsCategory.greenDiamond
                physicsCategory   = PhysicsCategory.greenNode
                colorSelected   = SpinnerEdgeColors.green.rawValue
                
            case SpinnerEdgeColors.red.rawValue:
                TouchEventFor = PhysicsCategory.redDiamond
                physicsCategory   = PhysicsCategory.redNode
                colorSelected   = SpinnerEdgeColors.red.rawValue
                
            case SpinnerEdgeColors.blue.rawValue:
                TouchEventFor = PhysicsCategory.blueDiamond
                physicsCategory   = PhysicsCategory.blueNode
                colorSelected   = SpinnerEdgeColors.blue.rawValue
                
            default: break
            }
            
            circulNode.removeFromParent()
            circulNode.name = colorSelected
            circulNode.strokeColor = UIColor.clear
            
            circulNode.physicsBody = SKPhysicsBody(rectangleOf: circulNode.frame.size)
            circulNode.physicsBody?.categoryBitMask = physicsCategory
            circulNode.physicsBody?.affectedByGravity = false
            circulNode.physicsBody?.contactTestBitMask = TouchEventFor
            circulNode.physicsBody?.isDynamic = false
            
            return circulNode
        }
        return SKNode()
    }
}

extension SpinnerManager
{
//  MARK: Spinner Selection Controller
    func userTappedNextSpinner(withCompletion didFinish: @escaping () -> Void)
    {
        log.debug("")
        animateNextSpinnerMovement()
        {
            didFinish()
        }
    }
    
    func userTappedPreviousSpinner(withCompletion didFinish: @escaping () -> Void)
    {
        log.debug("")
        animatePriviousSpinnerMovement()
        {
            didFinish()
        }
    }
    
    private func animateNextSpinnerMovement(withCompletion spinnerChanged: @escaping () -> Void)
    {
        log.debug("")
        if currentlySwitchingSpinner == false
        {
            currentlySwitchingSpinner = true
            spinnerNode?.run(SKAction.rotate(byAngle: rotateLeftAngle,
                                             duration: 0.7,
                                             delay: 0,
                                             usingSpringWithDamping: 0.9,
                                             initialSpringVelocity: 0.5))
            {
                self.spinnerNode?.zRotation = 0.0
                self.currentlySwitchingSpinner = false
            }

            spinnerNode?.run(SKAction.scale(to: 0.5, duration: 0.3))
            {
                self.moveToNextSpinner()
                self.spinnerNode?.texture = ArchiveManager.spinnersArrayInDisk[ArchiveManager.currentlyAtIndex].texture
                spinnerChanged()
                self.spinnerNode?.run(SKAction.scale(to: 1, duration: 0.3))
                self.grayOutSpinnerIfLocked()
            }
        }
    }
    
    private func animatePriviousSpinnerMovement(withCompletion spinnerChanged: @escaping () -> Void)
    {
        log.debug("")
        if currentlySwitchingSpinner == false
        {
            currentlySwitchingSpinner = true
            spinnerNode?.run(SKAction.rotate(byAngle: rotateRightAngle,
                                             duration: 0.7,
                                             delay: 0,
                                             usingSpringWithDamping: 0.9,
                                             initialSpringVelocity: 0.5))
            {
                self.spinnerNode?.zRotation = 0.0
                self.currentlySwitchingSpinner = false
            }
            
            spinnerNode?.run(SKAction.scale(to: 0.5, duration: 0.3))
            {
                self.moveToPreviousSpinner()
                self.spinnerNode?.texture = ArchiveManager.spinnersArrayInDisk[ArchiveManager.currentlyAtIndex].texture
                spinnerChanged()
                self.spinnerNode?.run(SKAction.scale(to: 1, duration: 0.3))
                self.grayOutSpinnerIfLocked()
            }
        }
    }
    
    fileprivate func grayOutSpinnerIfLocked()
    {
        log.debug("")
        guard let spinnerAlpha = spinnerNode?.alpha else { return }
        
        if ArchiveManager.currentSpinner.unlocked == false
        {
            if Float(spinnerAlpha) == 1.0
            {
                self.spinnerNode?.run(SKAction.fadeAlpha(to: 0.4, duration: 0.2))
            }
        }
        else if Float(spinnerAlpha) == 0.4
        {
            self.spinnerNode?.run(SKAction.fadeAlpha(to: 1.0, duration: 0.2))
        }
    }
    
    func moveToNextSpinner()
    {
        log.debug("")
        if ArchiveManager.currentlyAtIndex + 1 > ArchiveManager.spinnersArrayInDisk.count - 1
        {
            ArchiveManager.currentlyAtIndex = 0
        }
        else
        {
            ArchiveManager.currentlyAtIndex += 1
        }
    }
    
    func moveToPreviousSpinner()
    {
        log.debug("")
        if ArchiveManager.currentlyAtIndex - 1 < 0
        {
            ArchiveManager.currentlyAtIndex = ArchiveManager.spinnersArrayInDisk.count - 1
        }
        else
        {
            ArchiveManager.currentlyAtIndex -= 1
        }
    }
    
    func shakeSpinnerLocked(shouldShake shake: Bool)
    {
        log.debug("")
        if shake
        {
            let rotateRightAction = SKAction.rotate(byAngle: -0.06, duration: 0.4)
            let rotateCenterAction = SKAction.rotate(toAngle: 0.0, duration: 0.2)
            let rotateLeftAction = SKAction.rotate(byAngle: 0.05, duration: 0.4)
        
            let rightSequence = SKAction.sequence([SKAction.wait(forDuration: 0.4),
                                              rotateRightAction,
                                              rotateCenterAction,
                                              rotateRightAction,
                                              SKAction.wait(forDuration: 0.2),
                                              rotateCenterAction,
                                              rotateLeftAction,
                                              rotateCenterAction])
            
            let leftSequence = rightSequence.reversed()
            spinnerNode?.run(SKAction.sequence([rightSequence,leftSequence,rightSequence]), withKey: "ShakeLockedSpinner")
        }
        else
        {
            spinnerNode?.removeAction(forKey: "ShakeLockedSpinner")
        }
    }
}

extension SpinnerManager
{
    func rotateSpinnerTutorial()
    {
        log.debug("")
        guard spiningToStratingPosition == false else { return }
        
        switch diraction
        {
        case .Left:
            diraction = .Right
            rotateAction = SKAction.rotate(byAngle: rotateRightAngle, duration: spinnerSpeed)
            
        case .Right:
            diraction = .Left
            rotateAction = SKAction.rotate(byAngle: rotateLeftAngle, duration: spinnerSpeed)
        }
        
        if rotateAction != nil
        {
            spinnerNode?.run(SKAction.repeatForever(rotateAction!),withKey: Constants.actionKeys.rotate.rawValue)
        }
   
    }
}
