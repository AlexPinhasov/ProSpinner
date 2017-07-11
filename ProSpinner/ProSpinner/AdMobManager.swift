//
//  AdMobManager.swift
//  ProSpinner
//
//  Created by AlexP on 3.6.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import Foundation
import GoogleMobileAds

class AdMobManager: NSObject,
                    GADInterstitialDelegate
{
    var interstitial: GADInterstitial!
    var bannerView: GADBannerView!
    weak var rootViewController: UIViewController?
    
    
    init(rootViewController: UIViewController)
    {
        super.init()
        self.rootViewController = rootViewController
        configureGADInterstitial()
        interstitial.delegate = self
        configureGADBanner()
        addObserver()
        
        if ArchiveManager.interstitalCount > 5
        {
            ArchiveManager.interstitalCount = 1
        }
    }
    
    func addObserver()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(shouldShowInterstitial), name: NSNotification.Name(NotifictionKey.interstitalCount.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addBannerToView), name: NSNotification.Name(NotifictionKey.loadingFinish.rawValue), object: nil)
    }
    
    func shouldShowInterstitial()
    {
        guard let rootViewController = rootViewController else { return }
        
        if interstitial.isReady
        {
            interstitial.present(fromRootViewController: rootViewController)
        }
    }
    
    
    func configureGADBanner()
    {
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        bannerView.adUnitID = "ca-app-pub-9437548574063413/3716115489"
        bannerView.rootViewController = rootViewController
        rootViewController?.view.addSubview(bannerView)
        bannerView.load(GADRequest())
    }
    
    func addBannerToView()
    {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(NotifictionKey.loadingFinish.rawValue), object: nil)
    }
    
    func configureGADInterstitial()
    {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-9437548574063413/9116200689")
        interstitial.load(GADRequest())
    }

    /// Called when an interstitial ad request succeeded. Show it at the next transition point in your
    /// application such as when transitioning between view controllers.
    func interstitialDidReceiveAd(_ ad: GADInterstitial)
    {
        interstitial = ad
    }
    
    /// Called when an interstitial ad request completed without an interstitial to
    /// show. This is common since interstitials are shown sparingly to users.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError)
    {
        
    }
    
    /// Called just before presenting an interstitial. After this method finishes the interstitial will
    /// animate onto the screen. Use this opportunity to stop animations and save the state of your
    /// application in case the user leaves while the interstitial is on screen (e.g. to visit the App
    /// Store from a link on the interstitial).
    func interstitialWillPresentScreen(_ ad: GADInterstitial)
    {
        
    }
    
    /// Called when |ad| fails to present.
    func interstitialDidFail(toPresentScreen ad: GADInterstitial)
    {
        
    }
    
    /// Called before the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial)
    {
        ArchiveManager.interstitalCount = 1
        configureGADInterstitial()
    }
    
    /// Called just after dismissing an interstitial and it has animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial)
    {

    }
    
    /// Called just before the application will background or terminate because the user clicked on an
    /// ad that will launch another application (such as the App Store). The normal
    /// UIApplicationDelegate methods, like applicationDidEnterBackground:, will be called immediately
    /// before this.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial)
    {
        
    }
}
