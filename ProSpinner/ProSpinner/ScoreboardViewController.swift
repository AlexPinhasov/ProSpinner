//
//  ScoreboardViewController.swift
//  ProSpinner
//
//  Created by Alex Pinhasov on 31/07/2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import UIKit

class ScoreboardViewController: UIViewController,BaseAsyncProtocol
{
    var scoreboardDelegateDataSourceController : ScoreboardDelegateDataSourceController!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scoreTableView: UITableView!
    
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
