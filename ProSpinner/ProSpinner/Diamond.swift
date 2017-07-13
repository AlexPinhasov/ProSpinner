//
//  Diamond.swift
//  ProSpinner
//
//  Created by AlexP on 26.5.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit
import GameplayKit

class Diamond: SKSpriteNode
{
    static var diamondSpeed = 5.0
    static var diamondsXPosition : CGFloat = 1.0
    
    init()
    {
        log.debug()
        super.init(texture: nil, color: .clear, size: CGSize(width: 35, height: 27))
  
        let circuleMask = SKShapeNode(circleOfRadius: 17)
        circuleMask.strokeColor = .clear
        circuleMask.zPosition = 5

        var physicsCategory : UInt32! = 1
        var TouchEventFor : UInt32! = 1

        switch self
        {
        case is greenDiamond:
            physicsCategory = PhysicsCategory.greenDiamond
            TouchEventFor = PhysicsCategory.greenNode
            self.colorBlendFactor = 0.10
            self.color = .black
            self.blendMode = .alpha
            
        case is redDiamond:
            physicsCategory = PhysicsCategory.redDiamond
            TouchEventFor = PhysicsCategory.redNode
            
        case is blueDiamond:
            physicsCategory = PhysicsCategory.blueDiamond
            TouchEventFor = PhysicsCategory.blueNode
            
        default: break
        }
        
        // Actions
        let fallAction : SKAction = SKAction.moveTo(y: -1, duration: Diamond.diamondSpeed)
        let rotate     : SKAction = SKAction.rotate(byAngle: 30, duration: 13)
        self.run(SKAction.repeatForever(fallAction))
        self.run(SKAction.repeatForever(rotate))
        
        // Physics Body
        circuleMask.physicsBody = SKPhysicsBody(circleOfRadius: 15)
        circuleMask.physicsBody?.categoryBitMask = physicsCategory
        circuleMask.physicsBody?.contactTestBitMask = TouchEventFor
        circuleMask.physicsBody?.isDynamic = true

        self.zPosition = 5
        self.addChild(circuleMask)

    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
}

extension Diamond
{
    static var greenCounter : Int
    {
        get
        {
            return UserDefaults.standard.integer(forKey: UserDefaultKeys.green.rawValue)
        }
        set
        {
            UserDefaults.standard.set(newValue, forKey: UserDefaultKeys.green.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    
    static var redCounter : Int
    {
        get
        {
            return UserDefaults.standard.integer(forKey: UserDefaultKeys.red.rawValue)
        }
        set
        {
            UserDefaults.standard.set(newValue, forKey: UserDefaultKeys.red.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    
    static var blueCounter : Int
    {
        get
        {
            return UserDefaults.standard.integer(forKey: UserDefaultKeys.blue.rawValue)
        }
        set
        {
            UserDefaults.standard.set(newValue, forKey: UserDefaultKeys.blue.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
}

class redDiamond: Diamond
{
    override init()
    {
        super.init()
        self.name = Constants.DiamondsName.red.rawValue
        self.texture = Constants.DiamondsCleanTexture.red
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
}

class blueDiamond: Diamond
{
    override init()
    {
        super.init()
        self.name = Constants.DiamondsName.blue.rawValue
        self.texture = Constants.DiamondsCleanTexture.blue
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
}
class greenDiamond: Diamond
{
    override init()
    {
        super.init()
        self.name = Constants.DiamondsName.green.rawValue
        self.texture = Constants.DiamondsCleanTexture.green
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
}
