//
//  SideMenuScoreboardView.swift
//  ProSpinner
//
//  Created by AlexP on 3.8.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit

class SideMenuScoreboardView: SKNode,Animateable
{
    private var scoreboard : SKSpriteNode?
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        connectOutletsToScene()
        configureViewBeforePresentation()
    }
    
    private func connectOutletsToScene()
    {
        scoreboard = self.childNode(withName: Constants.NodesInSideMenu.scoreboard.rawValue) as? SKSpriteNode
    }
    
    func configureViewBeforePresentation()
    {
        self.isHidden = true
        self.position.x = 60
    }
    
    //  MARK: Presentation methods
    func showScoreboardView()
    {
        self.isHidden = false
        self.run(SKAction.moveTo(x: 0, duration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
    }
    
    func hideScoreboardView()
    {
        self.run(SKAction.moveTo(x: 60, duration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
        {
            self.isHidden = true
        }
    }
    
    func didTapScoreboard()
    {
        pulse(node: scoreboard, scaleUpTo: 1.2, scaleDownTo: 1.0, duration: 0.2)
        
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.presentScoreboard.rawValue), object: nil)
        
    }
}
