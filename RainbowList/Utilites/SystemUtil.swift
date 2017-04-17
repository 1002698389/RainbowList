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
    
    
    class func makeAlert(inController controller: UIViewController, title: String, message: String, dismissTitle: String) -> Void
    {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: dismissTitle,
                                         style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        controller.present(alert, animated: true,
                     completion: nil)
    }
}
