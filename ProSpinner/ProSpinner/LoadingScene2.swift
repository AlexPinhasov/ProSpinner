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
    var spinnerInScene : SKSpriteNode?
    var timer          : Timer?
    
    override func didMove(to view: SKView)
    {
        spinnerInScene = self.childNode(withName: "spinner") as? SKSpriteNode
        rotateSpinner()
        getTexturesToLoad()
    }
    
    func rotateSpinner()
    {
        let rotateLeftAngle = -(CGFloat.pi * 2)
        let rotateAction = SKAction.rotate(byAngle: rotateLeftAngle, duration: 2)
        spinnerInScene?.run(SKAction.repeatForever(rotateAction))
    }


    func getTexturesToLoad()
    {
        let spinnerArray = ArchiveManager.read_SpinnersFromUserDefault()
        
        var textures = spinnerArray.map({ (spinner) -> SKTexture in
            
            if let texture = spinner.texture
            {
                return texture
            }
            return SKTexture()
        })
        
        textures.append(Constants.DiamondsTexture.red)
        textures.append(Constants.DiamondsTexture.blue)
        textures.append(Constants.DiamondsTexture.green)
        textures.append(SKTexture(imageNamed: "RightEar"))
        textures.append(SKTexture(imageNamed: "LeftEar"))
        textures.append(SKTexture(imageNamed: "PlayPath"))
        textures.append(SKTexture(imageNamed: "LockMech"))
        
        SKTexture.preload(textures)
        {
            self.timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.presentNextScene), userInfo: nil, repeats: false)
        }
    }
    
    @objc func presentNextScene()
    {
        print("")
        DispatchQueue.main.async
            {
                if let nextScene = SKScene(fileNamed: "GameScene")
                {
                    nextScene.scaleMode = .aspectFill
                    NotificationCenter.default.post(name: NSNotification.Name(NotifictionKey.loadingFinish.rawValue), object: nil)
                    self.scene?.view?.presentScene(nextScene, transition: SKTransition.push(with: .up, duration: 1))
                }
        }
    }
}
