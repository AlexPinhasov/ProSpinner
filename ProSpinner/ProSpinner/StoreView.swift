//
//  StoreView.swift
//  ProSpinner
//
//  Created by AlexP on 23.6.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit

class StoreView: BaseClass
{
//  MARK: Outlets
    private var smallDiamondGroup      :SKSpriteNode?
    private var bigDiamondGroup        :SKSpriteNode?
    
    private var smallDiamondGroupCost  :SKLabelNode?
    private var bigDiamondGroupCost    :SKLabelNode?
    
    private var exitButton             :SKSpriteNode?
    private var storeAlert             :SKSpriteNode?
    private var storeBackground        :SKSpriteNode?
    
    init(scene: SKScene)
    {
        super.init()
        self.scene = scene
        connectOutletsToScene()
        configureViewBeforePresentation()
    }
    
    //  MARK: Game Life cycle
    private func connectOutletsToScene()
    {
        storeBackground        = self.scene?.childNode(withName: Constants.NodesInStoreView.StoreBackground.rawValue) as? SKSpriteNode
        storeAlert             = storeBackground?.childNode(withName: Constants.NodesInStoreView.storeAlert.rawValue) as? SKSpriteNode
        exitButton             = storeAlert?.childNode(withName: Constants.NodesInStoreView.exitButton.rawValue) as? SKSpriteNode
        
        smallDiamondGroup      = storeAlert?.childNode(withName: Constants.NodesInStoreView.smallDiamondGroup.rawValue) as? SKSpriteNode
        smallDiamondGroupCost  = storeAlert?.childNode(withName: Constants.NodesInStoreView.smallDiamondGroupCost.rawValue) as? SKLabelNode
        
        bigDiamondGroup        = storeAlert?.childNode(withName: Constants.NodesInStoreView.bigDiamondGroup.rawValue) as? SKSpriteNode
        bigDiamondGroupCost    = storeAlert?.childNode(withName: Constants.NodesInStoreView.bigDiamondGroupCost.rawValue) as? SKLabelNode
        

    }
    
    func configureViewBeforePresentation()
    {
        storeBackground?.alpha = 0.0
        storeAlert?.run(SKAction.move(to: CGPoint(x: 0, y: 400), duration: 0))
    }
    
    //  MARK: Presentation methods
    func presentStoreView()
    {
        storeBackground?.isHidden = false
        storeBackground?.run(SKAction.fadeIn(withDuration: 0.1))
        {
            self.storeAlert?.run(SKAction.move(to: CGPoint(x: 0, y: 18), duration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
        }
    }
    
    func hideStoreView()
    {
        storeAlert?.run(SKAction.move(to: CGPoint(x: 0, y: 700), duration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
        
        self.storeBackground?.run(SKAction.sequence([ SKAction.wait(forDuration: 0.2) , SKAction.fadeOut(withDuration: 0.1) ]))
    }
    
    func setSmallDiamondsGroupCost()
    {

    }
    
    func setBigDiamondsGroupCost()
    {
        
    }

}
