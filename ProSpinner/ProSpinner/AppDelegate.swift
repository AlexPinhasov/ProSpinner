//
//  AppDelegate.swift
//  ProSpinner
//
//  Created by Alex Pinhasov on 15/05/2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import GoogleMobileAds
import UIKit
import Firebase
import Fabric
import Crashlytics
import XCGLogger
import SwiftyStoreKit
import UserNotifications

// Create a logger object with no destinations
let log = XCGLogger(identifier: "advancedLogger", includeDefaultDestinations: false)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        // Initialize the Google Mobile Ads SDK.
        GADMobileAds.configure(withApplicationID: "ca-app-pub-9437548574063413~9762649081")
        FirebaseApp.configure()
        Fabric.with([Crashlytics.self])
        configureXCGLogger()
        completeIAPTransactions()
        registerForRemoteNotifications(application: application)
        handleReachability()
        
        
        print("FCM token: \(Messaging.messaging().fcmToken ?? "")")
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
         Messaging.messaging().appDidReceiveMessage(userInfo)
        
        application.applicationIconBadgeNumber = 0
        NotificationCenter.default.post(name: NSNotification.Name(NotifictionKey.checkForNewSpinners.rawValue), object: nil)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
         Messaging.messaging().appDidReceiveMessage(userInfo)
        
        application.applicationIconBadgeNumber = 0
        NotificationCenter.default.post(name: NSNotification.Name(NotifictionKey.checkForNewSpinners.rawValue), object: nil)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }
    
    private func handleReachability()
    {
        do {
            Network.reachability = try Reachability(hostname: "www.google.com")
            do {
                try Network.reachability?.start()
            } catch let error as Network.Error {
                print(error)
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
    }
    
    private func completeIAPTransactions()
    {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            
            for purchase in purchases {
                // swiftlint:disable:next for_where
                if purchase.transaction.transactionState == .purchased || purchase.transaction.transactionState == .restored {
                    
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    print("purchased: \(purchase.productId)")
                }
            }
        }
    }
    
    private func configureXCGLogger()
    {
        // Create a destination for the system console log (via NSLog)
        let systemDestination = AppleSystemLogDestination(identifier: "advancedLogger.systemDestination")
        
        // Optionally set some configuration options
        systemDestination.outputLevel = .debug
        systemDestination.showLogIdentifier = false
        systemDestination.showFunctionName = true
        systemDestination.showThreadName = true
        systemDestination.showLevel = true
        systemDestination.showFileName = true
        systemDestination.showLineNumber = true
        systemDestination.showDate = true
        
        // Add the destination to the logger
        log.add(destination: systemDestination)
        
        // Add basic app info, version info etc, to the start of the logs
        log.logAppDetails()
        log.setup(level: .debug, showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: "path/to/file", fileLevel: .debug)
    }
    
    private func registerForRemoteNotifications(application: UIApplication)
    {
        // [START set_messaging_delegate]
        Messaging.messaging().delegate = self
        // [END set_messaging_delegate]
        
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        // [END register_for_notifications]

    }
    
    static func showToast(withString text: String?)
    {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        ToastController().showToast(window: appDelegate?.window, withText: text)
    }
}
//  MARK: Push notification
    
    // [START ios_10_message_handling]
    @available(iOS 10, *)
    extension AppDelegate : UNUserNotificationCenterDelegate {
        
        // Receive displayed notifications for iOS 10 devices.
        func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    willPresent notification: UNNotification,
                                    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            let userInfo = notification.request.content.userInfo
            
            // With swizzling disabled you must let Messaging know about the message, for Analytics
            // Messaging.messaging().appDidReceiveMessage(userInfo)
            
            // Print message ID.
            if let messageID = userInfo[gcmMessageIDKey] {
                print("Message ID: \(messageID)")
            }
            
            // Print full message.
            print(userInfo)
            
            // Change this to your preferred presentation option
            completionHandler([])
        }
        
        func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    didReceive response: UNNotificationResponse,
                                    withCompletionHandler completionHandler: @escaping () -> Void) {
            let userInfo = response.notification.request.content.userInfo
            
            UIApplication.shared.applicationIconBadgeNumber = 0
            NotificationCenter.default.post(name: NSNotification.Name(NotifictionKey.checkForNewSpinners.rawValue), object: nil)
            
            // Print message ID.
            if let messageID = userInfo[gcmMessageIDKey] {
                print("Message ID: \(messageID)")
            }
            
            // Print full message.
            print(userInfo)
            
            completionHandler()
        }
    }
    // [END ios_10_message_handling]
    
    
    extension AppDelegate : MessagingDelegate {
        // [START refresh_token]
        func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
            print("Firebase registration token: \(fcmToken)")
        }
        // [END refresh_token]
        
        // [START ios_10_data_message]
        // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
        // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
        func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
            print("Received data message: \(remoteMessage.appData)")
        }
        // [END ios_10_data_message]
    }
