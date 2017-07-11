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
                    block(newSpinnersAvailable > ArchiveManager.spinnersArrayInDisk.count)
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
        getSpinnersFromDataBase()
        { (spinnerArray) in
            
            self.numberOfImagesInDownload = spinnerArray.count
            
            for newSpinner in spinnerArray
            {
                ArchiveManager.spinnersArrayInDisk.append(newSpinner)
            }
            self.handleDownloadingImagesForNewSpinners()
        }
    }
    
    static func getSpinnersFromDataBase(withBlock completion: @escaping ([Spinner]) -> Void)
    {
        log.debug("")
        var spinnersFound : [Spinner] = [Spinner]()
        let startingPosition = String(ArchiveManager.spinnersArrayInDisk.count + 1)
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
                        spinnerArray.append(snapshotChildArray.value(forKey: key) as! NSDictionary)
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
    
    static func requestCoruptedSpinnerData(forIndex index: Int)
    {
        log.debug("")
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
    
    static private func handleDownloadingImagesForNewSpinners()
    {
        log.debug("")
        for eachSpinner in ArchiveManager.spinnersArrayInDisk
        {
            guard let imageUrl = eachSpinner.imageUrlLink else { continue }
         
            guard imageUrl.contains("gs://") else { continue }
            
            NetworkManager.downloadTexture(withUrl: imageUrl)
            { (textureAsset) in
                
                eachSpinner.texture = textureAsset
                ArchiveManager.write_SpinnerToUserDefault(spinners: ArchiveManager.spinnersArrayInDisk)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.notifyWithNewTexture.rawValue),
                                                object: nil,
                                                userInfo: ["spinner":textureAsset])
                
                numberOfImagesInDownload -= 1
                
                if numberOfImagesInDownload <=  0
                {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.removeDownloadView.rawValue), object: nil)
                }
            }
        }
    }
    
    static func downloadTexture(withUrl url: String,withCompletion block: @escaping (SKTexture) -> Void)
    {
        log.debug("")
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
