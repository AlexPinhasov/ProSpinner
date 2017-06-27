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
    
    var addX : CGFloat = 0

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
            self.diamondsPlayerNeed.text = String(describing: diamondInt)
            self.separatorLabel.text = "/"
            self.changeFontToAllLabels(fontSize: 18)
            self.separatorLabel.position.x = diamondsPlayerHave.frame.width
            
            if let diamondsPlayerHaveText = diamondsPlayerHave.text,
               let diamondsPlayerHaveInt = Int(diamondsPlayerHaveText)
            {
                let diamondsPlayerHaveCGFloat = CGFloat(diamondsPlayerHaveInt)
                if diamondsPlayerHaveCGFloat < 10
                {
                    addX = 0
                }
                else if diamondsPlayerHaveCGFloat >= 10 &&  diamondsPlayerHaveCGFloat < 100
                {
                    addX = 7
                }
                else if diamondsPlayerHaveCGFloat >= 100 && diamondsPlayerHaveCGFloat < 1000
                {
                    addX = 13
                }
                else if diamondsPlayerHaveCGFloat >= 1000 && diamondsPlayerHaveCGFloat < 10000
                {
                    changeFontToAllLabels(fontSize: 15)
                    addX = 22.5
                }
                
                self.diamondsPlayerHave.position.x += addX
            }
            
            self.blackBackground = SKShapeNode(rect: self.diamondsPlayerNeed.frame)
            self.blackBackground.fillColor = .black
            self.diamondsPlayerNeed.addChild(blackBackground)
            self.blackBackground.zPosition = 0
            self.diamondsPlayerNeed.position = CGPoint.zero
            self.diamondsPlayerNeed.position.x += (self.diamondsPlayerHave.frame.size.width + self.separatorLabel.frame.size.width + addX)
        }
        else
        {
            hideSeparatorAndNeeded()
        }
    }
    
    func hideSeparatorAndNeeded()
    {
        self.separatorLabel.text = nil
        self.separatorLabel.isHidden = true
         self.diamondsPlayerHave.position.x = 0
        self.diamondsPlayerNeed.text = nil
        self.diamondsPlayerNeed.isHidden = true
        self.diamondsPlayerNeed.position = CGPoint.zero
        self.diamondsPlayerNeed.removeChildren(in: [blackBackground])
    }

    func frameTotalWidth() -> CGFloat
    {
        if addX == 22.5
        {
            return diamondsPlayerHave.frame.width + 8
        }
        return diamondsPlayerHave.frame.width 
    }
    
    func changeFontToAllLabels(fontSize size: CGFloat)
    {
        self.diamondsPlayerHave.fontSize = size
        self.diamondsPlayerNeed.fontSize = size
        self.separatorLabel.fontSize = size
    }
    
    func pulseNeededDiamonds(withDuration duration: TimeInterval,delay: TimeInterval)
    {
        pulse(node: diamondsPlayerNeed, scaleUpTo: 1.3, scaleDownTo: 1.0, duration: duration,delay: delay)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
