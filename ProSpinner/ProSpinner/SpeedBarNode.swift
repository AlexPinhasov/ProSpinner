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
    var crownGlow          : SKSpriteNode?
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        connectOutletsFromScene()
    }
    
    func connectOutletsFromScene()
    {
        log.debug()
        currentSpeedLabel    = self.childNode(withName: Constants.NodesInSpeedbarNode.CurrentSpeed.rawValue)  as? SKLabelNode
        crownGlow            = self.childNode(withName: Constants.NodesInSpeedbarNode.crownGlow.rawValue)  as? SKSpriteNode
        crownGlow?.isHidden  = true
    }

    //  MARK: Speed Progress bar logic
    func showSpeedProgressBar()
    {
        log.debug()
        self.removeAllActions()
        self.isHidden = false
        self.currentSpeedLabel?.text = "x1"
        currentSpeedLabel?.run(SKAction.scale(to: 1, duration: 0.4, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
        
        speedProgressBar = SpriteProgressBar()
        speedProgressBar?.delegate = self
        guard let speedProgressBar = speedProgressBar else { return }
        
        speedProgressBar.position = CGPoint(x: 30, y: 300)
        speedProgressBar.xScale = 0.0
        self.addChild(speedProgressBar)
        speedProgressBar.run(SKAction.scaleX(to: 1.0, duration: 2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
    }

    func removeSpeedProgressBar()
    {
        log.debug()
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
        log.debug()
        speedProgressBar?.updateProgressBar()
    }
    
    func didUpdateProgressBar(inPosition: ProgressInProgressBar)
    {
        log.debug()
        switch inPosition
        {
        case ProgressInProgressBar.start         : currentSpeedLabel?.text = "x1"
        case ProgressInProgressBar.qurter        : currentSpeedLabel?.text = "x2"
        case ProgressInProgressBar.midPoint      : currentSpeedLabel?.text = "x3"
        case ProgressInProgressBar.topQurter     : currentSpeedLabel?.text = "x4"
        case ProgressInProgressBar.topKingQurter : currentSpeedLabel?.text = "x5"
        case ProgressInProgressBar.king          :
            currentSpeedLabel?.text = "King!"
            crownGlow?.isHidden = false
            speedProgressBar?.removeSpark()
            
            let rotateAction = SKAction.rotate(byAngle: (CGFloat.pi * 2), duration: 5)
            crownGlow?.run(SKAction.repeatForever(rotateAction))
        
        }
        pulse(node: currentSpeedLabel, scaleUpTo: 1.3, scaleDownTo: 1.0, duration: 0.7)
    }
}
