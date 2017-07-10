//
//  LockedSpinnerNode.swift
//  ProSpinner
//
//  Created by AlexP on 21.6.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit

class LockedSpinnerNode: SKNode,
                         Animateable,
                         ButtonProtocol
{
    private var lockedBackground            : SKSpriteNode?
    private var unlockSpinnerButtonShadow   : SKSpriteNode?
    private var unlockSpinnerButton         : SKSpriteButton?
    private var unlockSpinnerLabel          : SKLabelNode?
    private var topLabel                    : SKLabelNode?
    private var userCanUnlockSpinner = false
    
    fileprivate var redSuccessV      : SKSpriteNode?
    fileprivate var blueSuccessV     : SKSpriteNode?
    fileprivate var greenSuccessV    : SKSpriteNode?
    
    private var lockedBackgroundIsAtStartingPosition = true
    
    required init?(coder aDecoder: NSCoder)
    {
        log.debug()
        super.init(coder: aDecoder)
        connectOutletsToScene()
        prepareForDisplay()
    }
    
    func prepareForDisplay()
    {
        lockedBackground?.xScale = 0
        lockedBackground?.yScale = 0
        
        unlockSpinnerButtonShadow?.xScale = 0
        unlockSpinnerButtonShadow?.yScale = 0
        
        unlockSpinnerButton?.xScale = 0
        unlockSpinnerButton?.yScale = 0
        
        topLabel?.xScale = 0
        topLabel?.yScale = 0
        
        redSuccessV?.xScale = 0
        redSuccessV?.yScale = 0
        
        blueSuccessV?.xScale = 0
        blueSuccessV?.yScale = 0
        
        greenSuccessV?.xScale = 0
        greenSuccessV?.yScale = 0
    }
    
    func connectOutletsToScene()
    {
        log.debug()
        lockedBackground            = self.childNode(withName: Constants.NodesInLockedSpinnerView.LockedSpinnerBackground.rawValue) as? SKSpriteNode
        unlockSpinnerButtonShadow   = self.childNode(withName: Constants.NodesInLockedSpinnerView.UnlockSpinnerButtonShadow.rawValue) as? SKSpriteNode
        unlockSpinnerButton         = self.childNode(withName: Constants.NodesInLockedSpinnerView.UnlockSpinnerButton.rawValue) as? SKSpriteButton
        unlockSpinnerLabel          = unlockSpinnerButton?.childNode(withName: Constants.NodesInLockedSpinnerView.UnlockSpinnerButton.rawValue) as? SKLabelNode
        unlockSpinnerButton?.delegate = self
        unlockSpinnerButton?.moveBy = 4
        
        topLabel                    = self.childNode(withName: Constants.NodesInLockedSpinnerView.TopLabel.rawValue) as? SKLabelNode

        redSuccessV                 = self.childNode(withName: Constants.NodesInScene.RedSuccess.rawValue) as? SKSpriteNode
        greenSuccessV               = self.childNode(withName: Constants.NodesInScene.GreenSuccess.rawValue) as? SKSpriteNode
        blueSuccessV                = self.childNode(withName: Constants.NodesInScene.BlueSuccess.rawValue) as? SKSpriteNode
    }
    
    func presentNode(shouldPresent present: Bool)
    {
        log.debug()
        if present && lockedBackground?.xScale == 0
        {
            self.isHidden = false
            
            lockedBackground?.run(SKAction.fadeAlpha(to: 1, duration: 0.2))
            lockedBackground?.run(SKAction.scaleX(to: 1, duration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
            lockedBackground?.run(SKAction.scaleY(to: 1, duration: 0.4, delay: 0.3, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
            
            topLabel?.run(SKAction.scale(to: 1, duration: 0.4, delay: 0.4, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
            unlockSpinnerButton?.run(SKAction.scale(to: 1, duration: 0.4, delay: 0.4, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
            unlockSpinnerButtonShadow?.run(SKAction.scale(to: 1, duration: 0.4, delay: 0.4, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
            
            redSuccessV?.run(SKAction.scale(to: 1, duration: 0.4, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
            blueSuccessV?.run(SKAction.scale(to: 1, duration: 0.4, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
            greenSuccessV?.run(SKAction.scale(to: 1, duration: 0.4, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
            
        }
        else if present == false
        {
            topLabel?.run(SKAction.scale(to: 0, duration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
            unlockSpinnerButton?.run(SKAction.scale(to: 0, duration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
            unlockSpinnerButtonShadow?.run(SKAction.scale(to: 0, duration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
            
            lockedBackground?.run(SKAction.scaleY(to: 0, duration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
            lockedBackground?.run(SKAction.scaleX(to: 0, duration: 0.3, delay: 0.15, usingSpringWithDamping: 0.6, initialSpringVelocity: 1)) { self.isHidden = true }
            lockedBackground?.run(SKAction.fadeOut(withDuration: 0.4))
            
            redSuccessV?.run(SKAction.scale(to: 0, duration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
            blueSuccessV?.run(SKAction.scale(to: 0, duration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
            greenSuccessV?.run(SKAction.scale(to: 0, duration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
        }
    }

    func canUnlockSpinner()
    {
        unlockSpinnerLabel?.run(SKAction.fadeIn(withDuration: 0.3))
        unlockSpinnerButton?.colorBlendFactor = 0
    }
    
    func canNotUnlockSpinner()
    {
        unlockSpinnerLabel?.run(SKAction.fadeAlpha(to: 0.5, duration: 0.3))
        unlockSpinnerButton?.colorBlendFactor = 0.7
    }
    
    func rotate(successV node: SKNode?)
    {
        node?.removeAction(forKey: Constants.actionKeys.MoveSuccessV.rawValue)
        node?.run(SKAction.rotate(byAngle: (CGFloat.pi * 2), duration: 0.7, delay: 0.2 , usingSpringWithDamping: 0.8, initialSpringVelocity: 1), withKey: Constants.actionKeys.MoveSuccessV.rawValue)
    }
    
    func playerHasEnoughDiamondsOfKind(diamonds: (playerHasRed: Bool, playerHasBlue: Bool,playerHasGreen: Bool))
    {
        log.debug()
        if diamonds.playerHasRed
        {
            redSuccessV?.alpha = 1
            rotate(successV: redSuccessV)
            redSuccessV?.texture = SKTexture(imageNamed: "GreenV")
        }
        else
        {
            redSuccessV?.alpha = 0
        }
        
        if diamonds.playerHasBlue
        {
            blueSuccessV?.alpha = 1
            rotate(successV: blueSuccessV)
            blueSuccessV?.texture = SKTexture(imageNamed: "GreenV")
        }
        else
        {
            blueSuccessV?.alpha = 0
        }
        
        if diamonds.playerHasGreen
        {
            greenSuccessV?.alpha = 1
            rotate(successV: greenSuccessV)
            greenSuccessV?.texture = SKTexture(imageNamed: "GreenV")
        }
        else
        {
            greenSuccessV?.alpha = 0
        }
        
        let playerHasEnoghDiamonds = diamonds.playerHasRed && diamonds.playerHasBlue && diamonds.playerHasGreen
        
        if playerHasEnoghDiamonds
        {
            canUnlockSpinner()
            userCanUnlockSpinner = true
        }
        else
        {
            canNotUnlockSpinner()
            userCanUnlockSpinner = false
        }
    }
    
    func userRequestedToUnlockSpinner() -> Bool
    {
        if userCanUnlockSpinner
        {
            return true
        }
        else
        {
            shake(node: unlockSpinnerButtonShadow, withDuration: 0.07)
            shake(node: unlockSpinnerButton, withDuration: 0.07)
            return false
        }
    }
    
//  MARK: Button Protocol methods
    func buttonIsPressed()
    {
        
    }
    
    func buttonReleased()
    {
        
    }
}
