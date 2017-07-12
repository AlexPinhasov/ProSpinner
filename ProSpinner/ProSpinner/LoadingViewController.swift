//
//  LoadingViewController.swift
//  ProSpinner
//
//  Created by Alex Pinhasov on 11/07/2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import UIKit
import SpriteKit

class LoadingViewController: UIViewController
{
    @IBOutlet weak var spinnerImage: UIImageView!
    private var nextScene      : GameScene?
    private var timer          : Timer?
    private var textures       : [SKTexture]?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        log.debug()
        setSpinnerInArrayOnFirstRun()
        spinnerImage.image = getMainSpinnerTexture()
        getTexturesToLoad()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        rotateAnimation(imageView: spinnerImage, duration: 1.5)
    }
    
    func rotateAnimation(imageView:UIImageView,duration: CFTimeInterval = 2.0)
    {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(.pi * 2.0)
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount = Float.greatestFiniteMagnitude;
        
        imageView.layer.add(rotateAnimation, forKey: "rotateSpinner")
    }
    
    func stopSpinnerRotation()
    {
        spinnerImage.layer.removeAnimation(forKey: "rotateSpinner")
    }
    
    func getMainSpinnerTexture() -> UIImage?
    {
        log.debug()
        _ = ArchiveManager.read_SpinnersFromUserDefault()
                
        let mainSpinner = ArchiveManager.spinnersArrayInDisk[ArchiveManager.mainSpinnerLocation]
        
        if let cgSpinnerImage = mainSpinner.texture?.cgImage()
        {
            return UIImage(cgImage: cgSpinnerImage)
        }
        return nil
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
            self.performSegue(withIdentifier: "showScene", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // get a reference to the second view controller
        if let secondViewController = segue.destination as? GameViewController
        {
            secondViewController.nextScene = nextScene
            secondViewController.loadingViewController = self
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

    private func setSpinnerInArrayOnFirstRun()
    {
        log.debug()
        if ArchiveManager.firstTimeRun == false
        {
            ArchiveManager.firstTimeRun = true
            UserDefaults.standard.set(nil, forKey: "Spinners")
            UserDefaults.standard.set(0  , forKey: UserDefaultKeys.highScore.rawValue)
            
            let spinner = Spinner(id: 1,
                                  imageUrlLink: "",
                                  texture: SKTexture(imageNamed: "blackSpinner") ,
                                  redNeeded: 10,
                                  blueNeeded: 10,
                                  greenNeeded: 10,
                                  mainSpinner: true,
                                  unlocked: true)
            
            ArchiveManager.write_SpinnerToUserDefault(spinners: [spinner])
            set10DiamondsOnFirstRun()
        }
    }
    
    private func set10DiamondsOnFirstRun()
    {
        log.debug()
        UserDefaults.standard.set(0, forKey: UserDefaultKeys.red.rawValue)
        UserDefaults.standard.set(0, forKey: UserDefaultKeys.blue.rawValue)
        UserDefaults.standard.set(0, forKey: UserDefaultKeys.green.rawValue)
    }
    
}
