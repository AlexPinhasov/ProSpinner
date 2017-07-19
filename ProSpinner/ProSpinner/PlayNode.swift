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

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        connectOutletsFromScene()
    }
    
    func connectOutletsFromScene()
    {
        playLabel       = self.childNode(withName: Constants.NodesInPlayNode.PlayLabel.rawValue)  as? SKSpriteButton
        playShadow      = self.childNode(withName: Constants.NodesInPlayNode.PlayShadow.rawValue) as? SKSpriteNode

        playLabel?.moveBy = -3
        playLabel?.delegate = self
    }
    
    func showNode()
    {
        self.removeAllActions()
        self.isHidden = false
        self.run(SKAction.scale(to: 1, duration: 0.7, delay: 0.20, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
    }
    
    func hideNode()
    {
        self.removeAllActions()
        self.run(SKAction.scale(to: 0, duration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
        {
            self.isHidden = true
        }
    }

    func buttonIsPressed()
    {

    }
    
    func buttonReleased()
    {

    }
}
