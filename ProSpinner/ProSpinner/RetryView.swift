//
//  RetryView.swift
//  ProSpinner
//
//  Created by AlexP on 18.6.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit
import UIKit

class RetryView: SKNode
{
//  MARK: Outlets
    private var BlueDiamondLabel        :SKLabelNode?
    private var RedDiamondLabel         :SKLabelNode?
    private var GreenDiamondLabel       :SKLabelNode?
    private var TotalDiamondsCollected  :SKLabelNode?
    private var TimePassed              :SKLabelNode?
    
    private var RetryButton             :SKSpriteNode?
    private var RetryButtonArrow        :SKSpriteNode?
    private var ExitButton              :SKSpriteNode?
    private var EndGameAlert            :SKSpriteNode?
    private var AlertViewBackground     :SKSpriteNode?
    private var shareFacebook           :SKSpriteNode?
    
    private let rotateRightAngle = -(CGFloat.pi * 2)
    
    private var timer = Timer()
    private var secondsPassed: TimeInterval = 0.0
    var finishedPresentingView: Bool = false
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        secondsPassed = 0.0
        connectOutletsToScene()
        configureViewBeforePresentation()
    }

//  MARK: Game Life cycle
    func gameStarted()
    {
        
    }
    
    func gameOver()
    {
        
    }

    private func connectOutletsToScene()
    {
        AlertViewBackground     = self.childNode(withName: Constants.NodesInRetryView.AlertViewBackground.rawValue) as? SKSpriteNode
        EndGameAlert            = AlertViewBackground?.childNode(withName: Constants.NodesInRetryView.EndGameAlert.rawValue) as? SKSpriteNode
        RetryButton             = EndGameAlert?.childNode(withName: Constants.NodesInRetryView.RetryButton.rawValue) as? SKSpriteNode
   
        RetryButtonArrow        = RetryButton?.childNode(withName: Constants.NodesInRetryView.RetryButtonArrow.rawValue) as? SKSpriteNode
        
        ExitButton              = EndGameAlert?.childNode(withName: Constants.NodesInRetryView.ExitButton.rawValue) as? SKSpriteNode
        shareFacebook           = EndGameAlert?.childNode(withName: Constants.NodesInRetryView.ShareFacebook.rawValue) as? SKSpriteNode
        
        BlueDiamondLabel        = EndGameAlert?.childNode(withName: Constants.NodesInRetryView.BlueDiamondLabel.rawValue) as? SKLabelNode
        RedDiamondLabel         = EndGameAlert?.childNode(withName: Constants.NodesInRetryView.RedDiamondLabel.rawValue) as? SKLabelNode
        GreenDiamondLabel       = EndGameAlert?.childNode(withName: Constants.NodesInRetryView.GreenDiamondLabel.rawValue) as? SKLabelNode
        TimePassed              = EndGameAlert?.childNode(withName: Constants.NodesInRetryView.TimePassed.rawValue) as? SKLabelNode
        TotalDiamondsCollected  = EndGameAlert?.childNode(withName: Constants.NodesInRetryView.TotalDiamondsCollected.rawValue) as? SKLabelNode
    }
    
    func configureViewBeforePresentation()
    {
        AlertViewBackground?.alpha = 0.0
        EndGameAlert?.run(SKAction.move(to: CGPoint(x: 0, y: 500), duration: 0))
    }
    
//  MARK: Presentation methods
    func presentRetryView(completion block: (() -> Void)?)
    {
        if finishedPresentingView == false
        {
            self.isHidden = false
            AlertViewBackground?.run(SKAction.fadeIn(withDuration: 0.2))
            {
                self.EndGameAlert?.run(SKAction.move(to: CGPoint(x: 0, y: 0), duration: 0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
                {
                    block?()
                    self.finishedPresentingView = true
                }
            }

            rotateRetryButton()
        }
    }
    
    func hideRetryView()
    {
        if finishedPresentingView
        {
            secondsPassed = 0.0
            EndGameAlert?.run(SKAction.move(to: CGPoint(x: 0, y: 500), duration: 0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
            {
                self.finishedPresentingView = false
                self.isHidden = true
            }
            self.AlertViewBackground?.run(SKAction.sequence([ SKAction.wait(forDuration: 0.2) , SKAction.fadeOut(withDuration: 0.1) ]))
        }
    }
    
    func setDiamondsCollected(diamonds: DiamondsTuple)
    {
        guard let diamonds = diamonds else { return }
        
        let redPlusSign = diamonds.red > 0 ? "+" : ""
        let bluePlusSign = diamonds.blue > 0 ? "+" : ""
        let greenPlusSign = diamonds.green > 0 ? "+" : ""
        
        self.RedDiamondLabel?.text = redPlusSign + String(diamonds.red)
        self.BlueDiamondLabel?.text = bluePlusSign + String(diamonds.blue)
        self.GreenDiamondLabel?.text = greenPlusSign + String(diamonds.green)
        self.TotalDiamondsCollected?.text = String(diamonds.red + diamonds.blue + diamonds.green)
        
        ArchiveManager.highScoreRecord = (diamonds.red + diamonds.blue + diamonds.green)
        
        let highScoreNSNumber = NSNumber(value: ArchiveManager.highScoreRecord)
        CrashlyticsLogManager.gameEnded(withScore: highScoreNSNumber)
    }
 
    private func rotateRetryButton()
    {
        let rotateAction = SKAction.rotate(byAngle: rotateRightAngle, duration: 4)
        RetryButtonArrow?.run(SKAction.repeatForever(rotateAction),withKey: Constants.actionKeys.rotate.rawValue)
    }
    
    func shareWithFacebook()
    {
        let image = UIImage(named: "8")
        ShareManager.shareToFacebook(withTitle: "Check out my score", shareContent: [applicationItunesUrl,image], withCompletionHandler: nil)
    }
    
//  MARK: Private timer methods
    @objc private func counter()
    {
        secondsPassed += 1
    }
}
