//
//  FixedSpinnerColorDropController.swift
//  ProSpinner
//
//  Created by AlexP on 29.7.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit

class FixedSpinnerColorDropController: BaseGameMode,
                                      GameMode
{
    private var lastRandomDiamond : UInt32 = 1
    override func configureDiamonds()
    {
        log.debug("")
        Diamond.diamondSpeed = 5.0
        timeInterval = 1.0
        super.configureDiamonds()
    }
    
    override func spawnDiamonds()
    {
        log.debug("")
        guard let scene = scene else { return }
        let nextDiamond = randomizeDiamondType()
        
        switch GameStatus.Playing
        {
        case true:
            nextDiamond.position = CGPoint(x: nextXLocation, y: scene.frame.height)
            nextDiamond.zPosition = 5
            scene.addChild(nextDiamond)
            nextXLocation = calculateXLocation()
            
        case false: nextDiamond.removeAllActions()
        }
        
        let diamondSpeed = Diamond.diamondSpeed
        
        if diamondSpeed >= 4.0 && diamondSpeed <= 4.05 // collected 15 diamonds
        {
            timeInterval = 0.85
            timer?.invalidate()
            reSchdeuleTimer()
        }
        else  if diamondSpeed >= 3.0 && diamondSpeed <= 3.05 // collected 50 diamonds
        {
            timeInterval = 0.75
            timer?.invalidate()
            reSchdeuleTimer()
        }
        else  if diamondSpeed >= 2.0 && diamondSpeed <= 2.05 // collected 100 diamonds
        {
            timeInterval = 0.6
            timer?.invalidate()
            reSchdeuleTimer()
        }
    }
    
    override func randomizeDiamondType() -> Diamond
    {
        log.debug("")
        var random = arc4random_uniform(3)+1
        
        if lastRandomDiamond == random
        {
            if random + 1 > 3
            {
                random = 1
            }
            else
            {
                random += 1
            }
            lastRandomDiamond = random
        }
        
        switch random
        {
        case Constants.DiamondIntColor.Blue.rawValue     : return blueDiamond()
        case Constants.DiamondIntColor.Red.rawValue      : return redDiamond()
        case Constants.DiamondIntColor.Green.rawValue    : return greenDiamond()
        default                             : break
        }
        return blueDiamond()
    }
    
    override func resetDiamondsTimer()
    {
        log.debug("")
        Diamond.diamondSpeed = 4.5
        timeInterval = 1.0
        timer?.invalidate()
    }
    
    override func updateDiamondSpeed()
    {
        if Diamond.diamondSpeed <= 1.85
        {
            Diamond.diamondSpeed = 1.85
        }
        else
        {
            Diamond.diamondSpeed -= 0.05
            Diamond.diamondRotationSpeed -= 0.02
        }
    }
    
    override func calculateXLocation() -> CGFloat
    {
        log.debug("")
        return 160
    }
}
