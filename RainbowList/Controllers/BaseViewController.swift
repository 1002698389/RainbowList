//
//  BaseViewController.swift
//  RainbowList
//
//  Created by admin on 2017/2/24.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        NotificationCenter.default.addObserver(self, selector: #selector(presentNewVC(notification:)), name: Notification.Name(rawValue: NotificationConstants.presentNewViewControllerNotification), object: nil)
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    func presentNewVC(notification: Notification) {
        if self === self.navigationController?.topViewController {
            if let userInfo = notification.userInfo {
                if let vc = userInfo[NotificationConstants.presentNewViewControllerKey] as? UIViewController {
                    self.navigationController?.present(vc, animated: true, completion: nil)
                }
            }
        }
        
    }
    
    deinit {
        print("======deinit======\(NSStringFromClass(type(of: self)))")
    }
}
