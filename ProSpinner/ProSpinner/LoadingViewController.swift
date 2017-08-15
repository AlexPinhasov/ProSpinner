//
//  LoadingViewController.swift
//  ProSpinner
//
//  Created by Alex Pinhasov on 11/07/2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import UIKit
import SpriteKit

class LoadingViewController: UIViewController,Animateable
{
    @IBOutlet weak var spinnerImage: UIImageView!
    private var nextScene      : GameScene?
    private var timer          : Timer?
    private var textures       : [SKTexture]?
    
    override func viewDidLoad()
    {
        log.debug("")
        super.viewDidLoad()
        log.debug()
        setSpinnerInArrayOnFirstRun()
        spinnerImage.image = getMainSpinnerTexture()
        getTexturesToLoad()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        log.debug("")
        super.viewDidAppear(animated)
        rotateAnimation(imageView: spinnerImage, duration: 1.5)
    }
    
    func stopSpinnerRotation()
    {
        log.debug("")
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
        log.debug("")
        let backgroundQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated)
        backgroundQueue.async(execute:
            {
                log.debug()
                let spinnerArray = ArchiveManager.spinnersArrayInDisk
                self.checkForCorruptedSpinnersObjects(inArray : spinnerArray)
                self.loadNextScene()
                self.loadSounds()
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
                
                self.textures?.append(SKTexture(imageNamed: "PlayPath"))
                self.textures?.append(SKTexture(imageNamed: "NewPlayButton"))
                self.textures?.append(SKTexture(imageNamed: "NewStoreButton"))
                self.textures?.append(SKTexture(imageNamed: "LockMech"))
                self.textures?.append(SKTexture(imageNamed: "RightHez"))
                self.textures?.append(SKTexture(imageNamed: "LeftHez"))
                
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
        timer?.invalidate()
        textures?.removeAll()
        timer = nil
        textures = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        log.debug("")
        // get a reference to the second view controller
        if let secondViewController = segue.destination as? GameViewController
        {
            secondViewController.nextScene = nextScene
            secondViewController.loadingViewController = self
        }
        
    }
    
    func loadSounds()
    {
        _ = SoundLibrary.CollectedDiamond
        _ = SoundLibrary.blopSound
        _ = SoundLibrary.spinnerChangedDirection
        _ = SoundLibrary.spinnerUnlocked
        _ = SoundLibrary.AlertSound
        _ = SoundLibrary.Error
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
            scene.sideMenuView      = scene.childNode(withName: Constants.NodesInSideMenu.SideMenu.rawValue) as? SideMenuView
            scene.scoreboardView    = scene.childNode(withName: Constants.NodesInSideMenu.scoreboardNode.rawValue) as? SideMenuScoreboardView
            scene.gameModeView      = scene.childNode(withName: Constants.NodesInGameModeNode.GameModeNode.rawValue) as? GameModeView
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
            ArchiveManager.shouldPlaySound = true
            ArchiveManager.gameExplantionDidShow = false
            ArchiveManager.mainSpinnerLocation = 1
            ArchiveManager.write_SpinnerToUserDefault(spinners: FirstInstallSpinners.getSpinnersArray())
            setDiamondsOnFirstRun()
        }
    }
    
    private func setDiamondsOnFirstRun()
    {
        log.debug()
        UserDefaults.standard.set(0, forKey: UserDefaultKeys.red.rawValue)
        UserDefaults.standard.set(0, forKey: UserDefaultKeys.blue.rawValue)
        UserDefaults.standard.set(0, forKey: UserDefaultKeys.green.rawValue)
    }
    
}
