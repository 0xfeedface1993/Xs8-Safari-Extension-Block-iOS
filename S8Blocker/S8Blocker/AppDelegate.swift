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
import WebShell_iOS

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
        self.saveContext()
    }

    // MARK: - Split view

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
        if topAsDetailController.detailItem == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }
    // MARK: - Core Data stack
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        guard let modelURL = Bundle.main.url(forResource: "S8Blocker", withExtension: "momd") else {
            fatalError("failed to find data model")
        }
        
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("failed to load model")
        }
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        let options = [NSMigratePersistentStoresAutomaticallyOption:true, NSInferMappingModelAutomaticallyOption:true]
        let dirURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.ascp.sex8block"), fileURL = URL(string: "S8Blocker.sql", relativeTo: dirURL)
        do {
            try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: fileURL, options: options)
            let moc = NSManagedObjectContext(concurrencyType:.privateQueueConcurrencyType)
            moc.persistentStoreCoordinator = psc
            return moc
        } catch {
            fatalError("Error configuring persistent store: \(error)")
        }
    }()

    // MARK: - Core Data Saving support

    func saveContext (flag: Bool = false) {
        let context = managedObjectContext
        if context.hasChanges {
            do {
                let request = NSFetchRequest<DRecord>(entityName: "DRecord")
                request.predicate = NSPredicate(value: true)
                let records = try context.fetch(request)
                records.forEach({
                    let status = DownloadStatus(rawValue: $0.status)!
                    if flag {
                        if status == .downloading || status == .waitting {
                            $0.status = DownloadStatus.errors.rawValue
                        }
                    }
                })
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        let backgroundSession = PCDownloadManager.share.backgroundSession
        print("Rejoining session with identifier \(identifier) \(backgroundSession)")
        PCDownloadManager.share.completeHandle[identifier] = completionHandler
        let notification = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "有一项下载任务完成"
        content.body = "点击打开App继续下一个任务"
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: "com.ascp.s8.downlaod.finished", content: content, trigger: nil)
        notification.add(request) { (err) in
            if let e = err {
                print(e)
            }
        }

    }
}

