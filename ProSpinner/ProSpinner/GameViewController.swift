//
//  GameViewController.swift
//  ProSpinner
//
//  Created by Alex Pinhasov on 15/05/2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GoogleMobileAds
import JSSAlertView

enum NotificationName: String
{
    case removeDownloadView = "removeDownloadView"
    case notifyWithNewTexture = "notifyWithNewTexture"
    case reloadLockedViewAfterPurchase = "reloadLockedViewAfterPurchase"
}

class GameViewController: UIViewController
{
    var downloadView: JSSAlertViewResponder?
    var admobManager : AdMobManager?
    var nextScene : SKScene?
//  MARK: View's Life cycle
    override func viewDidLoad()
    {
        log.debug()
        super.viewDidLoad()
        setSpinnerInArrayOnFirstRun()
        loadScene()
        loadingScreenDidFinish()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
//  MARK: Private methods
    func loadingScreenDidFinish()
    {
        log.debug()
        PurchaseManager.rootViewController = self
        admobManager = AdMobManager(rootViewController: self)
        checkForNewSpinners()
    }
    
    private func checkForNewSpinners()
    {
        NetworkManager.checkForNewSpinners()
            { foundNewSpinners in
                
                if foundNewSpinners
                {
                    let customIcon = UIImage(named: "downloadAlertLogo")
                    let alertview = JSSAlertView().show(
                        self,
                        title: "New Spinners Available !",
                        text: "",
                        buttonText: "Download",
                        cancelButtonText: "Cancel",
                        color: UIColor(red: 69/255, green: 175/255, blue: 224/255, alpha: 1.0),
                        iconImage: customIcon)
                    
                    alertview.setTextTheme(.light)
                    alertview.addAction(self.beginDownload)
                    alertview.addCancelAction {}
                }
        }
    }
    
    private func loadScene()
    {
        log.debug()
        if let sceneNode = nextScene
        {
            sceneNode.scaleMode = .aspectFill
            // Present the scene
            if let view = self.view as? SKView
            {
                view.presentScene(sceneNode)
                view.ignoresSiblingOrder = true
                view.showsFPS = true
                view.showsNodeCount = true
            }
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
        UserDefaults.standard.set(50, forKey: UserDefaultKeys.red.rawValue)
        UserDefaults.standard.set(50, forKey: UserDefaultKeys.blue.rawValue)
        UserDefaults.standard.set(50, forKey: UserDefaultKeys.green.rawValue)
    }
    
    func beginDownload()
    {
        log.debug()
        NetworkManager.handleNewSpinnersAvailable()

        if let downloadViewController = storyboard?.instantiateViewController(withIdentifier: "DownloadingViewController")
        {
            self.present(downloadViewController, animated: true, completion: nil)
        }
    }
}
