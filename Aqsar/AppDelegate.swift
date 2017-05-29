//
//  AppDelegate.swift
//  Aqsar
//
//  Created by moayad on 7/23/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase

extension FileManager{
    func addSkipBackupAttributeToItemAtURL(_ url:URL) throws {
        try (url as NSURL).setResourceValue(true, forKey: URLResourceKey.isExcludedFromBackupKey)
    }
}

func appDelegate() -> AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
}

func bookDetailsVC() -> BookDetailsViewController {
    if appDelegate().bookDetailsVC == nil {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        appDelegate().bookDetailsVC = storyboard.instantiateViewController(withIdentifier: "BookDetailsViewController") as? BookDetailsViewController
    }
    
    return appDelegate().bookDetailsVC!
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    fileprivate var bookDetailsVC: BookDetailsViewController?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        //---- If there any change on proparty ----//
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 10,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 10) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        let _ = try! Realm()
        //---- End If there any change on proparty -----//
//
        //UINavigationBar.appearance().barStyle = .black
        UIApplication.shared.statusBarStyle = .lightContent
        
        //UITabBar.appearance().translucent = false
        let tabbarBackgroundColor = UIColor(red: 5.0/255.0, green: 48.0/255.0, blue: 45.0/255.0, alpha: 1.0)
        
        UITabBar.appearance().tintColor = darkGreen
//        UITabBar.appearance().barTintColor = lightShinyGreenColor
         
        
        //UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: "DroidArabicKufi", size: 10)!, NSForegroundColorAttributeName: lightShinyGreenColor], forState: .Selected)
        
        //UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: "DroidArabicKufi", size: 10)!, NSForegroundColorAttributeName: UIColor.whiteColor()], forState: .Normal)
        
        //        UITabBarItem.appearance().setTitleTextAttributes([NSBackgroundColorAttributeName: UIColor.whiteColor()], forState: .Selected)
        //        UITabBarItem.appearance().setTitleTextAttributes([NSBackgroundColorAttributeName: UIColor.redColor()], forState: .Normal)
        
        navigateToUserScene()
        
        //setup notifications
        FIRApp.configure()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshNotification), name: NSNotification.Name.firInstanceIDTokenRefresh, object: nil)
        
        let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        
        application.registerForRemoteNotifications()
        
        // skip documents backingup
        do {
            let urlString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let url = URL(string: urlString)
            try FileManager.default.addSkipBackupAttributeToItemAtURL(url!)
        } catch {
            // Handle error here
            print("Error: \(error)")
        }
        
        
        
        return true
    }
    
    fileprivate func navigateToUserScene() {
        func navigateToController(_ storyboradID: String) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let controller = storyboard.instantiateViewController(withIdentifier: storyboradID)
            if let window = self.window {
                window.rootViewController = controller
            }
        }

        // if the user data exist + he has picked books (and categories), go to application directly
        print(RealmHelper.getLoggedinUser())
        if let currentUserData = RealmHelper.getLoggedinUser(), currentUserData.booksUnread.count > 0 || currentUserData.booksCount > 0 || currentUserData.booksInProgress.count > 0 || currentUserData.booksFinished.count > 0 || currentUserData.booksFavorites.count > 0 {
            navigateToController("RAMAnimatedTabBarController")
        }
    }
    
    @objc fileprivate func refreshNotification() {
        FIRMessaging.messaging().connect { error in
            if error == nil {
                print(#function)
            } else {
                print(error)
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print(deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print(userInfo)
        
        print("Message ID: \(userInfo["gcm.message_id"]!)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(userInfo)
        
        print("Message ID: \(userInfo["gcm.message_id"]!)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("ERROR: \(error.localizedDescription)")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

