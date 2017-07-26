//
//  PlayNode.swift
//  ProSpinner
//
//  Created by AlexP on 30.6.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit

class PlayNode: SKNode,
                ButtonProtocol
{
    var playLabel     : SKSpriteButton?
    var playShadow    : SKSpriteNode?
    var kingHat       : SKSpriteNode?

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        connectOutletsFromScene()
    }
    
    func connectOutletsFromScene()
    {
        playLabel       = self.childNode(withName: Constants.NodesInPlayNode.PlayLabel.rawValue)  as? SKSpriteButton
        playShadow      = self.childNode(withName: Constants.NodesInPlayNode.PlayShadow.rawValue) as? SKSpriteNode
        kingHat         = playLabel?.childNode(withName: Constants.NodesInPlayNode.kingHat.rawValue) as? SKSpriteNode
        showKingHatIfNeeded()
        playLabel?.moveBy = -3
        playLabel?.delegate = self
    }
    
    func showNode()
    {
        self.removeAllActions()
        self.isHidden = false
        self.run(SKAction.scale(to: 1, duration: 0.7, delay: 0.20, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
        showKingHatIfNeeded()
    }
    
    func hideNode()
    {
        self.removeAllActions()
        self.run(SKAction.scale(to: 0, duration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
        {
            self.isHidden = true
        }
    }
    
    func showKingHatIfNeeded()
    {
        if UserDefaults.standard.bool(forKey: NotifictionKey.userUnlockedKingHat.rawValue) == true
        {
            kingHat?.isHidden = false
        }
    }
    
    func buttonIsPressed()
    {

    }
    
    func buttonReleased()
    {

    }
}
