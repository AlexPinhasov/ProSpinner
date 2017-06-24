//
//  RetryView.swift
//  ProSpinner
//
//  Created by AlexP on 18.6.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit
import UIKit

class RetryView: BaseClass
{
//  MARK: Outlets
    private var BlueDiamondLabel        :SKLabelNode?
    private var RedDiamondLabel         :SKLabelNode?
    private var GreenDiamondLabel       :SKLabelNode?
    private var TotalDiamondsCollected  :SKLabelNode?
    private var TimePassed              :SKLabelNode?
    
    private var RetryButton             :SKSpriteNode?
    private var ExitButton              :SKSpriteNode?
    private var EndGameAlert            :SKSpriteNode?
    private var AlertViewBackground     :SKSpriteNode?
    
    private let rotateRightAngle = -(CGFloat.pi * 2)
    
    private var timer = Timer()
    private var secondsPassed: TimeInterval = 0.0
    
    init(scene: SKScene)
    {
        super.init()
        self.scene = scene
        connectOutletsToScene()
        configureViewBeforePresentation()
    }

//  MARK: Game Life cycle
    func gameStarted()
    {
        startTimer()
    }
    
    func gameOver()
    {
        endTimer()
    }

    private func connectOutletsToScene()
    {
        AlertViewBackground     = self.scene?.childNode(withName: Constants.NodesInRetryView.AlertViewBackground.rawValue) as? SKSpriteNode
        EndGameAlert            = AlertViewBackground?.childNode(withName: Constants.NodesInRetryView.EndGameAlert.rawValue) as? SKSpriteNode
        RetryButton             = AlertViewBackground?.childNode(withName: Constants.NodesInRetryView.RetryButton.rawValue) as? SKSpriteNode
        ExitButton              = EndGameAlert?.childNode(withName: Constants.NodesInRetryView.ExitButton.rawValue) as? SKSpriteNode
        
        BlueDiamondLabel        = EndGameAlert?.childNode(withName: Constants.NodesInRetryView.BlueDiamondLabel.rawValue) as? SKLabelNode
        RedDiamondLabel         = EndGameAlert?.childNode(withName: Constants.NodesInRetryView.RedDiamondLabel.rawValue) as? SKLabelNode
        GreenDiamondLabel       = EndGameAlert?.childNode(withName: Constants.NodesInRetryView.GreenDiamondLabel.rawValue) as? SKLabelNode
        TimePassed              = EndGameAlert?.childNode(withName: Constants.NodesInRetryView.TimePassed.rawValue) as? SKLabelNode
        TotalDiamondsCollected  = EndGameAlert?.childNode(withName: Constants.NodesInRetryView.TotalDiamondsCollected.rawValue) as? SKLabelNode
    }
    
    func configureViewBeforePresentation()
    {
        AlertViewBackground?.alpha = 0.0
        RetryButton?.run(SKAction.move(to: CGPoint(x: 0, y: -350), duration: 0))
        EndGameAlert?.run(SKAction.move(to: CGPoint(x: 0, y: 400), duration: 0))
    }
    
//  MARK: Presentation methods
    func presentRetryView()
    {
        AlertViewBackground?.isHidden = false
        AlertViewBackground?.run(SKAction.fadeIn(withDuration: 0.2))
        {
            self.EndGameAlert?.run(SKAction.move(to: CGPoint(x: 0, y: 18), duration: 0.3))
            self.RetryButton?.run(SKAction.move(to: CGPoint(x: 0, y: -185), duration: 0.3))
        }

        rotateRetryButton()
    }
    
    func hideRetryView()
    {
        secondsPassed = 0.0
        RetryButton?.run(SKAction.move(to: CGPoint(x: 0, y: -350), duration: 0.3))
        EndGameAlert?.run(SKAction.move(to: CGPoint(x: 0, y: 400), duration: 0.3))
        {
            self.AlertViewBackground?.run(SKAction.fadeOut(withDuration: 0.3))
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
    }
 
    private func rotateRetryButton()
    {
        let rotateAction = SKAction.rotate(byAngle: rotateRightAngle, duration: 4)
        RetryButton?.run(SKAction.repeatForever(rotateAction),withKey: Constants.actionKeys.rotate.rawValue)
    }
    
//  MARK: Private timer methods
    private func startTimer()
    {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(counter), userInfo: nil, repeats: true)
    }
    
    private func endTimer()
    {
        self.timer.invalidate()
        self.TimePassed?.text = timeString(time: secondsPassed)
    }
    
    @objc private func counter()
    {
        secondsPassed += 1
    }
    
    private func timeString(time: TimeInterval) -> String
    {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
}
