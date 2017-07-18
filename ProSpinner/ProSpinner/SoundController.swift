//
//  SoundController.swift
//  ProSpinner
//
//  Created by AlexP on 18.7.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import AVFoundation

class SoundController
{
    static var engine               = AVAudioEngine()
    static var audioFile            = AVAudioFile()
    static var audioPlayerNode      = AVAudioPlayerNode()
    static var changeAudioUnitTime  = AVAudioUnitTimePitch()
    
    static func configureSound()
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
    
    static func setUpSoundEngine()
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
    
    static func playSoundIfNeeded()
    {
        if ArchiveManager.shouldPlaySound
        {
            audioPlayerNode.play()
            
        }
        else if audioPlayerNode.isPlaying
        {
            audioPlayerNode.pause()
        }
    }
    
    static func stopMusic()
    {
        audioPlayerNode.pause()
    }
}
