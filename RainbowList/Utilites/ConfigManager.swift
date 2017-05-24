//
//  ConfigManager.swift
//  RainbowList
//
//  Created by admin on 2017/4/11.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit

private let k_DefaultsKey_AppVersion = "k_DefaultsKey_AppVersion"
private let k_Defaultkey_ShowArchivedData = "k_Defaultkey_ShowArchivedData"
private let k_Defaultkey_LeftMenuMaxWidth = "k_Defaultkey_LeftMenuMaxWidth"
private let k_Defaultkey_ContentLineNumbers = "k_Defaultkey_ContentLineNumbers"
private let k_Defaultkey_RemarkLineNumbers = "k_Defaultkey_RemarkLineNumbers"
private let k_Defaultkey_HasShowAlert_ArchiveAlarm = "k_Defaultkey_HasShowAlert_ArchiveAlarm"
private let k_Defaultkey_SyncEnabled = "k_Defaultkey_SyncEnabled"

class ConfigManager: NSObject {
    
    static let shared = ConfigManager()
    private override init() {}
    
    func initConfig()
    {
        if isFirstTimeRunApp() {
            
            DBManager.shared.insertDefaultData()
            
            leftMenuWidth = k_SCREEN_WIDTH * 0.3
        }
        
        UserDefaults.standard.set(k_AppVersion, forKey: k_DefaultsKey_AppVersion)
        UserDefaults.standard.synchronize()
        
    }
    
    //列表中是否应该显示归档数据
    var shouldShowArchiveData: Bool
    {
        get{
            return UserDefaults.standard.bool(forKey: k_Defaultkey_ShowArchivedData)
        }
        set{
            UserDefaults.standard.set(newValue, forKey: k_Defaultkey_ShowArchivedData)
            UserDefaults.standard.synchronize()
        }
    }
    //是否已经弹出过归档警告
    var hasShowAlertForArchiveData: Bool
    {
        get{
            return UserDefaults.standard.bool(forKey: k_Defaultkey_HasShowAlert_ArchiveAlarm)
        }
        set{
            UserDefaults.standard.set(newValue, forKey: k_Defaultkey_HasShowAlert_ArchiveAlarm)
            UserDefaults.standard.synchronize()
        }
    }
    
    //配置左侧菜单展开宽度
    var leftMenuWidth: CGFloat
    {
        get{
            return CGFloat(UserDefaults.standard.float(forKey: k_Defaultkey_LeftMenuMaxWidth))
        }
        set{
            UserDefaults.standard.set(Float(newValue), forKey: k_Defaultkey_LeftMenuMaxWidth)
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: Notification.Name(NotificationConstants.refreshLeftMenuMaxWidthNotification), object: nil)
        }
    }
    
    //配置事件列表内容显示行数
    var maxLineNumbersForEventCellContent: Int
    {
        get{
            return UserDefaults.standard.integer(forKey: k_Defaultkey_ContentLineNumbers)
        }
        set{
            UserDefaults.standard.set(newValue, forKey: k_Defaultkey_ContentLineNumbers)
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: Notification.Name(NotificationConstants.refreshEventListShouldNotRequeryNotification), object: nil)
        }
    }
    //配置事件列表备注显示行数
    var maxLineNumbersForEventCellRemark: Int
    {
        get{
            return UserDefaults.standard.integer(forKey: k_Defaultkey_RemarkLineNumbers)
        }
        set{
            UserDefaults.standard.set(newValue, forKey: k_Defaultkey_RemarkLineNumbers)
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: Notification.Name(NotificationConstants.refreshEventListShouldNotRequeryNotification), object: nil)
        }
    }

    var isCloudSyncEnabled: Bool
    {
        get{
            return UserDefaults.standard.bool(forKey: k_Defaultkey_SyncEnabled)
        }
        set{
            UserDefaults.standard.set(newValue, forKey: k_Defaultkey_SyncEnabled)
            UserDefaults.standard.synchronize()
        }
    }
    
    func downloadConfigFromCloud()
    {
        if isCloudSyncEnabled {
            
        }
    }
    func uploadConfigToCloud()
    {
        if isCloudSyncEnabled {
            
        }
    }
    
    func isFirstTimeRunApp() -> Bool
    {
        return UserDefaults.standard.string(forKey: k_DefaultsKey_AppVersion) == nil
    }

}
