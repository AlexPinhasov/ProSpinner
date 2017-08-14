//
//  ScoreboardDelegateDataSourceController.swift
//  ProSpinner
//
//  Created by Alex Pinhasov on 31/07/2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import UIKit

class ScoreboardDelegateDataSourceController: NSObject,
                                              UITableViewDelegate,
                                              UITableViewDataSource
{
    var scoreboardController : ScoreboardController!
    
    init(delegate: BaseAsyncProtocol)
    {
        scoreboardController = ScoreboardController(delegate: delegate)
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return scoreboardController.playersScores.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "scoreCell", for: indexPath) as? ScoreCell
        {
            if let scoreData = scoreboardController.data(atIndex: indexPath.row)
            {
                guard let score = scoreData.score       else { return cell }
                guard let imageId = scoreData.spinnerID   else { return cell }
                guard let userID = scoreData.userID     else { return cell }
                
                cell.playerName.text = scoreData.name
                cell.playerScore.text = String(describing: score)
                cell.rankLabel.text = String(indexPath.row + 1) + "."
                
                if let currentUser = currentUser
                {
                    if userID == currentUser.uid
                    {
                        cell.backgroundColor = UIColor(colorLiteralRed: 242/255, green: 244/255, blue: 244/255, alpha: 1.0)
                    }
                }
                
                if score >= 250
                {
                    cell.kingCrown.alpha = 1.0
                }
                
                if let image = UIImage(named: imageId)
                {
                    cell.imageView?.image = image
                }
                else
                {
                    for spinner in ArchiveManager.spinnersArrayInDisk where String(spinner.id ?? 2) == imageId
                    {
                        if let spinnerTexture = spinner.texture
                        {
                            cell.imageView?.image = UIImage(cgImage: spinnerTexture.cgImage())
                            break
                        }
                    }
                }
                
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func fetchData()
    {
        scoreboardController.fetchData()
    }

}
