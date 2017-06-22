//
//  Animateable.swift
//  ProSpinner
//
//  Created by AlexP on 11.6.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit

protocol Animateable
{
    func pulse(node: SKNode?, scaleUpTo: CGFloat, scaleDownTo: CGFloat,duration: TimeInterval,delay: TimeInterval)
}

extension Animateable
{
    func pulse(node: SKNode?, scaleUpTo: CGFloat, scaleDownTo: CGFloat,duration: TimeInterval,delay: TimeInterval = 0)
    {
        let pulseUp = SKAction.scale(to: scaleUpTo,
                                     duration: duration,
                                     delay: delay,
                                     usingSpringWithDamping: 1,
                                     initialSpringVelocity: 1)
        node?.run(pulseUp)
        {
            let pulseDown = SKAction.scale(to: scaleDownTo,
                                           duration: duration,
                                           delay: 0,
                                           usingSpringWithDamping: 2,
                                           initialSpringVelocity: 2)
            node?.run(pulseDown)
        }
    }
}
