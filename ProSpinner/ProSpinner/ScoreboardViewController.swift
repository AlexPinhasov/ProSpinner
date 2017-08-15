//
//  ScoreboardViewController.swift
//  ProSpinner
//
//  Created by Alex Pinhasov on 31/07/2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import UIKit
import FirebaseAuth
class ScoreboardViewController: UIViewController,BaseAsyncProtocol
{
    var scoreboardDelegateDataSourceController : ScoreboardDelegateDataSourceController!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scoreTableView: UITableView!
    
    @IBOutlet weak var facebookView: UIView!
    @IBOutlet weak var facebookButtonView: UIView!
    @IBOutlet weak var facebookViewHighetConstraint: NSLayoutConstraint!
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        loadingIndicator.startAnimating()
        scoreboardDelegateDataSourceController = ScoreboardDelegateDataSourceController(delegate: self)
        scoreTableView.delegate = scoreboardDelegateDataSourceController
        scoreTableView.dataSource = scoreboardDelegateDataSourceController
        fetchData()
        facebookView.isHidden = true
        facebookViewHighetConstraint.constant = 0
       // try? Auth.auth().signOut()
        guard currentUser == nil else { return }
        
        facebookView.isHidden = false
        facebookViewHighetConstraint.constant = 119
        let fb = FacebookManager(frame: facebookButtonView.frame)

        fb.scoreboardViewController = self
        facebookButtonView.addSubview(fb)
        fb.frame.origin.y = 0
        fb.frame.origin.x = 0
        print(fb)
    }
    
    func userLoggedIn()
    {
        facebookView.isHidden = true
        loadingIndicator.isHidden = true
        loadingIndicator.stopAnimating()
        facebookViewHighetConstraint.constant = 0
        scoreboardDelegateDataSourceController.fetchData()
        Diamond.redCounter += 100
        Diamond.blueCounter += 100
        Diamond.greenCounter += 100
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.reloadLockedViewAfterPurchase.rawValue), object: nil)
    }
    
    func tappedFacebookButton()
    {
        loadingIndicator.startAnimating()
        loadingIndicator.isHidden = false
    }
    
    func canceledFacebookLogin()
    {
        loadingIndicator.stopAnimating()
        loadingIndicator.isHidden = true
    }
    
    func fetchData()
    {
        scoreboardDelegateDataSourceController.fetchData()
    }
    
    func didSuccess()
    {
        loadingIndicator.stopAnimating()
        scoreTableView.reloadData()
    }
    
    @IBAction func userTappedClose(_ sender: UIBarButtonItem)
    {
        self.dismiss(animated: true, completion: nil)
    }
}
