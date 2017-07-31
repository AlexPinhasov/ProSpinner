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
                cell.playerName.text = scoreData.name
                cell.playerScore.text = String(scoreData.score)
                cell.rankLabel.text = String(indexPath.row + 1) + "."
                
                if scoreData.score >= 250
                {
                    cell.kingCrown.alpha = 1.0
                }
                
                if let image = UIImage(named: scoreData.imageID)
                {
                    cell.imageView?.image = image
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
