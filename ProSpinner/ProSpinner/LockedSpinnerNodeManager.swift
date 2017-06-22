//
//  LockedSpinnerNodeManager.swift
//  ProSpinner
//
//  Created by AlexP on 21.6.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit

class LockedSpinnerNodeManager: SKNode
{
    private var GrayBackground : SKSpriteNode?
    private var DarkBackground : SKSpriteNode?
    private var RedPrice : SKSpriteNode?
    private var BluePrice : SKSpriteNode?
    private var GreenPrice : SKSpriteNode?
    private var LockSprite : SKSpriteNode?
    
    override init()
    {
        super.init()
        connectOutletsToScene()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    private func connectOutletsToScene()
    {
        GrayBackground     = self.childNode(withName: Constants.NodesInLockedSpinnerView.GrayBackground.rawValue) as? SKSpriteNode
        DarkBackground     = self.childNode(withName: Constants.NodesInRetryView.EndGameAlert.rawValue) as? SKSpriteNode
        
        RedPrice           = self.childNode(withName: Constants.NodesInLockedSpinnerView.RedPrice.rawValue) as? SKSpriteNode
        GreenPrice         = self.childNode(withName: Constants.NodesInLockedSpinnerView.GreenPrice.rawValue) as? SKSpriteNode
        BluePrice          = self.childNode(withName: Constants.NodesInLockedSpinnerView.BluePrice.rawValue) as? SKSpriteNode
        
        LockSprite         = self.childNode(withName: Constants.NodesInLockedSpinnerView.LockSprite.rawValue) as? SKSpriteNode
    }
    
    func presentNode(shouldPresent present: Bool)
    {
        if present
        {
            self.run(SKAction.fadeIn(withDuration: 0.3))
        }
        else
        {
            self.run(SKAction.fadeOut(withDuration: 0.3))
        }
    }
}
