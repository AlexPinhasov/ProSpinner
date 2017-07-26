//
//  Animateable.swift
//  ProSpinner
//
//  Created by AlexP on 11.6.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit
import UIKit

protocol Animateable
{
    func pulse(node: SKNode?, scaleUpTo: CGFloat, scaleDownTo: CGFloat,duration: TimeInterval,delay: TimeInterval)
    func shake(node: SKNode?, byX: Int ,withDuration duration: TimeInterval,completion block: (() -> Void)?)
    func rotateAnimation(imageView:UIImageView,repeat repeatCount: Float,duration: CFTimeInterval)
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
    
    func shake(node: SKNode?, byX: Int = 10,withDuration duration: TimeInterval,completion block: (() -> Void)?)
    {
        let shakeRight = SKAction.move(by: CGVector(dx: byX, dy: 0), duration: duration)
        let shakeLeft = SKAction.move(by: CGVector(dx: -byX, dy: 0), duration: duration)
        let shakeSequene = SKAction.sequence([ shakeRight,shakeLeft,shakeLeft,shakeRight,shakeRight,shakeLeft ])
        
        node?.run(shakeSequene)
        {
            block?()
        }
    }
    
    func rotateAnimation(imageView:UIImageView,repeat repeatCount: Float = Float.greatestFiniteMagnitude ,duration: CFTimeInterval = 2.0)
    {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(.pi * 2.0)
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount = repeatCount
        
        imageView.layer.add(rotateAnimation, forKey: "rotateSpinner")
    }
}
