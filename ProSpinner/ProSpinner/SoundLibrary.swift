//
//  SoundLibrary.swift
//  ProSpinner
//
//  Created by Alex Pinhasov on 16/07/2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit

class SoundLibrary
{
    static let CollectedDiamond         = SKAction.playSoundFileNamed("CollectedDiamond.wav"    , waitForCompletion: false)
    static let blopSound                = SKAction.playSoundFileNamed("ButtonTap.wav"           , waitForCompletion: false)
    static let spinnerChangedDirection  = SKAction.playSoundFileNamed("Woosh.mp3"               , waitForCompletion: false)
    static let spinnerUnlocked          = SKAction.playSoundFileNamed("SpinnerUnlocked.wav"     , waitForCompletion: false)
    static let AlertSound               = SKAction.playSoundFileNamed("AlertSound.wav"          , waitForCompletion: false)
    static let Error                    = SKAction.playSoundFileNamed("Error.wav"               , waitForCompletion: false)
}
