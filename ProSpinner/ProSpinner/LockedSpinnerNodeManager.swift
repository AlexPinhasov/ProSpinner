//
//  LockedSpinnerNodeManager.swift
//  ProSpinner
//
//  Created by AlexP on 21.6.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit

class LockedSpinnerNodeManager: SKNode,
                                Animateable
{
    private var lockedBackground : SKSpriteNode?
    private var unlockRedBack    : SKSpriteNode?
    
    private var redPriceLabel : SKLabelNode?
    private var bluePriceLabel : SKLabelNode?
    private var greenPriceLabel : SKLabelNode?
    
    private var viewInfoLabel : SKLabelNode?
    
    private var lockedBackgroundIsAtStartingPosition = true
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    func connectOutletsToScene()
    {
        lockedBackground    = self.childNode(withName: Constants.NodesInLockedSpinnerView.LockedSpinnerBackground.rawValue) as? SKSpriteNode
        unlockRedBack       = self.childNode(withName: Constants.NodesInLockedSpinnerView.unlockRedBack.rawValue) as? SKSpriteNode
        
        viewInfoLabel      = lockedBackground?.childNode(withName: Constants.NodesInLockedSpinnerView.ViewInfoLabel.rawValue) as? SKLabelNode
        redPriceLabel      = lockedBackground?.childNode(withName: Constants.NodesInLockedSpinnerView.RedPrice.rawValue) as? SKLabelNode
        greenPriceLabel    = lockedBackground?.childNode(withName: Constants.NodesInLockedSpinnerView.GreenPrice.rawValue) as? SKLabelNode
        bluePriceLabel     = lockedBackground?.childNode(withName: Constants.NodesInLockedSpinnerView.BluePrice.rawValue) as? SKLabelNode
    }
    
    func presentNode(shouldPresent present: Bool)
    {
        if present && lockedBackground?.xScale == 0
        {
            self.isHidden = false
            
            unlockRedBack?.run(SKAction.fadeIn(withDuration: 0.2))
            lockedBackground?.run(SKAction.fadeIn(withDuration: 0.2))
            
            unlockRedBack?.run(SKAction.scaleX(to: 1, duration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
            lockedBackground?.run(SKAction.scaleX(to: 1, duration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
            
            unlockRedBack?.run(SKAction.scaleY(to: 1, duration: 0.4, delay: 0.3, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
            lockedBackground?.run(SKAction.scaleY(to: 1, duration: 0.4, delay: 0.3, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
            
        }
        else if present == false
        {
            unlockRedBack?.run(SKAction.scaleY(to: 0, duration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
            lockedBackground?.run(SKAction.scaleY(to: 0, duration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
            
            unlockRedBack?.run(SKAction.scaleX(to: 0, duration: 0.4, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
            lockedBackground?.run(SKAction.scaleX(to: 0, duration: 0.4, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
            {
                self.isHidden = true
            }
            
            unlockRedBack?.run(SKAction.fadeOut(withDuration: 0))
            lockedBackground?.run(SKAction.fadeOut(withDuration: 0.7))
        }
    }
    
    func userCanUnlockSpinner()
    {
        if lockedBackgroundIsAtStartingPosition
        {
            viewInfoLabel?.run(SKAction.fadeOut(withDuration: 0.1))
            viewInfoLabel?.run(SKAction.move(by: CGVector(dx: 0, dy: 8), duration: 0.4))
            {
                self.viewInfoLabel?.fontSize = 22
                self.viewInfoLabel?.text = Constants.LockedScreenStrings.UnlockSpinner.rawValue
                self.viewInfoLabel?.run(SKAction.fadeIn(withDuration: 0.1))
                self.pulseUnlockSpinnerLabel()
            }
            lockedBackground?.run(SKAction.move(by: CGVector(dx: 0, dy: -20), duration: 0.3))
            {
                self.lockedBackgroundIsAtStartingPosition = false
            }
        }
    }
    
    func userCantUnlockSpinner()
    {
        if lockedBackgroundIsAtStartingPosition == false
        {
            viewInfoLabel?.run(SKAction.fadeOut(withDuration: 0.1))
            viewInfoLabel?.run(SKAction.move(by: CGVector(dx: 0, dy: -8), duration: 0.4))
            {
                self.viewInfoLabel?.removeAllActions()
                self.viewInfoLabel?.setScale(1.0)
                self.viewInfoLabel?.fontSize = 18
                self.viewInfoLabel?.text = Constants.LockedScreenStrings.DiamondsNeeded.rawValue
                self.viewInfoLabel?.run(SKAction.fadeIn(withDuration: 0.1))
            }
            lockedBackground?.run(SKAction.move(by: CGVector(dx: 0, dy: 20), duration: 0.3))
            {
                self.lockedBackgroundIsAtStartingPosition = true
            }
        }
    }
    
    func userRequestedToUnlockSpinner(andPressedNode touchedNode: SKNode) -> Bool
    {
        if let unlockNowLabel = touchedNode as? SKLabelNode
        {
            if unlockNowLabel.text == Constants.LockedScreenStrings.UnlockSpinner.rawValue
            {
                return true
            }
            else //shake view and
            {
                shake(node: lockedBackground, withDuration: 0.1)
                shake(node: unlockRedBack, withDuration: 0.1)
                return false
            }
        }
        return false
    }
    
    func pulseUnlockSpinnerLabel()
    {
        let pulseSequene = SKAction.sequence([SKAction.scale(to: 1.2, duration: 0.7),SKAction.scale(to: 1.0, duration: 0.7)])
        
        viewInfoLabel?.run(SKAction.repeatForever(pulseSequene))
    }
    
    func setDiamondsPlayerNeed()
    {
        let spinner = ArchiveManager.currentSpinner
        
        redPriceLabel?.text = spinner.redNeeded?.description
        bluePriceLabel?.text = spinner.blueNeeded?.description
        greenPriceLabel?.text = spinner.greenNeeded?.description
    }
}
