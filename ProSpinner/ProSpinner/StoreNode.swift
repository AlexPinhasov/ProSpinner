//
//  StoreNode.swift
//  ProSpinner
//
//  Created by AlexP on 1.7.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit

class StoreNode : SKNode,
                  ButtonProtocol
{
    var storeButton        : SKSpriteButton?
    var storeButtonShadow  : SKSpriteNode?
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        connectOutletsFromScene()
    }
    
    func connectOutletsFromScene()
    {
        storeButton        = self.childNode(withName: Constants.NodesInStoreView.StoreButton.rawValue)  as? SKSpriteButton
        storeButtonShadow  = self.childNode(withName: Constants.NodesInStoreView.StoreButtonShadow.rawValue) as? SKSpriteNode
        
        storeButton?.moveBy = -3
        storeButton?.delegate = self
    }
    
    func showNode()
    {
        self.removeAllActions()
        self.isHidden = false
        self.run(SKAction.scale(to: 1, duration: 0.7, delay: 0.30, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
    }
    
    func hideNode()
    {
        self.removeAllActions()
        self.run(SKAction.scale(to: 0, duration: 0.7, delay: 0.10, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
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
