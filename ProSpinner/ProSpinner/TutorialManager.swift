//
//  TutorialManager.swift
//  ProSpinner
//
//  Created by AlexP on 12.6.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit

class TutorialManager: BaseClass
{
    private static var blackScreen : SKSpriteNode?
    private static var removeExplanationSprite: String?
    
    static var tutorialIsInProgress: Bool
    {
        get
        {
            log.debug("")
            return UserDefaults.standard.bool(forKey: "tutorialIsInProgress")
        }
        set
        {
            log.debug("")
            UserDefaults.standard.set(newValue,forKey: "tutorialIsInProgress")
        }
    }
    
    init(withScene scene: SKScene?)
    {
        super.init()
        self.scene = scene
        TutorialManager.blackScreen = self.scene?.childNode(withName: "TutorialBlackScreen") as? SKSpriteNode
    }
    
    static func fadeOutScreen()
    {
        log.debug("")
        blackScreen?.run(SKAction.fadeOut(withDuration: 0.3))
    }
    
    static func fadeInScreen()
    {
        log.debug("")
        blackScreen?.run(SKAction.fadeIn(withDuration: 0.3))
    }
    
    static func changeZposition(to zPosition: CGFloat)
    {
        log.debug("")
        blackScreen?.zPosition = zPosition
    }
    
    static func present(explanationSprite sprite: SKSpriteNode)
    {
        log.debug("")
        removeExplanationSprite = sprite.name
        blackScreen?.addChild(sprite)
    }
    
    static func removeCurrentExplanationSprite()
    {
        log.debug("")
        guard let removeExplanationSprite = removeExplanationSprite else { blackScreen?.removeAllChildren() ; return }
        
        if let nodeToDelete = blackScreen?.childNode(withName: removeExplanationSprite) as? SKSpriteNode
        {
            blackScreen?.removeChildren(in: [nodeToDelete])
        }
    }
}
