//
//  ProgressBar.swift
//  ProSpinner
//
//  Created by AlexP on 12.6.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit

class ProgressBar: SKNode
{
    private var cropNode = SKCropNode()
    private var progressBarWidth = 60
    private var progressBarHeight = 4
    
    private let anchorPointX = -38
    private let anchorPointY = -2
    
    init(newName: String,diamondsNeeded: Int, diamondPossesed: Int)
    {
        super.init()
        cropNode.zPosition = 4
        cropNode.name = newName
        cropNode.position =  CGPoint.zero
        cropNode.xScale = 0
        
        addFadeBackgroundToProgressBar(withColor: getMaskColor(for: newName))
        addActualProgressBarOverlay(name: newName,with: diamondPossesed, and: diamondsNeeded)
        addSecondMaskToHideTheLeftSideOfProgressBar()
        self.addChild(cropNode)
    }
    
    func animateProgressBar()
    {
        cropNode.run(SKAction.scaleX(to: 1, duration: 0.3))
    }

    private func addFadeBackgroundToProgressBar(withColor color: UIColor)
    {
        let cropBackgroundNode = SKCropNode()
        cropBackgroundNode.zPosition = 2
        
        let backgroundMask = SKShapeNode(rect: CGRect(x: 0, y: 0, width: progressBarWidth, height: progressBarHeight))
        backgroundMask.fillColor = color
        backgroundMask.strokeColor = .clear
        backgroundMask.zPosition = 2
        cropBackgroundNode.position = CGPoint.zero
        cropBackgroundNode.maskNode = backgroundMask
        backgroundMask.alpha = 0.3
        self.addChild(cropBackgroundNode)
    }
    
    private func addActualProgressBarOverlay(name newName: String,with diamondPossesed: Int, and diamondsNeeded: Int)
    {
        let barWidth = calculatePorportionalWidthToBar(with: diamondPossesed, and: diamondsNeeded)
        
        let mask = SKShapeNode(rect: CGRect(x: 0,
                                            y: 0,
                                            width: Int(barWidth),
                                            height: progressBarHeight))
        
        mask.strokeColor    = .clear
        mask.fillColor      = getMaskColor(for: newName)
        mask.zPosition      = 3
        cropNode.maskNode = mask
    }
    
    private func addSecondMaskToHideTheLeftSideOfProgressBar()
    {
        let cropBackgroundNode = SKCropNode()
        cropBackgroundNode.zPosition = 2
        
        let backgroundMask = SKShapeNode(rect: CGRect(x: anchorPointX, y: anchorPointY, width: progressBarWidth, height: progressBarHeight))
        backgroundMask.fillColor = .clear
        backgroundMask.strokeColor = .clear
        backgroundMask.zPosition = 2
        cropBackgroundNode.maskNode = backgroundMask
        self.addChild(cropBackgroundNode)
    }

    private func calculatePorportionalWidthToBar(with diamondPossesed: Int,and diamondsNeeded: Int) -> Double
    {
        let percentFromNeededDiamonds: CGFloat = CGFloat(diamondPossesed) / CGFloat(diamondsNeeded)
        return Double(percentFromNeededDiamonds * CGFloat(progressBarWidth) > CGFloat(progressBarWidth) ? CGFloat(progressBarWidth) : percentFromNeededDiamonds * CGFloat(progressBarWidth))
    }
    
    private func getMaskColor(for newName: String) -> UIColor
    {
        switch newName
        {
        case Constants.ProgressBars.red.rawValue:
            return Constants.DiamondProgressBarColor.redColor
            
        case Constants.ProgressBars.blue.rawValue:
            return Constants.DiamondProgressBarColor.blueColor
            
        case Constants.ProgressBars.green.rawValue:
            return Constants.DiamondProgressBarColor.greenColor
            
        default: break
        }
        return .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
