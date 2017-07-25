//
//  SpeedBarNode.swift
//  ProSpinner
//
//  Created by AlexP on 25.7.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit

class SpeedBarNode: SKNode
{
    var currentSpeedLabel  : SKLabelNode?
    var speedProgressBar   : ProgressBar?
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        connectOutletsFromScene()
    }
    
    func connectOutletsFromScene()
    {
        currentSpeedLabel    = self.childNode(withName: Constants.NodesInSpeedbarNode.CurrentSpeed.rawValue)  as? SKLabelNode
        //speedProgressBar   = self.childNode(withName: Constants.NodesInSpeedbarNode.SpeedProgressBar.rawValue) as? SKSpriteNode
    }

    //  MARK: Speed Progress bar logic
    func showSpeedProgressBar(withInitialValue value: Int)
    {
        self.removeAllActions()
        self.isHidden = false
        speedProgressBar?.run(SKAction.fadeIn(withDuration: 0.7))
        currentSpeedLabel?.run(SKAction.scale(to: 1, duration: 0.4, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
        
        let progressBarShape = ProgressBarShape(progressBarName: Constants.ProgressBars.green.rawValue,
                                                alignment: .vertical,
                                                progressBarWidth: 15,
                                                progressBarHeight: 250,
                                                color: Constants.DiamondProgressBarColor.manuGreenBlue,
                                                anchorPointX: -7,
                                                anchorPointY: 125,
                                                cornerRadius: 7.5)
        
        speedProgressBar = ProgressBar(progressBarShape: progressBarShape,
                                       incramentValue: value,
                                       totalValue: 250)
        guard let speedProgressBar = speedProgressBar else { return }
        
        speedProgressBar.position = CGPoint(x: 285, y: 170)
        scene?.addChild(speedProgressBar)
        speedProgressBar.animateProgressBar()
    }
    
    func changeSpeedHeight(toValue value: Int)
    {
        speedProgressBar?.addActualProgressBarOverlay(with: value, and: 250)
    }
    
    func resetSpeedProgressBar()
    {
        removeSpeedProgressBar()
        showSpeedProgressBar(withInitialValue: 7)
    }
    
    func removeSpeedProgressBar()
    {
        self.removeAllActions()
        speedProgressBar?.run(SKAction.fadeOut(withDuration: 0.7))
        currentSpeedLabel?.run(SKAction.scale(to: 0, duration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
        {
            self.isHidden = true
            self.speedProgressBar?.removeFromParent()
            self.speedProgressBar = nil
        }

    }
    
    func updateSpeedProgressBar(withValue value: DiamondsTuple)
    {
        guard let value = value else { return }
        
        changeSpeedHeight(toValue: value.red + value.blue + value.green + 6)
    }
}
