//
//  CustomSKLabelNode.swift
//  ProSpinner
//
//  Created by AlexP on 9.6.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit

class CustomSKLabelNode : SKNode,
                          Animateable
{
    var diamondsPlayerHave  : SKLabelNode = SKLabelNode()
    var separatorLabel      : SKLabelNode = SKLabelNode()
    var diamondsPlayerNeed  : SKLabelNode = SKLabelNode()
    var blackBackground     : SKShapeNode = SKShapeNode()

    override init()
    {
        super.init()
        self.diamondsPlayerHave.fontColor = .black
        self.diamondsPlayerHave.fontName = "OCRAStd"
        self.diamondsPlayerHave.position = CGPoint.zero
        self.diamondsPlayerHave.fontSize = 18
        self.diamondsPlayerHave.zPosition = 4
        
        addChild(self.diamondsPlayerHave)
        
        self.separatorLabel.fontColor = .black
        self.separatorLabel.fontName = "OCRAStd"
        self.separatorLabel.position = CGPoint.zero
        self.separatorLabel.fontSize = 18
        self.separatorLabel.zPosition = 4
        
        addChild(self.separatorLabel)
        
        self.diamondsPlayerNeed.fontColor = .white
        self.diamondsPlayerNeed.fontName = "OCRAStd"
        self.diamondsPlayerNeed.zPosition = 4
        self.diamondsPlayerNeed.position = CGPoint.zero
        self.diamondsPlayerNeed.fontSize = 18
    
        addChild(self.diamondsPlayerNeed)
    }
    
    func setText(diamondNeeded : Int?)
    {
        if let diamondInt = diamondNeeded
        {
            self.hideSeparatorAndNeeded()
            self.separatorLabel.isHidden = false
            self.diamondsPlayerNeed.isHidden = false
            self.diamondsPlayerHave.text = String(1000)
            
            self.blackBackground = SKShapeNode(rect: self.diamondsPlayerHave.frame)
            self.blackBackground.fillColor = .yellow
            self.diamondsPlayerHave.addChild(blackBackground)
            self.blackBackground.zPosition = 0

            
            
            self.diamondsPlayerNeed.text = String(describing: diamondInt)
            
            self.separatorLabel.text = "/"
            
            
            self.separatorLabel.position.x = diamondsPlayerHave.frame.width
            self.blackBackground = SKShapeNode(rect: self.separatorLabel.frame)
            self.blackBackground.fillColor = .red
            self.blackBackground.position = CGPoint.zero
            self.separatorLabel.addChild(blackBackground)
            self.blackBackground.zPosition = 0
            
            
            
            self.blackBackground = SKShapeNode(rect: self.diamondsPlayerNeed.frame)
            self.blackBackground.fillColor = .black
            self.diamondsPlayerNeed.addChild(blackBackground)
            self.blackBackground.zPosition = 0
            self.diamondsPlayerNeed.position = CGPoint.zero
            self.diamondsPlayerNeed.position.x += (self.diamondsPlayerHave.frame.size.width + self.separatorLabel.frame.size.width + 7)
        }
        else
        {
            hideSeparatorAndNeeded()
        }
    }
    
    func hideSeparatorAndNeeded()
    {
        self.separatorLabel.text = ""
        self.separatorLabel.isHidden = true
        
        self.diamondsPlayerNeed.text = ""
        self.diamondsPlayerNeed.isHidden = true
        self.diamondsPlayerNeed.position = CGPoint.zero
        self.diamondsPlayerNeed.removeChildren(in: [blackBackground])
    }

    func pulseNeededDiamonds(withDuration duration: TimeInterval,delay: TimeInterval)
    {
        pulse(node: diamondsPlayerNeed, scaleUpTo: 1.3, scaleDownTo: 1.0, duration: duration,delay: delay)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
