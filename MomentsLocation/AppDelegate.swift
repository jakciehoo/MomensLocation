//
//  AppDelegate.swift
//  MomentsLocation
//
//  Created by HooJackie on 1/15/15.
//  Copyright (c) 2015 jackie. All rights reserved.
//

import UIKit
import CoreData

let MyManagedObjectContextSaveDidFailNotification = "MyManagedObjectContextSaveDidFailNotification"
func fatalCoreDataError(error:NSError?){
    if let error = error {
        print("*** fatal error:\(error), \(error.userInfo)")
    }
    //Creates a notification with a given name and sender and posts it to the receiver.notificationName
    //The name of the notification.notificationSender The object posting the notification.
    NSNotificationCenter.defaultCenter().postNotificationName(MyManagedObjectContextSaveDidFailNotification, object: error)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    lazy var managedObectContext:NSManagedObjectContext = {
        //Returns the file URL for the resource identified by the specified name and file extension.
        //name The name of the resource file.extension If extension is an empty string or nil, the extension is assumed not to exist and the file URL is the first file encountered that exactly matches name.
        //Returns an array of URLs for the specified common directory in the requested domains.
    if let modelURL = NSBundle.mainBundle().URLForResource("DataModel", withExtension: "momd"){
        //An NSManagedObjectModel object describes a schema—a collection of entities (data models) that you use in your application.
        if let model = NSManagedObjectModel(contentsOfURL: modelURL){
            //Instances of NSManagedObjectContext use a coordinator to save object graphs to persistent storage and to retrieve model information. A context without a coordinator is not fully functional as it cannot access a model except through a coordinator.
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
            let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
            let documentsDirectory = urls[0] 
            let storeURL = documentsDirectory.URLByAppendingPathComponent("DataStore.sqlite")
            print(storeURL)
            var error:NSError?
            //Adds a new persistent store of a specified type at a given location, and returns the new store.
            do {
                let store = try coordinator.addPersistentStoreWithType(NSSQLiteStoreType,configuration:nil,URL:storeURL,options:nil)
            let context = NSManagedObjectContext()
            context.persistentStoreCoordinator = coordinator
            return context
            } catch var error1 as NSError {
                error = error1
                print("Error adding persistent store at \(storeURL):\(error!)")
            } catch {
                fatalError()
            }
        }else {
            print("Error initializing model from: \(modelURL)")
        }
    }else {
        print("Could not find data model in app bundle")
        }
        abort()
    }()

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        ShareSDK.registerApp("70661a461144")
        self.initializePlat()
        self.initializePlatForTrusteeship()
       
        let tabBarController = window?.rootViewController as! UITabBarController
        let tabBarItem1 = tabBarController.tabBar.items![0] 

        tabBarItem1.image = UIImage(named: "Tag")?.imageWithRenderingMode(.AlwaysOriginal)
        let tabBarItem2 = tabBarController.tabBar.items![1] 
        tabBarItem2.image = UIImage(named: "Locations")?.imageWithRenderingMode(.AlwaysOriginal)
        let tabBarItem3 = tabBarController.tabBar.items![2] 
        tabBarItem3.image = UIImage(named: "Map")?.imageWithRenderingMode(.AlwaysOriginal)
        let tabBarItem4 = tabBarController.tabBar.items![3] 
        tabBarItem4.image = UIImage(named: "More")?.imageWithRenderingMode(.AlwaysOriginal)
        customizeApperance()
        if let tabBarViewController = tabBarController.viewControllers{
            let currentLocationViewController = tabBarViewController[0] as! CurrentLocationViewController
            currentLocationViewController.managedObjectContext = managedObectContext
            let navigationController = tabBarViewController[1] as! UINavigationController
            let locationsViewController = navigationController.viewControllers[0] as! LocationsViewController
            locationsViewController.managedObjectContext = managedObectContext
            let forceTheViewToload = locationsViewController.view
            let mapViewController = tabBarViewController[2] as! MapViewController
            mapViewController.manageObjectContext = managedObectContext
            //let categoryPickerViewController = CategoryPickerViewController
        }
        listenFatalCoreDataNotification()
        return true
    }
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return ShareSDK.handleOpenURL(url, wxDelegate: self)
    }
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return ShareSDK.handleOpenURL(url, sourceApplication: sourceApplication, annotation: annotation, wxDelegate: self)
    }
    func initializePlat(){
        ShareSDK.connectSinaWeiboWithAppKey("656602314", appSecret: "1afde8e7f97c1c78e382160afba675a3", redirectUri: "http://weibo.com/hooyoo")
        ShareSDK.connectTencentWeiboWithAppKey("1104510145", appSecret: "us9PGXKbPkawsCPh", redirectUri: "www.weibo.com/hooyoo", wbApiCls: WeiboApi.self)
        ShareSDK.connectSMS()
        ShareSDK.connectQZoneWithAppKey("1104510145", appSecret: "us9PGXKbPkawsCPh", qqApiInterfaceCls: QQApiInterface.self, tencentOAuthCls: TencentOAuth.self)
        ShareSDK.connectWeChatWithAppId("wx70ef04115e47bde4", appSecret: "1122e72437da27d0fccdd9314d322142", wechatCls: WXApi.self)
        ShareSDK.connectQQWithQZoneAppKey("1104510145", qqApiInterfaceCls: QQApiInterface.self, tencentOAuthCls: TencentOAuth.self)
        ShareSDK.connectMail()
        ShareSDK.connectAirPrint()
        ShareSDK.connectCopy()
        
    }
    func initializePlatForTrusteeship(){
        ShareSDK.importQQClass(QQApiInterface.self, tencentOAuthCls: TencentOAuth.self)
        ShareSDK.importTencentWeiboClass(WeiboApi.self)
        ShareSDK.importWeChatClass(WXApi.self)
        
    }
    
    func listenFatalCoreDataNotification(){
        NSNotificationCenter.defaultCenter().addObserverForName(MyManagedObjectContextSaveDidFailNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: {notification in
            
            let alert = UIAlertController(title: "Internal Error", message: "There was a fatal error in the app and it cannot continue.\n\n" + "Press OK to terminate the app. Sorry for the inconvenience.", preferredStyle: .Alert)
            
            let action = UIAlertAction(title: "OK", style: .Default){
                    _ in
                //NSException is used to implement exception handling and contains information about an exception. An exception is a special condition that interrupts the normal flow of program execution. Each application can interrupt the program for different reasons.
                let exception = NSException(name: NSInternalInconsistencyException, reason: "Fatal Core Data Error", userInfo: nil)
                //Raises the receiver, causing program flow to jump to the local exception handler.
                exception.raise()
            }
            alert.addAction(action)
            
            //4
            self.viewControllerForShowAlert().presentViewController(alert, animated: true, completion: nil)
            
        })
    }
    //5
    func viewControllerForShowAlert() -> UIViewController {
        let rootViewController = self.window!.rootViewController!
        if let presentedViewController = rootViewController.presentedViewController{
            return presentedViewController
        }else{
            return rootViewController
        }
    }
    //定制页面显示效果
    func customizeApperance() {
        UINavigationBar.appearance().barTintColor = UIColor(red: 138/255, green: 160/255, blue: 60/255, alpha: 1)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        UITabBar.appearance().barTintColor = UIColor(red: 138/255, green: 160/255, blue: 60/255, alpha: 1)
        let tintColor = UIColor(red: 255/255.0, green: 238/255.0, blue: 136/255.0, alpha: 1.0)
        UITabBar.appearance().tintColor = tintColor
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.whiteColor()], forState: .Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.yellowColor()], forState: .Selected)
        
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

