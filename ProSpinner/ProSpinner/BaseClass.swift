//
//  BaseClass.swift
//  ProSpinner
//
//  Created by AlexP on 29.5.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit

class BaseClass
{
    var scene: SKScene?
}

enum NotifictionKey: String
{
    case collectionViewSpinner  = "collectionViewSpinner"
    case interstitalCount       = "interstitalCount"
    case loadingFinish          = "loadingFinish"
    case checkForNewSpinners    = "checkForNewSpinners"
}
