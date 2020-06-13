//
//  AppDelegate.swift
//  GoGetter
//
//  Created by Batth on 11/09/17.
//  Copyright © 2017 Batth. All rights reserved.
//

import UIKit
import CoreData
import FBSDKCoreKit
import Firebase
import IQKeyboardManagerSwift
import Fabric
import Crashlytics
import CoreLocation
import UserNotifications
import FacebookCore
import SwiftyStoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
//com.ionicframework.slinder952690
    //1927798904135900
    //fb1927798904135900
    var window: UIWindow?
    var locationManager: CLLocationManager!
    var latitude:Double = 0.0
    var longitude:Double = 0.0
    var currentController: UIViewController!
    
    var timer:Timer!
    
    var startDate:Date!
    var endDate:Date!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UserDefaults.standard.set(true, forKey: "UpdateImages")
        UserDefaults.standard.synchronize()
  //      ClientLog.WriteClientLog( msgType: "ios", msg:"appstart");
        
        
        startDate = Date()
            
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        FirebaseApp.configure()
        
        window?.backgroundColor = UIColor.white
//        LoginManager().logOut()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        application.applicationIconBadgeNumber = 0
        
        if LocalStore.store.isLogin() {
            FirebaseObserver.observer.observeFriendList()
            FirebaseObserver.observer.observeFriendsRemoved()
           
            // original
            let controller = storyboard.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
            let navigationController = UINavigationController(rootViewController: controller)
            navigationController.interactivePopGestureRecognizer?.isEnabled = false
            controller.isRootController = true
            window?.rootViewController = navigationController
//
            // test
//            let controller = PurchaseViewController.loadFromNib()
//            let controller = PurchaseManagerViewController.loadFromNib()
//            let controller = ReservePurchaseViewController.loadFromNib()
//            let controller = TestPurchaseViewController.loadFromNib()
//            let controller = PurchaseManagerViewController.loadFromNib()
//            let controller = storyboard.instantiateViewController(withIdentifier: "ListViewController")
//            self.window?.rootViewController = controller
            
        }
        else{
//ClientLog.WriteClientLog( msgType: "ios", msg:"not logged");
        }
        
        IQKeyboardManager.shared.enable = true
        Fabric.with([Crashlytics.self])
        
       
        
        if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject] {
            let apsDictionary = notification["aps"] as? [String: Any]
            let requiredData = apsDictionary!["requiredData"] as? [String: Any]
            let dictData = NSKeyedArchiver.archivedData(withRootObject: requiredData!)

            if requiredData!["type"] as? String == "chat" {
                UserDefaults.standard.setValue(dictData, forKey: "ChatUser")
                UserDefaults.standard.set(true, forKey: "chatNotification")
                UserDefaults.standard.synchronize()
            }
            else if requiredData!["type"] as? String == "like" {
                UserDefaults.standard.setValue(dictData, forKey: "LikedUser")
                UserDefaults.standard.set(true, forKey: "likedNotification")
                UserDefaults.standard.synchronize()
            }
            else if requiredData!["type"] as? String == "match"  {
                UserDefaults.standard.setValue(dictData, forKey: "matchedUser")
                UserDefaults.standard.set(true, forKey: "matchedNotification")
                UserDefaults.standard.synchronize()
            }
            else if requiredData!["type"] as? String == "new_match"  {
                UserDefaults.standard.setValue(dictData, forKey: "newMatchedUser")
                UserDefaults.standard.set(true, forKey: "newMatchedNotificationClicked")
                UserDefaults.standard.set(true, forKey: "newMatchedNotification")
                UserDefaults.standard.synchronize()
            }
        }
        else{
                UserDefaults.standard.set(false, forKey: "matchedNotification")
        }
        
        // see notes below for the meaning of Atomic / Non-Atomic
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in

            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                // Unlock content
                case .failed, .purchasing, .deferred:
                    break // do nothing
                }
            }
        }
        
        return true
    }
    
    func startLocationManager() {
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            //ClientLog.WriteClientLog( msgType: "ios", msg:"startlocation");
            locationManager.startUpdatingLocation()
            //ClientLog.WriteClientLog( msgType: "ios", msg:"endlocation");
        }
        else {
            let yesAction = self.currentController.action("Go to Settings?", .default) { (action) in
                //UIApplication.shared.open(URL(string:"prefs:root=LOCATION_SERVICES")!, options: [:], completionHandler: nil)
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }
            
            let noAction = self.currentController.action("Cancel", .cancel) { (action) in                    }
            self.currentController.showAlertWithCustomButtons("", "Apologies but we need to access your location in order to find matches in your area. Please enable location from your device settings.", yesAction,noAction)
        }
    }
    
    func registerForRemoteNotifications() {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in
//                    print("Permission granted: \(granted)")
                })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    
    func sendDeviceTokenToServer() {
   //     ClientLog.WriteClientLog( msgType: "ios", msg:"senddevid");
        let facebookID = LocalStore.store.getFacebookID()
        
        var parameters = Dictionary<String, Any?>()
        parameters["user_fb_id"] = facebookID
        
        if let deviceId = UserDefaults.standard.value(forKey: "device_token") as? String  {
            parameters["device_id"] = deviceId
        }
        else {
            parameters["device_id"] = "asdasdasdasdas"
        }
        
        WebServices.service.webServicePostRequest(.post, .user, .deviceToken, parameters as Dictionary<String, Any>, successHandler: { (response) in
            
            
        }, errorHandler: { (error) in
            
        })
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
	    let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        UserDefaults.standard.set(deviceTokenString, forKey: "device_token")
        UserDefaults.standard.synchronize()
        print(deviceTokenString)
        self.sendDeviceTokenToServer()
        self.startLocationManager()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {        
       // print("i am not available in simulator \(error)")
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        let apsDictionary = userInfo["aps"] as? [String: Any]
        let requiredData = apsDictionary!["requiredData"] as? [String: Any]
        let dictData = NSKeyedArchiver.archivedData(withRootObject: requiredData!)

        if requiredData!["type"] as? String == "like" {
            application.applicationIconBadgeNumber = 0
            
            UserDefaults.standard.setValue(dictData, forKey: "LikedUser")
            UserDefaults.standard.set(true, forKey: "likedNotification")
            UserDefaults.standard.synchronize()
            
            if application.applicationState == .active {
                if currentController.isKind(of: ProfileViewController.self){
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "likedNotification"), object: nil, userInfo: requiredData)
                }
                else {
                    let alert = UIAlertController.init(title: "", message: (requiredData?["message"] as! String), preferredStyle: .alert)
                    let action = UIAlertAction.init(title: "View Profile", style: .default, handler: { (action) in
                        self.currentController.navigationController?.popToRootViewController(animated: true)

                    })
                    let action1 = UIAlertAction.init(title: "Cancel", style: .default, handler: { (action) in
                        UserDefaults.standard.set(false, forKey: "likedNotification")
                        UserDefaults.standard.synchronize()
                    })
                    alert.addAction(action)
                    alert.addAction(action1)
                    
                    currentController.present(alert, animated: true, completion: nil)
                }
            }
            
        }
        else if requiredData!["type"] as? String == "match"  {
            application.applicationIconBadgeNumber = 0
            UserDefaults.standard.setValue(dictData, forKey: "matchedUser")
            UserDefaults.standard.set(true, forKey: "matchedNotification")
            UserDefaults.standard.synchronize()
            
            if application.applicationState == .active {
                if currentController.isKind(of: ProfileViewController.self){
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "matchedNotification"), object: nil, userInfo: requiredData)
                }
                else if self.currentController.isKind(of: EditProfileViewController.self) {
                    self.currentController.viewWillAppear(true)
                }
                else {
                    currentController.navigationController?.popToRootViewController(animated: true)
                    }
            }
            else {
                
            }
        }
        else if requiredData!["type"] as? String == "new_match"  {
            application.applicationIconBadgeNumber = 0
            UserDefaults.standard.setValue(dictData, forKey: "newMatchedUser")
            UserDefaults.standard.set(true, forKey: "newMatchedNotification")
            UserDefaults.standard.set(false, forKey: "newMatchedNotificationClicked")
            UserDefaults.standard.synchronize()
            
            if application.applicationState == .active {
                let alert = UIAlertController.init(title: "New Match:", message: (requiredData?["message"] as! String), preferredStyle: .alert)
                let action = UIAlertAction.init(title: "Say Hello", style: .default, handler: { (action) in
                    if self.currentController.isKind(of: ProfileViewController.self){
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newMatchedNotification"), object: nil, userInfo: requiredData)
                    }
                    else if self.currentController.isKind(of: ChatListViewController.self) {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newMatchListNotification"), object: nil, userInfo: requiredData)
                    }
                    else if self.currentController.isKind(of: EditProfileViewController.self) {
                        self.currentController.viewWillAppear(true)
                    }
                    else {
                        self.currentController.navigationController?.popToRootViewController(animated: true)
                    }
                })
                let action1 = UIAlertAction.init(title: "Maybe Later", style: .default, handler:{ (action) in
                    UserDefaults.standard.set(false, forKey: "newMatchedNotification")
                    UserDefaults.standard.synchronize()
                })
                alert.addAction(action)
                alert.addAction(action1)
                    
                currentController.present(alert, animated: true, completion: nil)
            }
            else {
                
            }
        }
    }
    
    @objc func showChatAlert(requiredData:[String:Any]) {
        let sender = requiredData["sender"] as? [String: Any]
        let alert = UIAlertController.init(title: "Message", message: String(format: "%@: %@",sender!["user_name"] as! CVarArg,(requiredData["message"] as! String)), preferredStyle: .alert)
        let action = UIAlertAction.init(title: "Chat", style: .default, handler: { (action) in
            if self.currentController.isKind(of: ProfileViewController.self) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "chatNotification"), object: nil, userInfo: requiredData)
                
            }else if self.currentController.isKind(of: ChatListViewController.self){
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "chatListNotification"), object: nil, userInfo: requiredData)
                
            }else {
                self.currentController.navigationController?.popToRootViewController(animated: true)
            }
            
        })
        let action1 = UIAlertAction.init(title: "Cancel", style: .default, handler:nil)
        alert.addAction(action)
        alert.addAction(action1)
        
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    // Below method will provide you current location.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation:CLLocation = locations.last!
        latitude = currentLocation.coordinate.latitude
        longitude = currentLocation.coordinate.longitude
        
        locationManager?.stopUpdatingLocation()
        if timer != nil {
            timer.invalidate()
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { (time) in
            self.timer.invalidate()
            self.saveUserLocation()
        })
        
    }
    
    // Below Mehtod will print error if not able to update location.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if self.currentController != nil {
            let yesAction = self.currentController.action("Go to Settings?", .default) { (action) in
                //UIApplication.shared.open(URL(string:"prefs:root=LOCATION_SERVICES")!, options: [:], completionHandler: nil)
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }
            
            let noAction = self.currentController.action("Cancel", .cancel) { (action) in                    }
            self.currentController.showAlertWithCustomButtons("", "Apologies but we need to access your location in order to find matches in your area. Please enable location from your device settings.", yesAction,noAction)
        }
    }
    
    func saveUserLocation() {
        var parameters = Dictionary<String, Any?>()
        parameters["user_fb_id"] = LocalStore.store.getFacebookID()
//        parameters["latitude"] = String(format:"%f", self.latitude)
//        parameters["longitude"] = String(format:"%f", self.longitude)
        parameters["latitude"] = String(format:"%f", 32.715736)
        parameters["longitude"] = String(format:"%f", -117.161087)
        WebServices.service.webServicePostRequest(.post, .user, .setLocation, parameters as Dictionary<String, Any>, successHandler: { (response) in
            if self.currentController != nil {
                self.currentController.getUserDetails(false)
            }
        }, errorHandler: { (error) in
        })
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        endDate = Date()
        let sessionTime = self.secondsToHoursMinutesSeconds(seconds:Int(endDate.timeIntervalSince(startDate)))
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "id-SessionLength",
            AnalyticsParameterItemName: String(format:"SessionLength %@",sessionTime)
            ])
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        startDate = Date()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if LocalStore.store.isLogin() {
            FirebaseObserver.observer.observeFriendList()
            FirebaseObserver.observer.observeFriendsRemoved()
            FirebaseObserver.observer.count = 0
            FirebaseObserver.observer.observeOnline()
            self.startLocationManager()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        return ApplicationDelegate.shared.application(app, open: url, options: options)
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Slindir")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> String {
        return String(format:"%d:%d",(seconds % 3600) / 60, (seconds % 3600) % 60)
    }
   
}
