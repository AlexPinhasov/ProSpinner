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

    private var finishedPresentingView: Bool = false
    
//  MARK: Purchase Alert Properties
    private var storePurchaseAlert      :SKSpriteNode?
    private var redToGet                :SKLabelNode?
    private var blueToGet               :SKLabelNode?
    private var greenToGet              :SKLabelNode?
    private var packageTexture          :SKSpriteNode?
    private var loadingSpinner          :SKSpriteNode?
    
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        connectOutletsToScene()
        configureViewBeforePresentation()
        configureCostFromProducts()
    }
    
    //  MARK: Game Life cycle
    private func configureCostFromProducts()
    {
        PurchaseManager.getInfo() { (result) in
            
            for product in result.retrievedProducts
            {
                if product.localizedTitle == "Big Diamond Pack", let price = product.localizedPrice
                {
                    self.bigDiamondGroupCost?.text = price
                }
                
                if product.localizedTitle == "Diamond Pack",let price = product.localizedPrice
                {
                    self.smallDiamondGroupCost?.text = price
                }
            }
        }
    }
    
    private func connectOutletsToScene()
    {
        storeBackground        = self.childNode(withName: Constants.NodesInStoreView.StoreBackground.rawValue) as? SKSpriteNode
        storeAlert             = self.childNode(withName: Constants.NodesInStoreView.storeAlert.rawValue) as? SKSpriteNode
        exitButton             = storeAlert?.childNode(withName: Constants.NodesInStoreView.exitButton.rawValue) as? SKSpriteNode
        
        smallDiamondGroup      = storeAlert?.childNode(withName: Constants.NodesInStoreView.smallDiamondGroup.rawValue) as? SKSpriteNode
        
        smallPackButton         = storeAlert?.childNode(withName: Constants.NodesInStoreView.smallPackButton.rawValue) as? SKSpriteButton
        bigPackButton           = storeAlert?.childNode(withName: Constants.NodesInStoreView.bigPackButton.rawValue) as? SKSpriteButton
        smallDiamondGroupCost   = smallPackButton?.childNode(withName: Constants.NodesInStoreView.smallDiamondGroupCost.rawValue) as? SKLabelNode
        smallPackButton?.moveBy = -6
        bigPackButton?.moveBy   = -6
        
        bigDiamondGroup         = storeAlert?.childNode(withName: Constants.NodesInStoreView.bigDiamondGroup.rawValue) as? SKSpriteNode
        bigDiamondGroupCost     = bigPackButton?.childNode(withName: Constants.NodesInStoreView.bigDiamondGroupCost.rawValue) as? SKLabelNode
        
        storePurchaseAlert      = self.childNode(withName: Constants.NodesInLockedWhenPurchase.StorePurchaseInProgressAlert.rawValue) as? SKSpriteNode
        redToGet                = storePurchaseAlert?.childNode(withName: Constants.NodesInLockedWhenPurchase.RedToRecive.rawValue) as? SKLabelNode
        blueToGet               = storePurchaseAlert?.childNode(withName: Constants.NodesInLockedWhenPurchase.BlueToRecive.rawValue) as? SKLabelNode
        greenToGet              = storePurchaseAlert?.childNode(withName: Constants.NodesInLockedWhenPurchase.GreenToRecive.rawValue) as? SKLabelNode
        packageTexture          = storePurchaseAlert?.childNode(withName: Constants.NodesInLockedWhenPurchase.PackageRequested.rawValue) as? SKSpriteNode
        loadingSpinner          = storePurchaseAlert?.childNode(withName: Constants.NodesInLockedWhenPurchase.loadingSpinner.rawValue) as? SKSpriteNode
    }
    
    func configureViewBeforePresentation()
    {
        self.isHidden = true
        storeBackground?.alpha = 0.0
        storeAlert?.run(SKAction.move(to: CGPoint(x: 160, y: 800), duration: 0))
    }
    
    func configurePurchaseAlert(registeredPurchase: RegisteredPurchase)
    {
        var diamondBought = "0"
        switch registeredPurchase
        {
        case .SmallDiamondPack:
            diamondBought = "+100"
            packageTexture?.texture = SKTexture(imageNamed: "DiamondGroupSmall")
            
        case .BigDiamondPack:
            diamondBought = "+300"
            packageTexture?.texture = SKTexture(imageNamed: "DiamondGroupLarge")
            
        }
        
        redToGet?.text = diamondBought
        blueToGet?.text = diamondBought
        greenToGet?.text = diamondBought
        
        let rotateAction = SKAction.rotate(byAngle: (CGFloat.pi * 2), duration: 1)
        loadingSpinner?.run(SKAction.repeatForever(rotateAction),withKey: Constants.actionKeys.rotate.rawValue)
        
        storePurchaseAlert?.isHidden = false
        storePurchaseAlert?.run(SKAction.fadeIn(withDuration: 0.2))
    }
    
    //  MARK: Presentation methods
    func presentStoreView()
    {
        self.isHidden = false
        storeBackground?.run(SKAction.fadeIn(withDuration: 0.1))
        {
            self.storeAlert?.run(SKAction.move(to: CGPoint(x: 160, y: 278), duration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
            {
                self.finishedPresentingView = true
            }
        }
        resetLoadingPurchase()
    }
    
    func hideStoreView()
    {
        if finishedPresentingView == true
        {
            finishedPresentingView = false
            storeAlert?.run(SKAction.move(to: CGPoint(x: 160, y: 800), duration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
            {
                self.isHidden = true
            }
            
            self.storeBackground?.run(SKAction.sequence([ SKAction.wait(forDuration: 0.2) , SKAction.fadeOut(withDuration: 0.1) ]))
        }
        resetLoadingPurchase()
    }
    
    func resetLoadingPurchase()
    {
        loadingSpinner?.removeAction(forKey: Constants.actionKeys.rotate.rawValue)
        storePurchaseAlert?.run(SKAction.fadeOut(withDuration: 0.2))
        {
            self.storePurchaseAlert?.isHidden = true
        }
        
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
