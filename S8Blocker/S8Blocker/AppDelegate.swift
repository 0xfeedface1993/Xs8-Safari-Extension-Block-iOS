 //
//  AppDelegate.swift
//  S8Blocker
//
//  Created by virus1994 on 2017/6/26.
//  Copyright © 2017年 ascp. All rights reserved.
//

import UIKit
import UserNotifications
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        let splitViewController = self.window!.rootViewController as! UISplitViewController
//        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
//        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
//        splitViewController.delegate = self
//
//        let masterNavigationController = splitViewController.viewControllers[0] as! UINavigationController
//        let controller = masterNavigationController.topViewController as! MasterViewController
//        controller.managedObjectContext = managedObjectContext
        if !UIApplication.shared.isRegisteredForRemoteNotifications {
            UNUserNotificationCenter.current().requestAuthorization(options: UNAuthorizationOptions.alert.union(.sound).union(.badge)) { (isSuccess, err) in
                if isSuccess {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }   else    {
                    print(err?.localizedDescription ?? "***************** ****************")
                }
            }
        }
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var tokenStr: String = ""
        for i in 0 ..< deviceToken.count{
            tokenStr += String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        let token = "\(tokenStr.replacingOccurrences(of: "<", with: "").replacingOccurrences(of: ">", with: ""))"
        print(token)
        
        let request = RegisterDeviceRequest(userid: UIDevice.current.identifierForVendor?.uuidString ?? "admin", deviceid: token)
        let caller = WebserviceCaller<APIResponse<[String:String]>, RegisterDeviceRequest>(url: .debug, way: .post, method: .registerDevice)
        caller.paras = request
        caller.execute = { (data, err, res) in
            if let _ = err {
                return
            }
            
            guard let json = data else {
                print(">>>>>>>>>>>> Empty Data <<<<<<<<<<<<<<")
                return
            }
            
            guard json.code == 200 else {
                print(">>>>>>>>>>>> Error Code: \(json.code), \(json.msg) <<<<<<<<<<<<<<")
                return
            }
            
            guard let inner = json.data else {
                print(">>>>>>>>>>>> Inner Data Empty <<<<<<<<<<<<<<")
                return
            }
            
            print(inner)
        }
        try? Webservice.share.read(caller: caller)
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
        // Saves changes in the application's managed object context before the application terminates.
        
    }
}

