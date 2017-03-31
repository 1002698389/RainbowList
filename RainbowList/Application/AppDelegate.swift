//
//  AppDelegate.swift
//  RainbowList
//
//  Created by admin on 2017/2/27.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit
import UserNotifications
import Toast_Swift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        print(documentUrl?.path ?? "")
        
        //数据库初始化
        initDatabase()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        window?.makeKeyAndVisible()
        window?.rootViewController = MainContainerViewController()
        
        //定制UI
        UINavigationBar.appearance().tintColor = UIColor.white
        ToastManager.shared.duration = 2
        
        //本地通知
        UNUserNotificationCenter.current().delegate = UserNotificationManager.shared
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(pushToNotificationDetail(notification:)), name: Notification.Name(NotificationConstants.userNotificationTriggerNotification), object: nil)
        
        return true
    }
    
    
    func initDatabase(){
        
        if let value = UserDefaults.standard.string(forKey: k_DefaultsKey_AppVersion) {
            print("app version:" + value)
        } else {
            print("first time run app")
            UserDefaults.standard.set(k_SCREEN_WIDTH * 0.3, forKey: k_Defaultkey_LeftMenuMaxWidth)
            DBManager.shared.insertDefaultData()
        }
        
        UserDefaults.standard.set(k_AppVersion, forKey: k_DefaultsKey_AppVersion)
        UserDefaults.standard.synchronize()
    }

    
    func pushToNotificationDetail(notification: Notification) {
        if let eventId = notification.userInfo?[NotificationConstants.userNotificationTriggerKey] as? String{
            let rootVC = MainContainerViewController()
            window?.rootViewController = rootVC
            if let event = DBManager.shared.findEvent(eventId: eventId) {
                let detailVC = EventDetailViewController(event: event)
                rootVC.mainNavController?.pushViewController(detailVC, animated: true)
            }
        }
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
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

