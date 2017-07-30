//
//  FreeSpinnerColorDropController.swift
//  ProSpinner
//
//  Created by AlexP on 29.7.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit

class FreeSpinnerColorDropController: BaseGameMode,
                                      GameMode
{
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
        
        if diamondSpeed > 6.5 && diamondSpeed < 6.505 // collected 15 diamonds
        {
            timeInterval = 1.25
            timer?.invalidate()
            reSchdeuleTimer()
        }
        else  if diamondSpeed > 5.5 && diamondSpeed < 5.55 // collected 50 diamonds
        {
            timeInterval = 1.1
            timer?.invalidate()
            reSchdeuleTimer()
        }
        else  if diamondSpeed > 4.0 && diamondSpeed < 4.05 // collected 100 diamonds
        {
            timeInterval = 0.9
            timer?.invalidate()
            reSchdeuleTimer()
        }
        else  if diamondSpeed > 1.5 && diamondSpeed < 1.55 // collected 200+ diamonds
        {
            timeInterval = 0.8
            timer?.invalidate()
            reSchdeuleTimer()
        }
    }
    
    override func resetDiamondsTimer()
    {
        log.debug("")
        Diamond.diamondSpeed = 7.0
        timeInterval = 1.5
        timer?.invalidate()
    }

    override func calculateXLocation() -> CGFloat
    {
        log.debug("")
        let leftLocation = Diamond.diamondsXPosition - 60
        return CGFloat(arc4random_uniform(120)+UInt32(leftLocation))
    }
}
