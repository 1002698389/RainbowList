//
//  Macro.swift
//  RainbowList
//
//  Created by admin on 2017/2/24.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit

// MARK : 全局常量

let k_SCREEN_HEIGHT = UIScreen.main.bounds.height
let k_SCREEN_WIDTH = UIScreen.main.bounds.width

let k_ListTable_OrderBase = 500
let k_Appid = "1221862568"
let k_AppDisplayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") ?? ""
let k_AppVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? ""


let documentUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

//友盟统计
let UMAppKey = "58de113307fe6511540013ed"
let UMEvent_CreateNewEvent = "UMEvent_CreateNewEvent"
let UMEvent_CreateNewList = "UMEvent_CreateNewList"
let UMEvent_DeleteEvent = "UMEvent_DeleteEvent"
let UMEvent_DeleteList = "UMEvent_DeleteList"
let UMEvent_ModifyEvent = "UMEvent_ModifyEvent"
let UMEvent_ModifyList = "UMEvent_ModifyList"
let UMEvent_ModifyListOrder = "UMEvent_ModifyListOrder"
let UMEvent_RecreateListOrder = "UMEvent_RecreateListOrder"
let UMEvent_ArchiveEvent = "UMEvent_ArchiveEvent"
let UMEvent_UnarchiveEvent = "UMEvent_UnarchiveEvent"
let UMEvent_ChangeSlideWidth = "UMEvent_ChangeSlideWidth"
let UMEvent_ChangeContentLineNumber = "UMEvent_ChangeContentLineNumber"
let UMEvent_ClickAboutCell = "UMEvent_ClickAboutCell"
let UMEvent_ClickReviewCell = "UMEvent_ClickReviewCell"
let UMEvent_ClickShareAppButton = "UMEvent_ClickShareAppButton"
let UMEvent_ClickSettingButton = "UMEvent_ClickSttingButton"
let UMEvent_ClickEditListButton = "UMEvent_ClickEditListButton"

//通知常量
struct NotificationConstants{
    //展开左菜单通知
    static let openLeftMenuNotification = "openLeftMenuNotification"
    
    //关闭左菜单通知
    static let closeLeftMenuNotification = "closeLeftMenuNotification"
    
    //完全展开左菜单通知
    static let openLeftMenuEntirelyNotification = "openLeftMenuEntirelyNotification"
    
    //切换清单通知
    static let selectListNotification = "selectListNotification"
    //切换的清单key，用来从通知中获取切换到了哪个清单
    static let selectedListKey = "selectedListKey"
    
    //present一个新的VC
    static let presentNewViewControllerNotification = "presentNewViewControllerNotification"
    //所展示的新VC的key，用来从通知中获取新的VC
    static let presentNewViewControllerKey = "presentNewViewControllerKey"
    
    //刷新事件列表通知
    static let refreshEventListShouldRequeryFromDatabaseNotification = "refreshEventListShouldRequeryFromDatabaseNotification"
    static let refreshEventListShouldNotRequeryNotification = "refreshEventListShouldNotRequeryNotification"
    
    //刷新清单列表通知
    static let refreshListDataWithCreationNotification = "refreshListDataWithCreationNotification"
    static let refreshListDataWithUpdateNotification = "refreshListDataWithUpdateNotification"
    
    //跳转设置页通知
    static let jumpToSettingPageNotification = "jumpToSettingPageNotification"
    
    //刷新左侧菜单宽度
    static let refreshLeftMenuMaxWidthNotification = "refreshLeftMenuMaxWidthNotification"
    
    //本地通知触发
    static let userNotificationTriggerNotification = "userNotificationTriggerNotification"
    //触发通知对象的key，value为一个RBEvent id
    static let userNotificationTriggerKey = "userNotificationTriggerKey"
}
