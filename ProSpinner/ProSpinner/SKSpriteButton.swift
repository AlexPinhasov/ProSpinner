//
//  SKSpriteButton.swift
//  ProSpinner
//
//  Created by Alex Pinhasov on 28/06/2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit

class SKSpriteButton: SKSpriteNode,Animateable
{
    var originalPosition   : CGPoint = CGPoint.zero
    var moveBy             : CGFloat = 0
    var delegate           : ButtonProtocol?
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        originalPosition = self.position
    }
    
    func touchedUpInside()
    {
        if self.position == originalPosition
        {
            enableSwipe = false
            self.run(SKAction.move(by: CGVector(dx: 0, dy: moveBy), duration: 0.05))
            self.delegate?.buttonIsPressed()
        }
    }
    
    func releasedButton()
    {
        if self.position != originalPosition
        {
            self.run(SoundLibrary.blopSound)
            pulse(node: self, scaleUpTo: 1.2, scaleDownTo: 1.0, duration: 0.2)
            enableSwipe = true
            self.run(SKAction.move(to: originalPosition, duration: 0.05))
            self.delegate?.buttonReleased()
        }
    }
}
