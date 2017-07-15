//
//  FirstInstallSpinners.swift
//  ProSpinner
//
//  Created by AlexP on 13.7.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit

struct FirstInstallSpinners
{
    static func getSpinnersArray() -> [Spinner]
    {
        UserDefaults.standard.set(nil, forKey: "Spinners")
        UserDefaults.standard.set(0  , forKey: UserDefaultKeys.highScore.rawValue)
        
        var spinnerArray = [Spinner]()
        
        //More Coming
        spinnerArray.append(Spinner(id: ArchiveManager.comingMoreSpinnerId, unlocked: true, redNeeded: 0, blueNeeded: 0, greenNeeded: 0))
        
        
        spinnerArray.append( Spinner(id: 1,
                                imageUrlLink: "gs://prospinner-a4255.appspot.com/SpinnersTextures/1/spinner.png",
                                texture: SKTexture(imageNamed: "blackSpinner"),
                                redNeeded: 10,
                                blueNeeded: 10,
                                greenNeeded: 10,
                                mainSpinner: true,
                                unlocked: true)
                            )
    
        // Metal texture
        spinnerArray.append(Spinner(id: 2, redNeeded: 10, blueNeeded: 30, greenNeeded: 30))
        // Triangle
        spinnerArray.append(Spinner(id: 3, redNeeded: 100, blueNeeded: 20, greenNeeded: 12))
        // Red
        spinnerArray.append(Spinner(id: 4, redNeeded: 100, blueNeeded: 50, greenNeeded: 50))
        // Blade
        spinnerArray.append(Spinner(id: 5, redNeeded: 250, blueNeeded: 250, greenNeeded: 250))
        //Flower
        spinnerArray.append(Spinner(id: 6, redNeeded: 150, blueNeeded: 150, greenNeeded: 150))
        //Cosmos
        spinnerArray.append(Spinner(id: 7, redNeeded: 200, blueNeeded: 300, greenNeeded: 255))
        //Dragons
        //spinnerArray.append(Spinner(id: 8, redNeeded: 1500, blueNeeded: 1500, greenNeeded: 1500))
        
        return spinnerArray
    }
}
