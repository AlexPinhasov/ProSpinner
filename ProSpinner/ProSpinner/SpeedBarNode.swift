//
//  SpeedBarNode.swift
//  ProSpinner
//
//  Created by AlexP on 25.7.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit

class SpeedBarNode: SKNode,
                    ProgressBarProtocol,
                    Animateable
{
    var currentSpeedLabel  : SKLabelNode?
    var speedProgressBar   : SpriteProgressBar?
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        connectOutletsFromScene()
    }
    
    func connectOutletsFromScene()
    {
        currentSpeedLabel    = self.childNode(withName: Constants.NodesInSpeedbarNode.CurrentSpeed.rawValue)  as? SKLabelNode
    }

    //  MARK: Speed Progress bar logic
    func showSpeedProgressBar()
    {
        self.removeAllActions()
        self.isHidden = false
        self.currentSpeedLabel?.text = "x1"
        currentSpeedLabel?.run(SKAction.scale(to: 1, duration: 0.4, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
        
        speedProgressBar = SpriteProgressBar()
        speedProgressBar?.delegate = self
        guard let speedProgressBar = speedProgressBar else { return }
        
        speedProgressBar.position = CGPoint(x: 290, y: 300)
        speedProgressBar.xScale = 0.0
        self.addChild(speedProgressBar)
        speedProgressBar.run(SKAction.scaleX(to: 1.0, duration: 2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
    }

    func removeSpeedProgressBar()
    {
        self.removeAllActions()
        speedProgressBar?.run(SKAction.fadeOut(withDuration: 0.4))
        currentSpeedLabel?.run(SKAction.scale(to: 0, duration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
        {
            self.isHidden = true
            self.speedProgressBar?.removeFromParent()
            self.speedProgressBar = nil
        }
    }
    
    func updateSpeedProgressBar()
    {
        speedProgressBar?.addActualProgressBarOverlay()
        
    }
    
    func didUpdateProgressBar(inPosition: ProgressInProgressBar)
    {
        switch inPosition
        {
        case ProgressInProgressBar.start     : currentSpeedLabel?.text = "x1"
        case ProgressInProgressBar.qurter    : currentSpeedLabel?.text = "x2"
        case ProgressInProgressBar.midPoint  : currentSpeedLabel?.text = "x3"
        case ProgressInProgressBar.topQurter : currentSpeedLabel?.text = "x4"
        case ProgressInProgressBar.king      : currentSpeedLabel?.text = "x5"
        }
        pulse(node: currentSpeedLabel, scaleUpTo: 1.3, scaleDownTo: 1.0, duration: 0.7)
    }
}
