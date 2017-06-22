//
//  Diamond.swift
//  ProSpinner
//
//  Created by AlexP on 26.5.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit
import GameplayKit

struct Diamonds
{
    static let blue     = SKTexture(imageNamed: "BlueCleanDiamond")
    static let red      = SKTexture(imageNamed: "RedCleanDiamond")
    static let green    = SKTexture(imageNamed: "GreenCleanDiamond")
}

enum DiamondColor: UInt32
{
    case Blue   = 1
    case Red    = 2
    case Green  = 3
}

enum DiamondsName : String
{
    case red = "redDiamond"
    case blue = "blueDiamond"
    case green = "greenDiamond"
}

class Diamond: SKSpriteNode
{
    static var diamondSpeed = 4.0
    static var diamondsXPosition : CGFloat = 1.0
    
    init()
    {
        super.init(texture: nil, color: .clear, size: CGSize(width: 35, height: 27))
  
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
        self.physicsBody = SKPhysicsBody(rectangleOf: self.frame.size)
        self.physicsBody?.categoryBitMask = physicsCategory
        self.physicsBody?.contactTestBitMask = TouchEventFor
        self.physicsBody?.isDynamic = true
        self.zPosition = 1
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
        }
    }
}

class redDiamond: Diamond
{
    override init()
    {
        super.init()
        self.name = DiamondsName.red.rawValue
        self.texture = Diamonds.red
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
        self.name = DiamondsName.blue.rawValue
        self.texture = Diamonds.blue
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
        self.name = DiamondsName.green.rawValue
        self.texture = Diamonds.green
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
}
