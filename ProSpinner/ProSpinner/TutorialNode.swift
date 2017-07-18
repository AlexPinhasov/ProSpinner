//
//  TutorialNode.swift
//  ProSpinner
//
//  Created by AlexP on 18.7.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit

class TutorialNode: SKNode
{
    private weak var explainGameImage   : SKSpriteNode?
    
    weak var gotItButton                : SKSpriteButton?
    private weak var gotItButtonShadow  : SKSpriteNode?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        connectOutletsFromScene()
    }
    
    func connectOutletsFromScene()
    {
        explainGameImage = self.childNode(withName: Constants.NodeInExplainGameNode.ExplainGameImage.rawValue) as? SKSpriteNode
        gotItButton = self.childNode(withName: Constants.NodeInExplainGameNode.Gotit.rawValue) as? SKSpriteButton
        gotItButtonShadow = self.childNode(withName: Constants.NodeInExplainGameNode.GotitShadow.rawValue) as? SKSpriteNode
        
        gotItButton?.moveBy = -4
    }
    
    func showNode()
    {
        self.run(SKAction.fadeIn(withDuration: 0.4))
    }
    
    func hideNode(completion block: @escaping () -> Void)
    {
        self.run(SKAction.fadeOut(withDuration: 0.3))
        {
            self.removeFromScene()
            block()
        }
    }
    
    private func removeFromScene()
    {
        self.removeAllActions()
        self.removeAllChildren()
        self.removeFromParent()
    }
}
