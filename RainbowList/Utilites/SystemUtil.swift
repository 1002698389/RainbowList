//
//  SystemUtil.swift
//  RainbowList
//
//  Created by admin on 2017/3/29.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit

class SystemUtil: NSObject {
    
    //跳到系统设置页面
    class func jumpToSettingPage() {
        let url = URL.init(string:UIApplicationOpenSettingsURLString)!
        if UIApplication.shared.canOpenURL(url){
            UIApplication.shared.open(url, options:[:], completionHandler: nil)
        }
    }
    
}
