//
//  NetworkManager.swift
//  ProSpinner
//
//  Created by AlexP on 30.5.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import Foundation
import FirebaseDatabase
import SpriteKit
import FirebaseStorage
import FirebaseCore

class NetworkManager
{
    static private var numberOfImagesInDownload: Int = 0
    static private var database = Database.database().reference().database.reference()
    static var currentlyCheckingForNewSpinners = false
    
    static func checkForNewSpinners(withCompletion block: @escaping (Bool) -> Void)
    {
        NetworkManager.currentlyCheckingForNewSpinners = true
        let backgroundQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated)
        backgroundQueue.async(execute:
            {
                log.debug("")
                database.child("NumberOfSpinners").observeSingleEvent(of: .value, with:
                    { (snapshot) in
                        
                        if let newSpinnersAvailable = snapshot.value as? Int
                        {
                            block(newSpinnersAvailable > ArchiveManager.spinnersArrayInDiskCount)
                        }
                        else
                        {
                            block(false)
                        }
                })
                { (error) in
                    print(error.localizedDescription)
                    block(false)
                }
                NetworkManager.currentlyCheckingForNewSpinners = false
        })
    }
    
    static func handleNewSpinnersAvailable()
    {
        log.debug("")
        guard let status = Network.reachability?.status else { return }
        
        switch status
        {
        case .unreachable: break
        case .wifi,.wwan:
            
            getSpinnersFromDataBase()
            { (spinnerArray) in
                
                self.numberOfImagesInDownload = spinnerArray.count
                
                ArchiveManager.resetDownloadedSpinnersArray()
                ArchiveManager.currentlyDownloadedSpinnersArray.append(contentsOf: spinnerArray)

                self.handleDownloadingImagesForNewSpinners()
            }
        }
    }
    
    static func getSpinnersFromDataBase(withBlock completion: @escaping ([Spinner]) -> Void)
    {
        log.debug("")
        guard let status = Network.reachability?.status else { return }
        
        switch status
        {
        case .unreachable: break
        case .wifi,.wwan:
            
            var spinnersFound : [Spinner] = [Spinner]()
            let startingPosition = String(ArchiveManager.spinnersArrayInDiskCount + 1)
            database.child("Spinners").queryOrderedByKey().queryStarting(atValue: startingPosition).observeSingleEvent(of: .value, with:
            { (snapshot) in
                
                if let snapshotChildArray = snapshot.value as? NSArray
                {
                    let filterdSnapshot = snapshotChildArray.filter() { return $0 is NSDictionary }
                    if let filterdSnapshot = filterdSnapshot as? [NSDictionary]
                    {
                        for spinner in filterdSnapshot
                        {
                            spinnersFound.append(Spinner(id:            spinner["id"] as? Int,
                                                         imageUrlLink:  spinner["imagePath"] as? String,
                                                         texture:       nil,
                                                         redNeeded:     spinner["redNeeded"] as? Int,
                                                         blueNeeded:    spinner["blueNeeded"] as? Int,
                                                         greenNeeded:   spinner["greenNeeded"] as? Int,
                                                         mainSpinner:   false,
                                                         unlocked:      false))
                        }
                    }
                }
                else if let snapshotChildArray = snapshot.value as? NSDictionary
                {
                    var spinnerArray = [NSDictionary]()
                    
                    if let keys = snapshotChildArray.allKeys as? [String]
                    {
                        for index in 0..<keys.count
                        {
                            let key = keys[index]
                            if let spinnerDictionary = snapshotChildArray.value(forKey: key) as? NSDictionary
                            {
                                spinnerArray.append(spinnerDictionary)
                            }
                        }
                    }
                    
                    for spinner in spinnerArray
                    {
                        spinnersFound.append(Spinner(id:            spinner["id"] as? Int,
                                                     imageUrlLink:  spinner["imagePath"] as? String,
                                                     texture:       nil,
                                                     redNeeded:     spinner["redNeeded"] as? Int,
                                                     blueNeeded:    spinner["blueNeeded"] as? Int,
                                                     greenNeeded:   spinner["greenNeeded"] as? Int,
                                                     mainSpinner:   false,
                                                     unlocked:      false))
                    }
                }

                
                completion(spinnersFound)
                    
            })
            { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    static func requestCoruptedSpinnerData(forIndex index: Int)
    {
        log.debug("")
        guard let status = Network.reachability?.status else { return }
        
        switch status
        {
        case .unreachable: break
        case .wifi,.wwan:
            
            let indexInFirebase = index + 1
            database.child("Spinners").child(indexInFirebase.description).observeSingleEvent(of: .value, with:
                { (snapshot) in
                    
                    if let spinnerFix = snapshot.value as? NSDictionary
                    {
                        let imageUrlLink = spinnerFix["imagePath"] as? String
                       
                        if let imageUrl = imageUrlLink
                        {
                            downloadTexture(withUrl: imageUrl, withCompletion: { (texture) in
                                
                                let spinnerNewData =     Spinner(id:            spinnerFix["id"] as? Int,
                                                                 imageUrlLink:  imageUrlLink,
                                                                 texture:       texture,
                                                                 redNeeded:     spinnerFix["redNeeded"] as? Int,
                                                                 blueNeeded:    spinnerFix["blueNeeded"] as? Int,
                                                                 greenNeeded:   spinnerFix["greenNeeded"] as? Int,
                                                                 mainSpinner:   false,
                                                                 unlocked:      false)
                                
                                    ArchiveManager.spinnersArrayInDisk[index] = spinnerNewData
                            })
                        }
                    }
            })
            { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    static private func handleDownloadingImagesForNewSpinners()
    {
        log.debug("")
        guard let status = Network.reachability?.status else { return }
        
        switch status
        {
        case .unreachable: break
        case .wifi,.wwan:
            
            for eachSpinner in ArchiveManager.currentlyDownloadedSpinnersArray
            {
                guard let imageUrl = eachSpinner.imageUrlLink else { continue }
             
                guard imageUrl.contains("gs://") else { continue }
                
                NetworkManager.downloadTexture(withUrl: imageUrl)
                { (textureAsset) in
                    
                    eachSpinner.texture = textureAsset
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.notifyWithNewTexture.rawValue),
                                                    object: nil,
                                                    userInfo: ["spinner":textureAsset])
                    
                    numberOfImagesInDownload -= 1
                    
                    if numberOfImagesInDownload <=  0
                    {
                        ArchiveManager.spinnersArrayInDisk.append(contentsOf: ArchiveManager.currentlyDownloadedSpinnersArray)
                        ArchiveManager.sortArrayInDiskAfterUpdate()
                        ArchiveManager.write_SpinnerToUserDefault(spinners: ArchiveManager.spinnersArrayInDisk)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.removeDownloadView.rawValue), object: nil)
                    }
                }
            }
        }
    }
    
    static func downloadTexture(withUrl url: String,withCompletion block: @escaping (SKTexture) -> Void)
    {
        log.debug("")
        guard let status = Network.reachability?.status else { return }
        
        switch status
        {
        case .unreachable: break
        case .wifi,.wwan:
            
            let islandRef = Storage.storage().reference(forURL: url)
            // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
            islandRef.getData(maxSize: 1 * 1024 * 1024)
            { data, error in
                
                if let error = error
                {
                    print(error.localizedDescription)
                }
                else
                {
                    if let data = data
                    {
                        if let image = UIImage(data: data)
                        {
                            block(SKTexture(image: image))
                        }
                    }
                }
            }
        }
    }
    static var scoreDictionary = [NSDictionary]()
    
    static func getPlayersScoreboard(withBlock completion: @escaping ([ScoreData]) -> Void)
    {
        scoreDictionary.removeAll()
        
        guard let status = Network.reachability?.status else { return }
        log.debug("")
        
        switch status
        {
        case .unreachable: break
        case .wifi,.wwan:
            
            var scoresFound = [ScoreData]()
            
            database.child("HighScores").queryOrderedByKey().observeSingleEvent(of: .value, with:
            { (snapshot) in
                
                if let snapshotChildArray = snapshot.value as? NSDictionary
                {
                    // gets all scores key
                    if let keys = snapshotChildArray.allKeys as? [String]
                    {
                        for index in 0..<keys.count
                        {
                            let key = keys[index]
                            if let scoreDic = snapshotChildArray.value(forKey: key) as? NSDictionary
                            {
                                scoreDictionary.append(scoreDic)
                            }
                        }
                        
                        if shouldRegisterScore(childArray: snapshotChildArray)
                        {
                            registerMyScoreToDB()
                        }
                    }
                    
                    for dictionary in scoreDictionary
                    {
                        guard let name      = dictionary["name"]      as? String else { continue }
                        guard let score     = dictionary["score"]     as? Int    else { continue }
                        guard let spinnerID = dictionary["spinnerID"] as? String else { continue }
                        guard let userID    = dictionary["userID"]    as? String else { continue }
                        
                        var scoreToAppend = score
                        if let currentUser = currentUser
                        {
                            if score < ArchiveManager.bestScore && userID == currentUser.uid
                            {
                                scoreToAppend = ArchiveManager.bestScore
                            }
                        }
                        scoresFound.append(ScoreData(name   : name ,score  : scoreToAppend ,spinnerID: spinnerID ,userID : userID ))
                    }
                }

                scoresFound.sort(by: { return $0.score! > $1.score! })

                scoreDictionary.removeAll()
                completion(scoresFound)
            })
            { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    static func shouldRegisterScore(childArray array: NSDictionary) -> Bool
    {
        guard let currentUser = currentUser else { return false }
        
        for dbScore in scoreDictionary
        {
            if let scoreUserID   = dbScore["userID"] as? String,
               let DatabaseScore = dbScore["score"]  as? Int
            {
                if scoreUserID == currentUser.uid
                {
                    if ArchiveManager.bestScore > DatabaseScore
                    {
                        updateMyScoreOnDB()
                    }
                    return false
                }
            }
        }
        
        // at this point i know that no record of mine is at the data base or i did not beat my own score
        
        let howManyScoresLessThenMine = scoreDictionary.filter(
        {
            if let keyScore = $0["score"] as? Int
            {
                return  keyScore < ArchiveManager.bestScore
            }
            return false
        })
        
        guard howManyScoresLessThenMine.count > 0 else { return false }
        
        // at this point i know there are at least 1 score less then mine
        
        // if there are less then 50 records then register my score regradless other players score
        if scoreDictionary.count < 5
        {
            return true
        }
        removeAScoreFromDB()
        return true
    }
    
    
    static func updateMyScoreOnDB()
    {
        guard let currentUser = currentUser else { return }
        database.child("HighScores").child("\(currentUser.uid)/score").setValue(ArchiveManager.bestScore)
    }
    
    static func registerMyScoreToDB()
    {
         if let thePost = createUserData()
         {
            let score : NSDictionary = ["name"     : thePost.name!,
                                        "score"    : thePost.score!,
                                        "spinnerID": thePost.spinnerID!,
                                        "userID"   : thePost.userID! ]
            
            scoreDictionary.append(score)
            database.child("HighScores").child("\(thePost.userID!)").setValue(score)
            
        }
    }
    
    static func removeAScoreFromDB()
    {
        scoreDictionary = scoreDictionary.sorted(by: { return $1["score"] as! Int > $0["score"] as!  Int })
        if let lowestKey = scoreDictionary.first,
           let userID = lowestKey["userID"] as? String
        {
            database.child("HighScores").child(userID).removeValue()
        }
        scoreDictionary.removeFirst()
    }
    
    static private func createUserData() -> ScoreData?
    {
        var thePost : ScoreData?
        
        guard let currentUser = currentUser else { return thePost }
        guard let userName    = currentUser.displayName else { return thePost }
        guard let spinnerId   = ArchiveManager.currentSpinner.id else { return thePost }
        
        let spinnerID = String(spinnerId) == "1" ? "blackSpinner" : String(spinnerId)
        
        thePost = ScoreData(name      : userName,
                            score    : ArchiveManager.bestScore,
                            spinnerID: spinnerID,
                            userID   : currentUser.uid)
        
        return thePost
    }
}
