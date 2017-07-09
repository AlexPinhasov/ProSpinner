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
    var diamondsPlayerNeed  : SKLabelNode = SKLabelNode()
    var blackBackground     : SKShapeNode = SKShapeNode()

    override init()
    {
        super.init()
        self.diamondsPlayerHave.fontColor = .black
        self.diamondsPlayerHave.fontName = "MyriadPro-Cond"
        self.diamondsPlayerHave.position = CGPoint.zero
        self.diamondsPlayerHave.fontSize = 26
        self.diamondsPlayerHave.zPosition = 4
        
        addChild(self.diamondsPlayerHave)

        self.diamondsPlayerNeed.fontColor = .white
        self.diamondsPlayerNeed.fontName = "MyriadPro-Cond"
        self.diamondsPlayerNeed.zPosition = 5
        self.diamondsPlayerNeed.position = CGPoint.zero
        self.diamondsPlayerNeed.fontSize = 26
        self.diamondsPlayerNeed.horizontalAlignmentMode = .left
    
        addChild(self.diamondsPlayerNeed)
    }
    
    func setText(diamondNeeded : Int?)
    {
        log.debug()
        hideSeparatorAndNeeded()
        
        if let diamondInt = diamondNeeded
        {
            diamondsPlayerNeed.text = String(describing: diamondInt)
            //changeFontToAllLabels(fontSize: 24)
            
            diamondsPlayerHave.horizontalAlignmentMode = .left
            diamondsPlayerHave.text?.append(" / " + (diamondsPlayerNeed.text ?? ""))

            blackBackground = SKShapeNode(rect: self.diamondsPlayerNeed.frame)
            blackBackground.fillColor = .black
            //blackBackground.strokeColor = .clear
            diamondsPlayerNeed.addChild(blackBackground)
            blackBackground.zPosition = 0
            diamondsPlayerNeed.position = CGPoint.zero
            diamondsPlayerNeed.isHidden = false
            diamondsPlayerNeed.position.x += (self.diamondsPlayerHave.frame.width - diamondsPlayerNeed.frame.width )
        }
    }
    
    func hideSeparatorAndNeeded()
    {
        log.debug()
        diamondsPlayerNeed.isHidden = true
        diamondsPlayerNeed.text = nil
        diamondsPlayerNeed.position = CGPoint.zero
        diamondsPlayerNeed.removeChildren(in: [blackBackground])
    
        diamondsPlayerHave.text = diamondsPlayerHave.text?.replacingOccurrences(of: " ", with: "")
        if let i = diamondsPlayerHave.text?.characters.index(of: "/"),
           let endIndex = diamondsPlayerHave.text?.characters.endIndex
        {
            diamondsPlayerHave.text!.removeSubrange(i..<endIndex)
        }
        diamondsPlayerHave.horizontalAlignmentMode = .center
    }
    
    func changeLabelColor(color: UIColor)
    {
        diamondsPlayerHave.fontColor = color
    }
    
    func frameTotalWidth() -> CGFloat
    {
        log.debug()
        return diamondsPlayerHave.frame.width 
    }
    
    func changeFontToAllLabels(fontSize size: CGFloat)
    {
        log.debug()
        diamondsPlayerHave.fontSize = size
        diamondsPlayerNeed.fontSize = size
    }
    
    func pulseNeededDiamonds(withDuration duration: TimeInterval,delay: TimeInterval)
    {
        log.debug()
        pulse(node: diamondsPlayerNeed, scaleUpTo: 1.3, scaleDownTo: 1.0, duration: duration,delay: delay)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
