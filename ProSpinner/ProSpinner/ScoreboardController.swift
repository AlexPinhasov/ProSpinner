//
//  ScoreboardController.swift
//  ProSpinner
//
//  Created by Alex Pinhasov on 31/07/2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import Foundation

protocol BaseAsyncProtocol
{
    func didSuccess()
}

class ScoreboardController
{
    var delegate: BaseAsyncProtocol?
    var playersScores : [ScoreData] = [ScoreData]()
    
    init(delegate: BaseAsyncProtocol)
    {
        self.delegate = delegate
    }
    
    func fetchData()
    {
        NetworkManager.getPlayersScoreboard()
        {   scoresArray in
            
            self.playersScores = scoresArray
            self.delegate?.didSuccess()
        }
    }
    
    func data(atIndex index: Int) -> ScoreData?
    {
        if index < playersScores.count
        {
            return playersScores[index]
        }
        return nil
    }
}
