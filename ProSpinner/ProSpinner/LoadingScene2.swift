//
//  LoadingScene2.swift
//  ProSpinner
//
//  Created by AlexP on 2.7.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import SpriteKit

class LoadingScene2: SKScene
{
    private var nextScene      : GameScene?
    var spinnerInScene : SKSpriteNode?
    private var timer          : Timer?
    private var textures       : [SKTexture]?
    
    override func didMove(to view: SKView)
    {
        log.debug()
        rotateSpinner()
        getTexturesToLoad()
    }
    
    func getMainSpinnerTexture() -> SKTexture?
    {
        log.debug()
        _ = ArchiveManager.read_SpinnersFromUserDefault()
        let mainSpinner = ArchiveManager.spinnersArrayInDisk[ArchiveManager.mainSpinnerLocation]
        return mainSpinner.texture
    }
    
    func rotateSpinner()
    {
        log.debug()
        let rotateLeftAngle = -(CGFloat.pi * 2)
        let rotateAction = SKAction.rotate(byAngle: rotateLeftAngle, duration: 2)
        spinnerInScene?.run(SKAction.repeatForever(rotateAction))
    }

    func getTexturesToLoad()
    {
        let backgroundQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated)
        backgroundQueue.async(execute:
        {
            log.debug()
            let spinnerArray = ArchiveManager.spinnersArrayInDisk
            self.checkForCorruptedSpinnersObjects(inArray : spinnerArray)
            self.loadNextScene()
            self.textures = spinnerArray.map({ (spinner) -> SKTexture in
                
                if let texture = spinner.texture
                {
                    return texture
                }
                return SKTexture()
            })
            
            self.textures?.append(Constants.DiamondsTexture.red)
            self.textures?.append(Constants.DiamondsTexture.blue)
            self.textures?.append(Constants.DiamondsTexture.green)
            self.textures?.append(Constants.DiamondsCleanTexture.red)
            self.textures?.append(Constants.DiamondsCleanTexture.blue)
            self.textures?.append(Constants.DiamondsCleanTexture.green)

            self.textures?.append(SKTexture(imageNamed: "RightEar"))
            self.textures?.append(SKTexture(imageNamed: "LeftEar"))
            self.textures?.append(SKTexture(imageNamed: "PlayPath"))
            self.textures?.append(SKTexture(imageNamed: "NewPlayButton"))
            self.textures?.append(SKTexture(imageNamed: "NewStoreButton"))
            self.textures?.append(SKTexture(imageNamed: "LockMech"))
            self.textures?.append(SKTexture(imageNamed: "RightHez"))
            self.textures?.append(SKTexture(imageNamed: "LeftRHez"))
            
            DispatchQueue.main.async
            {
                self.timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.preloadTextures), userInfo: nil, repeats: false)
            }
        })
    }
    
    func checkForCorruptedSpinnersObjects(inArray spinnersArray: [Spinner])
    {
        log.debug()
        for (index,spinner) in spinnersArray.enumerated()
        {
            if spinner.texture == nil
            {
                NetworkManager.requestCoruptedSpinnerData(forIndex: index)
            }
        }
    }
    
    func preloadTextures()
    {
        log.debug()
        guard let textures = textures else { presentNextScene() ; return }
        SKTexture.preload(textures)
        {
            self.presentNextScene()
        }
    }
    
    @objc func presentNextScene()
    {
        log.debug()
        DispatchQueue.main.async
        {
            guard let nextScene = self.nextScene else { return }
            nextScene.scaleMode = .aspectFill
            self.scene?.view?.presentScene(nextScene, transition: SKTransition.push(with: .left, duration: 0.7))
        }
    }
    
    @objc func loadNextScene()
    {
        log.debug()
        if let scene = GameScene(fileNamed: "GameScene")
        {
            nextScene = scene
            scene.spinnerManager    = SpinnerManager(inScene: scene)
            scene.diamondsManager   = DiamondsManager(inScene: scene)
            scene.manuManager       = ManuManager(inScene: scene)
            scene.tutorialManager   = TutorialManager(withScene: scene)
            scene.storeView         = scene.childNode(withName: Constants.NodesInStoreView.StoreView.rawValue) as? StoreView
            scene.retryView         = scene.childNode(withName: Constants.NodesInRetryView.RetryView.rawValue) as? RetryView
            scene.physicsWorld.contactDelegate = scene
            
            scene.handleSpinnerConfiguration()
            scene.handleManuConfiguration()
            scene.handleDiamondConfiguration()
        }
    }
}
