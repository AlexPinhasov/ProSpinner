//
//  BaseClass.swift
//  ProSpinner
//
//  Created by AlexP on 29.5.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit

class BaseClass
{
    var scene: SKScene?
}

enum NotifictionKey: String
{
    case collectionViewSpinner = "collectionViewSpinner"
    case interstitalCount = "interstitalCount"
    case loadingFinish  = "loadingFinish"
    case checkForNewSpinners = "checkForNewSpinners"
}

extension SKSpriteNode
{
    func addGlow(radius: Float = 13)
    {
        let effectNode = SKEffectNode()
        effectNode.shouldRasterize = true
        addChild(effectNode)
        //let textureSprite = SKSpriteNode(texture: texture)
        let textureSprite = SKShapeNode(rect: CGRect(origin: CGPoint(x: -35, y: -35), size: CGSize(width: 70, height: 70)), cornerRadius: 35)
       // textureSprite.size = CGSize(width: 40, height: 62)
        textureSprite.fillColor = UIColor(red: 243/255, green: 255/255, blue: 206/255, alpha: 0.7)
        effectNode.addChild(textureSprite)
        effectNode.filter = CIFilter(name: "CIGaussianBlur", withInputParameters: ["inputRadius":radius])
    }
}
