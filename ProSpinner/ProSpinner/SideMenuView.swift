//
//  SideMenuView.swift
//  ProSpinner
//
//  Created by AlexP on 16.7.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit
import AVFoundation

class SideMenuView: SKNode,Animateable
{
    private var sideMenuBackground: SKSpriteNode?
    private var muteSound         : SKSpriteNode?
    private var backgroundMusic   : SKAudioNode!
    
    
    var engine = AVAudioEngine()
    var audioFile = AVAudioFile()
    var audioPlayerNode = AVAudioPlayerNode()
    var changeAudioUnitTime = AVAudioUnitTimePitch()
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setUpEngine()
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
        self.run(SoundLibrary.blopSound)
        pulse(node: muteSound, scaleUpTo: 1.2, scaleDownTo: 1.0, duration: 0.2)
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
        audioPlayerNode.stop()
        engine.stop()
        engine.reset()
        engine.attach(audioPlayerNode)
        changeAudioUnitTime.pitch = 0
        engine.attach(changeAudioUnitTime)
        engine.connect(audioPlayerNode, to: changeAudioUnitTime, format: nil)
        engine.connect(changeAudioUnitTime, to: engine.outputNode, format: nil)
        try? engine.start()
        audioPlayerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
    }
    
    func setUpEngine()
    {
        if let fileString = Bundle.main.path(forResource: "BackgroundMusic", ofType: "wav")
        {
            let url = URL(fileURLWithPath: fileString)
            do {
                try audioFile = AVAudioFile(forReading: url)
                print("done")
            }
            catch{
                
            }
        }
    }
    
    func playSoundIfNeeded()
    {
        if ArchiveManager.shouldPlaySound
        {
            audioPlayerNode.play()
            self.scene?.audioEngine.mainMixerNode.outputVolume = 0.8
        }
        else
        {
            audioPlayerNode.pause()
            self.scene?.audioEngine.mainMixerNode.outputVolume = 0.0
        }
    }
    
    func changeVolumeTo(value: Float ,duration: TimeInterval)
    {
        if ArchiveManager.shouldPlaySound
        {
            self.scene?.audioEngine.mainMixerNode.outputVolume = value
        }
    }
}
