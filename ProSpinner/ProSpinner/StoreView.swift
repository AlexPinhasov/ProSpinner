//
//  StoreView.swift
//  ProSpinner
//
//  Created by AlexP on 23.6.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit

class StoreView: SKNode
{
//  MARK: Outlets
    private var smallDiamondGroup      :SKSpriteNode?
    private var bigDiamondGroup        :SKSpriteNode?
    
    private var smallDiamondGroupCost  :SKLabelNode?
    private var bigDiamondGroupCost    :SKLabelNode?
    
    private var exitButton             :SKSpriteNode?
    private var storeAlert             :SKSpriteNode?
    private var storeBackground        :SKSpriteNode?
    
    private var smallPackButton        :SKSpriteButton?
    private var bigPackButton          :SKSpriteButton?

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        connectOutletsToScene()
        configureViewBeforePresentation()
    }
    
    //  MARK: Game Life cycle
    private func connectOutletsToScene()
    {
        storeBackground        = self.childNode(withName: Constants.NodesInStoreView.StoreBackground.rawValue) as? SKSpriteNode
        storeAlert             = self.childNode(withName: Constants.NodesInStoreView.storeAlert.rawValue) as? SKSpriteNode
        exitButton             = storeAlert?.childNode(withName: Constants.NodesInStoreView.exitButton.rawValue) as? SKSpriteNode
        
        smallDiamondGroup      = storeAlert?.childNode(withName: Constants.NodesInStoreView.smallDiamondGroup.rawValue) as? SKSpriteNode
        smallDiamondGroupCost  = smallDiamondGroup?.childNode(withName: Constants.NodesInStoreView.smallDiamondGroupCost.rawValue) as? SKLabelNode
        
        smallPackButton         = storeAlert?.childNode(withName: Constants.NodesInStoreView.smallPackButton.rawValue) as? SKSpriteButton
        bigPackButton           = storeAlert?.childNode(withName: Constants.NodesInStoreView.bigPackButton.rawValue) as? SKSpriteButton
        smallPackButton?.moveBy = -6
        bigPackButton?.moveBy   = -6
        
        bigDiamondGroup        = storeAlert?.childNode(withName: Constants.NodesInStoreView.bigDiamondGroup.rawValue) as? SKSpriteNode
        bigDiamondGroupCost    = bigDiamondGroup?.childNode(withName: Constants.NodesInStoreView.bigDiamondGroupCost.rawValue) as? SKLabelNode
        

    }
    
    func configureViewBeforePresentation()
    {
        self.isHidden = true
        storeBackground?.alpha = 0.0
        storeAlert?.run(SKAction.move(to: CGPoint(x: 160, y: 700), duration: 0))
    }
    
    //  MARK: Presentation methods
    func presentStoreView()
    {
        self.isHidden = false
        storeBackground?.run(SKAction.fadeIn(withDuration: 0.1))
        {
            self.storeAlert?.run(SKAction.move(to: CGPoint(x: 160, y: 278), duration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
        }
    }
    
    func hideStoreView()
    {
        storeAlert?.run(SKAction.move(to: CGPoint(x: 160, y: 700), duration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
        {
            self.isHidden = true
        }
        
        self.storeBackground?.run(SKAction.sequence([ SKAction.wait(forDuration: 0.2) , SKAction.fadeOut(withDuration: 0.1) ]))
    }
    
    func touchedUpSmallPackButton()
    {
        smallPackButton?.touchedUpInside()
    }
    
    func touchedUpBigPackButton()
    {
        bigPackButton?.touchedUpInside()
    }
    
    func releasedButton(button: SKNode?)
    {
        smallPackButton?.releasedButton()
        bigPackButton?.releasedButton()
    }
    
    func setSmallDiamondsGroupCost()
    {

    }
    
    func setBigDiamondsGroupCost()
    {
        
    }

}
