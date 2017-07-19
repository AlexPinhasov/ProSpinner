//
//  ArchiveManager.swift
//  ProSpinner
//
//  Created by AlexP on 30.5.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import Foundation
import SpriteKit

enum UserDefaultKeys: String
{
    case red                        = "redCounter"
    case blue                       = "blueCounter"
    case green                      = "greenCounter"
    case mainSpinnerIndex           = "mainSpinnerIndex"
    case interstitialCount          = "interstitalCount"
    case spinnersInDisk             = "Spinners"
    case firstTimeRun               = "firstTimeRun"
    case highScore                  = "highScore"
    case muteSound                  = "muteSound"
    case tutorial                  = "tutorial"
}

class ArchiveManager
{
    static let comingMoreSpinnerId = 300
    static let moreSpinnersDemi = 1
    static var currentlyAtIndex  = ArchiveManager.mainSpinnerLocation
    static var currentlyDownloadedSpinnersArray : [Spinner] = [Spinner]()
    
    static var spinnersArrayInDisk : [Spinner] = [Spinner]()
    {
        didSet
        {
            log.debug("")
            if spinnersArrayInDisk.count > 0
            {
                ArchiveManager.write_SpinnerToUserDefault(spinners: spinnersArrayInDisk)
            }
        }
    }
    
    static var spinnersArrayInDiskCount: Int
    {
        log.debug("")
        return ArchiveManager.spinnersArrayInDisk.count - moreSpinnersDemi
    }
    
    static func sortArrayInDiskAfterUpdate()
    {
        log.debug("")
        ArchiveManager.spinnersArrayInDisk.sort(by:
        {
            let firstSum = $0.redNeeded! + $0.blueNeeded! + $0.greenNeeded!
            let secondSum = $1.redNeeded! + $1.blueNeeded! + $1.greenNeeded!
            return firstSum < secondSum
        })
    }
    
    
    static func resetDownloadedSpinnersArray()
    {
        log.debug("")
        ArchiveManager.currentlyDownloadedSpinnersArray = [Spinner]()
    }
    
    
    static var mainSpinnerLocation : Int
    {
        get
        {
            log.debug("")
            return UserDefaults.standard.integer(forKey: UserDefaultKeys.mainSpinnerIndex.rawValue)
        }
        set
        {
            log.debug("")
            UserDefaults.standard.set(newValue, forKey: UserDefaultKeys.mainSpinnerIndex.rawValue)
            UserDefaults.standard.synchronize()
                
        }
    }
    
    static var interstitalCount : Int
    {
        get
        {
            log.debug("")
            return UserDefaults.standard.integer(forKey: UserDefaultKeys.interstitialCount.rawValue)
        }
        set
        {
            log.debug("")
            UserDefaults.standard.set(newValue, forKey: UserDefaultKeys.interstitialCount.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    
    static var currentSpinner : Spinner
    {
        get
        {
            log.debug("")
            return ArchiveManager.spinnersArrayInDisk[ArchiveManager.currentlyAtIndex]
        }
    }
    
    static func write_SpinnerToUserDefault(spinners : [Spinner])
    {
        log.debug("")
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: spinners)
        
        UserDefaults.standard.set(encodedData, forKey: UserDefaultKeys.spinnersInDisk.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    static func currentSpinnerHasBeenUnlocked()
    {
        log.debug("")
        resetMainSpinners()
        ArchiveManager.spinnersArrayInDisk[ArchiveManager.currentlyAtIndex].unlocked = true
        ArchiveManager.spinnersArrayInDisk[ArchiveManager.currentlyAtIndex].mainSpinner = true
        mainSpinnerLocation = ArchiveManager.currentlyAtIndex
        let updatedArray = ArchiveManager.spinnersArrayInDisk
        write_SpinnerToUserDefault(spinners: updatedArray)
    }
    
    static func changeMainSpinner()
    {
        log.debug("")
        resetMainSpinners()
        ArchiveManager.spinnersArrayInDisk[ArchiveManager.currentlyAtIndex].mainSpinner = true
        mainSpinnerLocation = ArchiveManager.currentlyAtIndex
        let updatedArray = ArchiveManager.spinnersArrayInDisk
        write_SpinnerToUserDefault(spinners: updatedArray)
    }
    
    static func resetMainSpinners()
    {
        log.debug("")
        for spinner in spinnersArrayInDisk { spinner.mainSpinner = false }
    }
    
    static func read_SpinnersFromUserDefault() -> [Spinner]
    {
        log.debug("")
        if let data = UserDefaults.standard.data(forKey: UserDefaultKeys.spinnersInDisk.rawValue)
        {
            if let spinnerArray = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Spinner]
            {
                ArchiveManager.spinnersArrayInDisk = spinnerArray
                return spinnerArray
            }
        }
        else
        {
            print("There is an issue")
        }
        return [Spinner]()
    }
    
    static var highScoreRecord : Int
    {
        get
        {
            log.debug("")
            return UserDefaults.standard.integer(forKey: UserDefaultKeys.highScore.rawValue)
        }
        set
        {
            log.debug("")
            if newValue > highScoreRecord
            {
                UserDefaults.standard.set(newValue, forKey: UserDefaultKeys.highScore.rawValue)
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    static var firstTimeRun : Bool
    {
        get
        {
            log.debug("")
            return UserDefaults.standard.bool(forKey: UserDefaultKeys.firstTimeRun.rawValue)
        }
        set
        {
            log.debug("")
            UserDefaults.standard.set(true, forKey: UserDefaultKeys.firstTimeRun.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    
    static var gameExplantionDidShow : Bool
    {
        get
        {
            log.debug("")
            return UserDefaults.standard.bool(forKey: UserDefaultKeys.tutorial.rawValue)
        }
        set
        {
            log.debug("")
            UserDefaults.standard.set(newValue, forKey: UserDefaultKeys.tutorial.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    
    static var shouldPlaySound: Bool
    {
        get
        {
            log.debug("")
            return UserDefaults.standard.bool(forKey: UserDefaultKeys.muteSound.rawValue)
        }
        set
        {
            log.debug("")
            UserDefaults.standard.set(newValue, forKey: UserDefaultKeys.muteSound.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
}
