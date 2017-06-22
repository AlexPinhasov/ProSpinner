//
//  LoadingScene.swift
//  ProSpinner
//
//  Created by AlexP on 5.6.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit

class LoadingScene: SKScene
{
    private var topMetal: SKSpriteNode?
    private var rightMetal: SKSpriteNode?
    private var leftMetal: SKSpriteNode?
    
    private var topOriginalPosition = CGPoint()
    private var rightOriginalPosition = CGPoint()
    private var leftOriginalPosition = CGPoint()
    
    override func didMove(to view: SKView)
    {
        topMetal = self.childNode(withName: "topMetal") as? SKSpriteNode
        rightMetal = self.childNode(withName: "rightMetal") as? SKSpriteNode
        leftMetal = self.childNode(withName: "leftMetal") as? SKSpriteNode
        
//        topOriginalPosition = topMetal.position
//        rightOriginalPosition = rightMetal.position
//        leftOriginalPosition = leftMetal.position
//        
        animateDown()
    }
    
    func animateDown()
    {
        let spinnerArray = ArchiveManager.read_SpinnersFromUserDefault()
        
        var textures = spinnerArray.map({ (spinner) -> SKTexture in
            
            if let texture = spinner.texture
            {
                return texture
            }
            return SKTexture()
        })
        
        topMetal?.run(SKAction.sequence([  SKAction.wait(forDuration: 1),
                                          SKAction.move(to: CGPoint(x: 71, y: -120), duration: 1.3),]))
        
        leftMetal?.run(SKAction.sequence([  SKAction.wait(forDuration: 1),
                                           SKAction.move(to: CGPoint(x: -73, y: -264), duration: 1.9)]))
        
        rightMetal?.run(SKAction.sequence([  SKAction.wait(forDuration: 1),
                                            SKAction.move(to: CGPoint(x: -0.7, y: -193), duration: 1.8),
                                            SKAction.wait(forDuration: 1)]))
        {
            textures.append(Diamonds.red)
            textures.append(Diamonds.blue)
            textures.append(Diamonds.green)
            SKTexture.preload(textures)
            {
                DispatchQueue.main.async
                {
                    if let nextScene = SKScene(fileNamed: "GameScene")
                    {
                        nextScene.scaleMode = .aspectFill
                        NotificationCenter.default.post(name: NSNotification.Name(NotifictionKey.loadingFinish.rawValue), object: nil)
                        self.scene?.view?.presentScene(nextScene, transition: SKTransition.fade(withDuration: 1.2))
                    }
                }
            }
        }
    }
    
    func animateUp()
    {
        topMetal?.run(SKAction.move(to: calculateXLocation(for: topOriginalPosition), duration: 1))
        rightMetal?.run(SKAction.move(to: calculateXLocation(for: rightOriginalPosition), duration: 0.6))
        leftMetal?.run(SKAction.sequence([  SKAction.move(to: calculateXLocation(for: leftOriginalPosition), duration: 1.4),
                                           SKAction.wait(forDuration: 0.5)]))
        {
            self.animateDown()
        }
    }
    
    private func calculateXLocation(for point: CGPoint) -> CGPoint
    {
        let location = abs(point.y - 60.0)
        return CGPoint(x: point.x  ,y: CGFloat(arc4random_uniform(120)+UInt32(location)))
    }
    
}
