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
        audioPlayerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)

        let audioFileBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: UInt32(audioFile.length))
        try? audioFile.read(into: audioFileBuffer, frameCount: UInt32(audioFile.length))
        audioPlayerNode.scheduleBuffer(audioFileBuffer, at: nil, options: .loops, completionHandler: nil)
       
        engine.connect(audioPlayerNode, to: engine.mainMixerNode, format: audioFileBuffer.format)
        do
        {
            try engine.start()
        }
        catch(let error)
        {
            log.debug(error)
        }
    }
    
    func setUpSoundEngine()
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
        configureSound()
        playSoundIfNeeded()
    }
    
    func playSoundIfNeeded()
    {
        if ArchiveManager.shouldPlaySound
        {
            self.scene?.audioEngine.mainMixerNode.outputVolume = 0.8

            audioPlayerNode.play()
           
        }
        else if audioPlayerNode.isPlaying
        {
            self.scene?.audioEngine.mainMixerNode.outputVolume = 0.0
            audioPlayerNode.pause()
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
