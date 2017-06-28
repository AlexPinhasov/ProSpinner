//
//  SKSpriteButton.swift
//  ProSpinner
//
//  Created by Alex Pinhasov on 28/06/2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit

class SKSpriteButton: SKSpriteNode
{
    var originalPosition: CGPoint = CGPoint.zero
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        originalPosition = self.position
    }
    
    func touchedUpInside()
    {
        if self.position == originalPosition
        {
            self.run(SKAction.move(by: CGVector(dx: 0, dy: -6), duration: 0.05))
        }
    }
    
    func releasedButton()
    {
        if self.position != originalPosition
        {
            self.run(SKAction.move(to: originalPosition, duration: 0.05))
        }
    }
}
