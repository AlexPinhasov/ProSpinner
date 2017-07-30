//
//  GameMode.swift
//  ProSpinner
//
//  Created by AlexP on 29.7.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import UIKit

enum GameSelected
{
    case FreeSpinnerColorDrop
    case FixedSpinnerColorDrop
}

protocol GameMode
{
    func configureDiamonds()
    func reSchdeuleTimer()
    func spawnDiamonds()
    func resetDiamondsTimer()
    func randomizeDiamondType() -> Diamond
    func calculateXLocation() -> CGFloat
    func updateDiamondSpeed()
}
