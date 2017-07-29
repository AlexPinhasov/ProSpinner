//
//  ShareManager.swift
//  ProSpinner
//
//  Created by Alex Pinhasov on 12/07/2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import UIKit
import Social

class ShareManager
{
    weak static var rootViewController: UIViewController?
    
    // MARK: - Facebook Share
    static func shareToFacebook(withTitle title: String, shareContent contentArray: [Any?], withCompletionHandler completionHandler: SLComposeViewControllerCompletionHandler?) -> Swift.Void
    {
        log.debug("")
        guard SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) else
        {
            AppDelegate.showToast(withString: "No Facebook profile found")
            return
        }
        
        if let facebookViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        {
            if facebookViewController.setInitialText(title)
            {
                print("Added setInitialText: \(title) to share")
            }
            
            for obj in contentArray
            {
                if let URLObject = obj as? URL,
                   facebookViewController.add(URLObject)
                {
                    print("Added addURL: \(URLObject) to share")
                }
                
                if let imageObject = obj as? UIImage,
                   facebookViewController.add(imageObject)
                {
                    print("Added addImage: \(imageObject) to share")
                }
            }
            
            if let handler = completionHandler {
                facebookViewController.completionHandler = handler
            }
            rootViewController?.present(facebookViewController, animated: true, completion: nil)
        }
    }
}
