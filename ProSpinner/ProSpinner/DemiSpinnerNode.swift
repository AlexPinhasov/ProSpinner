//
//  DemiSpinnerNode.swift
//  ProSpinner
//
//  Created by AlexP on 15.7.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit

class DemiSpinnerNode: SKNode,ButtonProtocol
{
    var reviewButton       : SKSpriteButton?
    var reviewButtonShadow : SKSpriteNode?
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        connectOutletsFromScene()
    }
    
    func connectOutletsFromScene()
    {
        reviewButton        = self.childNode(withName: Constants.NodesInScene.ReviewButton.rawValue)  as? SKSpriteButton
        reviewButtonShadow  = self.childNode(withName: Constants.NodesInScene.ReviewButtonShadow.rawValue) as? SKSpriteNode
        
        reviewButton?.moveBy = -3
        reviewButton?.delegate = self
    }
    
    static func goToItunesForReview(completion: @escaping ((_ success: Bool)->()))
    {
        guard let url = applicationReviewUrl
        else
        {
            completion(false)
            return
        }
        
        guard #available(iOS 10, *) else
        {
            UIApplication.shared.openURL(url)
            return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
    
    func showNode()
    {
        self.isHidden = false
        self.run(SKAction.scale(to: 1, duration: 0.7, delay: 0.30, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
    }
    
    func hideNode()
    {
        self.run(SKAction.scale(to: 0, duration: 0.7, delay: 0.10, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
        {
            self.isHidden = true
        }
    }
    
    
    func buttonIsPressed()
    {
        
    }
    
    func buttonReleased()
    {
        
    }
}
