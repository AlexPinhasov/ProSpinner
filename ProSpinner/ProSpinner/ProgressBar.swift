//
//  ProgressBar.swift
//  ProSpinner
//
//  Created by AlexP on 12.6.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit

struct ProgressBarShape
{
    let progressBarName   : String
    let alignment         : ProgressBarAlignment
    let progressBarWidth  : Int
    let progressBarHeight : Int
    let color             : UIColor
    let anchorPointX      : Int
    let anchorPointY      : Int
    let cornerRadius      : CGFloat
}

enum ProgressBarAlignment
{
    case horizontal
    case vertical
}

class ProgressBar: SKNode
{
    private var cropNode                = SKCropNode()
    private var progressBarWidth        = 60
    private var progressBarHeight       = 4
    private var progtessBarColor        = UIColor()
    
    private var alignment : ProgressBarAlignment = .horizontal
    
    private var anchorPointX            = -38
    private var anchorPointY            = -2
    
    private var cornerRadius : CGFloat  = 2
    
    init(progressBarShape: ProgressBarShape,incramentValue: Int, totalValue: Int)
    {
        super.init()
        cropNode.zPosition = 4
        cropNode.position =  CGPoint.zero
        cropNode.xScale = 0
        
        cropNode.name = progressBarShape.progressBarName
        progressBarWidth = progressBarShape.progressBarWidth
        progressBarHeight = progressBarShape.progressBarHeight
        progtessBarColor = progressBarShape.color
        alignment = progressBarShape.alignment
        anchorPointX = progressBarShape.anchorPointX
        anchorPointY = progressBarShape.anchorPointY
        cornerRadius = progressBarShape.cornerRadius
        
        switch alignment
        {
        case .horizontal:
            cropNode.xScale = 0.0
            cropNode.yScale = 1.0
        case .vertical:
            cropNode.xScale = 1.0
            cropNode.yScale = 0.0
        }

        addFadeBackgroundToProgressBar(withColor: progtessBarColor)
        addActualProgressBarOverlay(with: incramentValue, and: totalValue)
        addSecondMaskToHideTheLeftSideOfProgressBar()
        self.addChild(cropNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animateProgressBar()
    {
        switch alignment
        {
        case .horizontal:
            cropNode.run(SKAction.scaleX(to: 1, duration: 0.3))
        case .vertical:
            cropNode.run(SKAction.scaleY(to: 1, duration: 0.3))
        }
    }

    private func addFadeBackgroundToProgressBar(withColor color: UIColor)
    {
        let cropBackgroundNode = SKCropNode()
        cropBackgroundNode.zPosition = 2
        
        let backgroundMask = SKShapeNode(rect: CGRect(x: 0, y: 0, width: progressBarWidth, height: progressBarHeight),cornerRadius: cornerRadius)
        backgroundMask.fillColor = color
        backgroundMask.strokeColor = .clear
        backgroundMask.zPosition = 2
        cropBackgroundNode.position = CGPoint.zero
        cropBackgroundNode.maskNode = backgroundMask
        backgroundMask.alpha = 0.3
        self.addChild(cropBackgroundNode)
    }
    
    func addActualProgressBarOverlay(with incramentValue: Int, and totalValue: Int)
    {
        if cropNode.maskNode != nil
        {
            cropNode.maskNode = nil
        }
        
        let incrementBy = calculatePorportionalWidthToBar(with: incramentValue, and: totalValue)
        
        var mask = SKShapeNode()
        
        switch alignment
        {
        case .horizontal:
            mask = SKShapeNode(rect: CGRect(x: 0,
                                            y: 0,
                                            width: Int(incrementBy),
                                            height: progressBarHeight),
                                            cornerRadius: cornerRadius)
        case .vertical:
            mask = SKShapeNode(rect: CGRect(x: 0,
                                            y: 0,
                                            width: progressBarWidth,
                                            height: Int(incrementBy)),
                                            cornerRadius: cornerRadius)
        }
        
        mask.strokeColor    = .clear
        mask.fillColor      = progtessBarColor
        mask.zPosition      = 3
        cropNode.maskNode = mask
    }
    
    private func addSecondMaskToHideTheLeftSideOfProgressBar()
    {
        let cropBackgroundNode = SKCropNode()
        cropBackgroundNode.zPosition = 2
        
        let backgroundMask = SKShapeNode(rect: CGRect(x: anchorPointX, y: anchorPointY, width: progressBarWidth, height: progressBarHeight),cornerRadius: cornerRadius)
        backgroundMask.fillColor = .clear
        backgroundMask.strokeColor = .clear
        backgroundMask.zPosition = 2
        cropBackgroundNode.maskNode = backgroundMask
        self.addChild(cropBackgroundNode)
    }

    private func calculatePorportionalWidthToBar(with incramentValue: Int,and totalValue: Int) -> Double
    {
        let percentFromTotalValue: CGFloat = CGFloat(incramentValue) / CGFloat(totalValue)
        
        switch alignment
        {
        case .horizontal:
            return Double(percentFromTotalValue * CGFloat(progressBarWidth) > CGFloat(progressBarWidth) ? CGFloat(progressBarWidth) : percentFromTotalValue * CGFloat(progressBarWidth))
        case .vertical:
            return Double(percentFromTotalValue * CGFloat(progressBarHeight) > CGFloat(progressBarHeight) ? CGFloat(progressBarHeight) : percentFromTotalValue * CGFloat(progressBarHeight))
        }
    }
}
