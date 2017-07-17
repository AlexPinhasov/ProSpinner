//
//  SideMenuView.swift
//  ProSpinner
//
//  Created by AlexP on 16.7.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit

class SideMenuView: SKNode,Animateable
{
    private var sideMenuBackground: SKSpriteNode?
    private var muteSound         : SKSpriteNode?
    private var backgroundMusic   : SKAudioNode!
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        configureSound()
        connectOutletsToScene()
        configureViewBeforePresentation()
        changeSoundUI()
    }
    
    private func connectOutletsToScene()
    {
        sideMenuBackground    = self.childNode(withName: Constants.NodesInSideMenu.sideMenuBackground.rawValue) as? SKSpriteNode
        muteSound             = self.childNode(withName: Constants.NodesInSideMenu.muteSound.rawValue) as? SKSpriteNode
    }
    
    func configureViewBeforePresentation()
    {
        self.isHidden = true
        self.position.x = -50
    }
    

    //  MARK: Presentation methods
    func showSideView()
    {
        self.isHidden = false
        self.run(SKAction.moveTo(x: 0, duration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
    }
    
    func hideSideMenu()
    {
        self.run(SKAction.moveTo(x: -50, duration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1))
        {
            self.isHidden = true
        }
    }
    
    func didTapSound()
    {
        pulse(node: muteSound, scaleUpTo: 1.2, scaleDownTo: 1.0, duration: 0.4)
        ArchiveManager.shouldPlaySound = !ArchiveManager.shouldPlaySound
        changeSoundUI()
    }
    
    private func changeSoundUI()
    {
        if ArchiveManager.shouldPlaySound == true
        {
            muteSound?.texture = SKTexture(imageNamed: "SoundOn")
        }
        else
        {
            muteSound?.texture = SKTexture(imageNamed: "SoundOff2")
        }
    }
    
    func configureSound()
    {
        if let musicURL = Bundle.main.url(forResource: "BackgroundMusic", withExtension: "wav")
        {
            backgroundMusic = SKAudioNode(url: musicURL)
            addChild(backgroundMusic)
            backgroundMusic?.run(SKAction.stop())
            backgroundMusic?.run(SKAction.changeVolume(to: 0, duration: 0))
            playSoundIfNeeded()
        }
    }
    
    func playSoundIfNeeded()
    {
        if ArchiveManager.shouldPlaySound
        {
            backgroundMusic?.run(SKAction.play())
            backgroundMusic?.run(SKAction.changeVolume(to: 0.8, duration: 5))
        }
        else
        {
            backgroundMusic?.run(SKAction.stop())
        }
    }
    
    func changeVolumeTo(value: Float ,duration: TimeInterval)
    {
        if ArchiveManager.shouldPlaySound
        {
            backgroundMusic?.run(SKAction.changeVolume(to: value, duration: duration))
        }
    }
}
