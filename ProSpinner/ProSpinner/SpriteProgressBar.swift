//
//  SpriteProgressBar.swift
//  ProSpinner
//
//  Created by AlexP on 25.7.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit

enum ProgressInProgressBar: Int
{
    case start     = -250
    case qurter    = -220
    case midPoint  = -180
    case topQurter = -120
    case king      = 0
}

class SpriteProgressBar: SKNode
{
    private var cropNode              = SKCropNode()
    private var progressBarYPosition  = -250
    private var backgroundMask        : SKSpriteNode!
    var delegate                      : ProgressBarProtocol?
    
    override init()
    {
        super.init()
        addFadeBackgroundToProgressBar()
        addActualProgressBarOverlay()
        self.addChild(cropNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addFadeBackgroundToProgressBar()
    {
        backgroundMask = SKSpriteNode(imageNamed: "SpeedProgressBarBack")
        backgroundMask.size = CGSize(width: 20, height: 250)
        backgroundMask.color = .white
        backgroundMask.zPosition = 1
        self.addChild(backgroundMask)
    }
    
    func addActualProgressBarOverlay()
    {
        if cropNode.maskNode != nil
        {
            cropNode.maskNode = nil
            progressBarYPosition += 1
            sendDelegateOfPosition()
        }

        let progressBar = SKSpriteNode(imageNamed: "SpeedProgressBar")
        progressBar.size = CGSize(width: 20, height: 250)
        progressBar.color = .white
        progressBar.zPosition = 2
        
        let mask = SKSpriteNode(color: .black, size: CGSize(width: 20, height: 250))
        mask.color = .white
        mask.zPosition      = 3
        mask.position = CGPoint(x: 0, y: progressBarYPosition)
        cropNode.addChild(progressBar)
        cropNode.maskNode = mask
        cropNode.zPosition = 2
    }
    
    func sendDelegateOfPosition()
    {
        switch progressBarYPosition
        {
        case ProgressInProgressBar.start.rawValue     : delegate?.didUpdateProgressBar(inPosition: .start)
        case ProgressInProgressBar.qurter.rawValue    : delegate?.didUpdateProgressBar(inPosition: .qurter)
        case ProgressInProgressBar.midPoint.rawValue  : delegate?.didUpdateProgressBar(inPosition: .midPoint)
        case ProgressInProgressBar.topQurter.rawValue : delegate?.didUpdateProgressBar(inPosition: .topQurter)
        case ProgressInProgressBar.king.rawValue      : delegate?.didUpdateProgressBar(inPosition: .king)
        default: break
        }
    }
}
