//
//  GameModeView.swift
//  ProSpinner
//
//  Created by AlexP on 29.7.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit

class GameModeView: SKNode
{
    private var gameModeBackground        :SKSpriteNode?

    private var freeSpinNode: SKNode?
    private var fixedSpinNode: SKNode?
    
    private var freeSpinButton: SKSpriteNode?
    private var fixedSpinButton: SKSpriteNode?
    private var selectGame: SKSpriteNode?

    private var freeHighScoreLabel: SKLabelNode?
    private var fixedHighScoreLabel: SKLabelNode?
    
    var finishedPresentingView: Bool = false
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        connectOutletsToScene()
        configureViewBeforePresentation()
    }
    
    private func connectOutletsToScene()
    {
        gameModeBackground    = self.childNode(withName: Constants.NodesInGameModeNode.GameModeBackground.rawValue) as? SKSpriteNode
        
        freeSpinNode         = gameModeBackground?.childNode(withName: Constants.NodesInGameModeNode.FreeSpinNode.rawValue)
        fixedSpinNode         = gameModeBackground?.childNode(withName: Constants.NodesInGameModeNode.FixedSpinNode.rawValue)
        
        freeSpinButton         = freeSpinNode?.childNode(withName: Constants.NodesInGameModeNode.FreeSpinGameMode.rawValue) as? SKSpriteNode
        freeHighScoreLabel         = freeSpinButton?.childNode(withName: Constants.NodesInGameModeNode.FreeHighScoreLabel.rawValue) as? SKLabelNode
        
        fixedSpinButton         = fixedSpinNode?.childNode(withName: Constants.NodesInGameModeNode.FixedSpinGameMode.rawValue) as? SKSpriteNode
        fixedHighScoreLabel     = fixedSpinButton?.childNode(withName: Constants.NodesInGameModeNode.FixedHighScoreLabel.rawValue) as? SKLabelNode
        
        selectGame         = freeSpinNode?.childNode(withName: Constants.NodesInGameModeNode.selectGame.rawValue) as? SKSpriteNode
        
    }
    
    func configureViewBeforePresentation()
    {
        self.isHidden = true
        gameModeBackground?.alpha = 0.0
        freeSpinButton?.xScale = 0.0
        freeSpinButton?.yScale = 0.0

        fixedSpinButton?.xScale = 0.0
        fixedSpinButton?.yScale = 0.0
    }
    
    func presentGameModeView(completion block: (() -> Void)?)
    {
        if finishedPresentingView == false
        {
            let scorePrefix = "score: "
            fixedHighScoreLabel?.text = scorePrefix + String(ArchiveManager.highScoreRecordFixed)
            freeHighScoreLabel?.text = scorePrefix + String(ArchiveManager.highScoreRecord)
            
            self.isHidden = false
            gameModeBackground?.run(SKAction.fadeIn(withDuration: 0.2))
            {
                self.freeSpinButton?.run(SKAction.scale(to: 1.0, duration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
                {
                    block?()
                    self.finishedPresentingView = true
                }
                
                self.fixedSpinButton?.run(SKAction.scale(to: 1.0, duration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
            }
        }
    }
    
    func hideGameModeView()
    {
        if finishedPresentingView
        {
            
            
            self.fixedSpinButton?.run(SKAction.scale(to: 0.0, duration: 0.4, delay: 0, usingSpringWithDamping: 0.1, initialSpringVelocity: 1))
            self.freeSpinButton?.run(SKAction.scale(to: 0.0, duration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
            {
                self.finishedPresentingView = false
                self.isHidden = true
            }
            self.gameModeBackground?.run(SKAction.sequence([SKAction.wait(forDuration: 0.2),SKAction.fadeOut(withDuration: 0.2)]))
        }
    }
    
}
