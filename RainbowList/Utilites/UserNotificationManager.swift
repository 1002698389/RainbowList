//
//  UserNotificationManager.swift
//  RainbowList
//
//  Created by admin on 2017/3/28.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit
import UserNotifications

class UserNotificationManager: NSObject {
    
    static let shared = UserNotificationManager()
    private override init() {
    }
    
    func requestUserNotificationAuthorization(completionHandler: @escaping () -> ()) {

        UNUserNotificationCenter.current().requestAuthorization(options: [.badge,.alert,.sound]) { (granted, error) in
            if granted {
                print("authorization succeed!")
                completionHandler()
            }else{
                self.presentRquestAuthorAlert()
            }
        }
    }
    
    func presentRquestAuthorAlert() {
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "获取通知权限失败！", message: "在应用被授予使用系统通知权限之前，提醒功能将无法正常使用。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "去授权", style: .default, handler: {
                _ in
                SystemUtil.jumpToSettingPage()
            }))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func addUserNotification(forEvent event: RBEvent) {
        
        guard let _ = event.alarm else {
            return
        }
        
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus == .notDetermined {
                
                self.requestUserNotificationAuthorization {
                    self.realAddUserNotifiaction(forEvent: event)
                }
                
            }else if settings.authorizationStatus == .denied{
                
                self.presentRquestAuthorAlert()
                
            }else if settings.authorizationStatus == .authorized {
                
                self.realAddUserNotifiaction(forEvent: event)
            }
        })

    }
    
    func realAddUserNotifiaction(forEvent event: RBEvent) {
        
        if let alarm = event.alarm {
            let content = UNMutableNotificationContent()
            content.title = "提醒"
            content.body = event.content
            content.sound = UNNotificationSound(named: "alarm.mp3")
            
            let dateComponents = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: alarm.ringTime)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let requestIdentifier = event.identifier
            let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if error == nil {
                    print("Time Interval Notification scheduled: \(requestIdentifier) for event:\(event.identifier)")
                }
            }
        }
    }
    
    func removeUserNotification(forEvent event: RBEvent) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [event.identifier])
    }
    
    func removeAllUserNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    
}

extension UserNotificationManager: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let alert = UIAlertController(title: notification.request.content.title, message: notification.request.content.body, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "关闭", style: .cancel, handler: nil))
//        alert.addAction(UIAlertAction(title: "查看", style: .default, handler: {
//            _ in
//            let eventId = notification.request.identifier
//            NotificationCenter.default.post(name: Notification.Name(NotificationConstants.userNotificationTriggerNotification), object: nil, userInfo: [NotificationConstants.userNotificationTriggerKey: eventId])
//        }))
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let eventId = response.notification.request.identifier
        NotificationCenter.default.post(name: Notification.Name(NotificationConstants.userNotificationTriggerNotification), object: nil, userInfo: [NotificationConstants.userNotificationTriggerKey: eventId])
        
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        completionHandler()
    }
    
    
}
