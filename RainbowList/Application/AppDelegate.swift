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
        
//        print(documentUrl?.path ?? "")
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        window?.rootViewController = MainContainerViewController()
        
        //app数据初始化
        ConfigManager.shared.initConfig()

        //定制UI
        UINavigationBar.appearance().tintColor = UIColor.white
        ToastManager.shared.duration = 2
        
        //配置本地通知
        UNUserNotificationCenter.current().delegate = UserNotificationManager.shared
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        application.applicationIconBadgeNumber = 0
        
        UserNotificationManager.shared.resetUserNotification()
        
        //点击通知进入后，push到详情页
        NotificationCenter.default.addObserver(self, selector: #selector(pushToNotificationDetail(notification:)), name: Notification.Name(NotificationConstants.userNotificationTriggerNotification), object: nil)
        
        
        //友盟统计
//        MobClick.setLogEnabled(true)
        if let config = UMAnalyticsConfig.sharedInstance() {
            config.appKey = UMAppKey
            MobClick.start(withConfigure: config)
        }
        
        window?.makeKeyAndVisible()
        return true
    }
    
    //FIXME: 暂时这样简单处理，可能存在一些问题
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
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        application.applicationIconBadgeNumber = 0
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

