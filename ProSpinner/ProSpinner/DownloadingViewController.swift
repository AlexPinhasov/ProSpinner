//
//  DownloadingViewController.swift
//  ProSpinner
//
//  Created by AlexP on 3.6.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import UIKit
import SpriteKit

class DownloadingViewController: UIViewController  ,Animateable
{
//  MARK: Outlets
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var successV: UIImageView!
    
    private var downloadingDelegateDataSource: DownloadingDelegateDataSource?
    
//  MARK: View lifecycle
    override func viewDidLoad()
    {
        log.debug()
        super.viewDidLoad()
        downloadingDelegateDataSource = DownloadingDelegateDataSource(collectionView: collectionView)
        collectionView.delegate = downloadingDelegateDataSource
        collectionView.dataSource = downloadingDelegateDataSource
        addObservers()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        log.debug()
        UIView.animate(withDuration: 0.2)
        {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        }
    }
    
//  MARK: Private methods
    private func addObservers()
    {
        log.debug()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(newSpinnerAvailable),
                                               name: NSNotification.Name(rawValue: NotificationName.notifyWithNewTexture.rawValue),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(removeDownloadView),
                                               name: NSNotification.Name(rawValue: NotificationName.removeDownloadView.rawValue),
                                               object: nil)
    }
    
    @objc private func newSpinnerAvailable(notification: NSNotification)
    {
        log.debug()
        if let spinnerTexture = notification.userInfo?["spinner"] as? SKTexture
        {
            downloadingDelegateDataSource?.newSpinnerAvailable(spinnerTexture: spinnerTexture)
        }
    }
    
    @objc private func removeDownloadView()
    {
        log.debug()
        indicator.stopAnimating()
        closeButton.isEnabled = true
        closeButton.setTitle("Close View", for: .normal)
        
        fadeInSuccessV()
        
        downloadingDelegateDataSource?.removeObserver()
        NotificationCenter.default.removeObserver(self)
    }
    
    private func fadeInSuccessV()
    {
        UIView.animate(withDuration: 0.5, animations: {
          self.successV.alpha = 1
            
        }, completion: { (true) in
          
            self.rotateAnimation(imageView: self.successV, repeat: 1,duration: 0.2)
            
        })
    }

    @IBAction func dismissViewController(sender: UIButton)
    {
        log.debug()
        UIView.animate(withDuration: 0.2, animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)

        }, completion: { (true) in
            self.dismiss(animated: true, completion: nil)
        })
    }
}
