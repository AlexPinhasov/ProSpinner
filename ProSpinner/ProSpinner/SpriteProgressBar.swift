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
    case qurter    = -230
    case midPoint  = -185
    case topQurter = -120
    case king      = -10
}

class SpriteProgressBar: SKNode
{
    private var cropNode              = SKCropNode()
    private var progressBarYPosition  = -250
    private var backgroundMask        : SKSpriteNode!
    private var spark                 : SKEmitterNode = SKEmitterNode(fileNamed: "SparkEmitter")!
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
        let progressBar = SKSpriteNode(imageNamed: "SpeedProgressBar")
        progressBar.size = CGSize(width: 20, height: 250)
        progressBar.color = .white
        progressBar.zPosition = 2
        
        spark.zPosition = 5
        spark.position = CGPoint(x: 0, y: progressBarYPosition + 125)
        self.addChild(spark)
        
        let mask = SKSpriteNode(color: .black, size: CGSize(width: 20, height: 250))
        mask.color = .white
        mask.zPosition      = 3
        mask.position = CGPoint(x: 0, y: progressBarYPosition)
        cropNode.addChild(progressBar)
        cropNode.maskNode = mask
        cropNode.zPosition = 2

    }
    
    func updateProgressBar()
    {
        progressBarYPosition += 1
        sendDelegateOfPosition()
        
        spark.position = CGPoint(x: 0, y: progressBarYPosition + 125)
        cropNode.maskNode?.position = CGPoint(x: 0, y: progressBarYPosition)
    }
    
    func sendDelegateOfPosition()
    {
        switch progressBarYPosition
        {
        case ProgressInProgressBar.start.rawValue     : delegate?.didUpdateProgressBar(inPosition: .start)
        case ProgressInProgressBar.qurter.rawValue    : delegate?.didUpdateProgressBar(inPosition: .qurter)
        case ProgressInProgressBar.midPoint.rawValue  : delegate?.didUpdateProgressBar(inPosition: .midPoint)
        case ProgressInProgressBar.topQurter.rawValue : delegate?.didUpdateProgressBar(inPosition: .topQurter)
        case ProgressInProgressBar.king.rawValue      :
            delegate?.didUpdateProgressBar(inPosition: .king)
            UserDefaults.standard.set(true, forKey: NotifictionKey.userUnlockedKingHat.rawValue)
        default: break
        }
    }
}
