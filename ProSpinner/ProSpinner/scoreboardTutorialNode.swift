//
//  scoreboardTutorialNode.swift
//  ProSpinner
//
//  Created by AlexP on 5.8.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit

class ScoreboardTutorialNode: SKNode,
                              Animateable
{
    var scoreboardAlertView    : SKSpriteNode?
    var scoreboardBackground   : SKSpriteNode?
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        connectOutletsFromScene()
    }
    
    func configureViewBeforePresentation()
    {
        self.isHidden = true
        scoreboardBackground?.alpha = 0.0
        scoreboardAlertView?.xScale = 0.0
        scoreboardAlertView?.yScale = 0.0
    }
    
    func connectOutletsFromScene()
    {
        scoreboardAlertView = self.childNode(withName: Constants.scoreboardTutorialNode.scoreboardAlertView.rawValue)  as? SKSpriteNode
        scoreboardBackground = self.childNode(withName: Constants.scoreboardTutorialNode.scoreboardBackground.rawValue)  as? SKSpriteNode
    }
    
    func showNode()
    {
        self.removeAllActions()
        self.isHidden = false
        scoreboardBackground?.run(SKAction.sequence([SKAction.wait(forDuration: 3),SKAction.fadeIn(withDuration: 0.2)]))
        {
            self.scoreboardAlertView?.run(SKAction.scale(to: 1, duration: 0.7, delay: 0.30, usingSpringWithDamping: 0.6, initialSpringVelocity:
                1))
        }
    }
    
    func hideNode(completion block: @escaping () -> Void)
    {
        self.removeAllActions()
        scoreboardBackground?.run(SKAction.fadeOut(withDuration: 0.2))
        scoreboardAlertView?.run(SKAction.scale(to: 0, duration: 0.7, delay: 0.10, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
        {
            self.removeFromParent()
            block()
        }
    }
}
