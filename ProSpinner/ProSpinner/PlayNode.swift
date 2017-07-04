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
    var rightEar      : SKSpriteNode?
    var leftEar       : SKSpriteNode?
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        connectOutletsFromScene()
    }
    
    func connectOutletsFromScene()
    {
        playLabel       = self.childNode(withName: Constants.NodesInPlayNode.PlayLabel.rawValue)  as? SKSpriteButton
        playShadow      = self.childNode(withName: Constants.NodesInPlayNode.PlayShadow.rawValue) as? SKSpriteNode
        rightEar        = self.childNode(withName: Constants.NodesInPlayNode.RightEar.rawValue)   as? SKSpriteNode
        leftEar         = self.childNode(withName: Constants.NodesInPlayNode.LeftEar.rawValue)    as? SKSpriteNode
        
        playLabel?.moveBy = -3
        playLabel?.delegate = self
    }
    
    func showNode()
    {
        self.isHidden = false
        self.run(SKAction.scale(to: 1, duration: 0.7, delay: 0.20, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
        
    }
    
    func hideNode()
    {
        self.run(SKAction.scale(to: 0, duration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
        {
            self.isHidden = true
        }
    }
    
    func buttonIsPressed()
    {
        let moveRightEar_Right = SKAction.moveTo(x: 115, duration: 0.07)
        let rightEarAngle = SKAction.rotate(byAngle: 1, duration: 0.15)
        
        let moveLeftEar_Left = SKAction.moveTo(x: -115, duration: 0.07)
        let leftEarAngle = SKAction.rotate(byAngle: -1, duration: 0.15)
        
        rightEar?.run(moveRightEar_Right)
        rightEar?.run(rightEarAngle)
        
        leftEar?.run(moveLeftEar_Left)
        leftEar?.run(leftEarAngle)
    }
    
    func buttonReleased()
    {
        let moveRightEar_Left = SKAction.moveTo(x: 110, duration: 0.07)
        let rightEarAngle = SKAction.rotate(byAngle: -1, duration: 0.15)
        
        let moveLeftEar_Right = SKAction.moveTo(x: -110, duration: 0.07)
        let leftEarAngle = SKAction.rotate(byAngle: 1, duration: 0.15)
        
        leftEar?.run(moveLeftEar_Right)
        leftEar?.run(leftEarAngle)
        
        rightEar?.run(moveRightEar_Left)
        rightEar?.run(rightEarAngle)
    }
}
