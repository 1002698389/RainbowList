//
//  AboultViewController.swift
//  RainbowList
//
//  Created by admin on 2017/3/30.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit
import MessageUI

class AboultViewController: UIViewController {

    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var opensourceButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var contactMeButton: UIButton!
    
    @IBOutlet weak var appNameVersionLabel: UILabel!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        MobClick.event(UMEvent_ClickAboutCell)
        
        iconImageView.layer.cornerRadius = 8
        iconImageView.layer.masksToBounds = true
        
        appNameVersionLabel.text = "\(k_AppDisplayName) V\(k_AppVersion)"
        
        opensourceButton.setTitleColor(UIColor(hexString: ThemeManager.shared.themeColorHexString), for: .normal)
        shareButton.setTitleColor(UIColor(hexString: ThemeManager.shared.themeColorHexString), for: .normal)
        contactMeButton.setTitleColor(UIColor(hexString: ThemeManager.shared.themeColorHexString), for: .normal)
    }

    
    
    // MARK: - Interaction Event Handler
    
    @IBAction func showOpenSource(_ sender: Any) {
    }
    
    @IBAction func shareApp(_ sender: UIButton) {
        
        MobClick.event(UMEvent_ClickShareAppButton)
        
        let textToShare = "\(k_AppDisplayName)-让生活变得简单!"
        let icon = UIImage(named:"icon")!
        let downloadUrl = NSURL(string: "https://itunes.apple.com/us/app/id\(k_Appid)")!
        let objectsToShare = [textToShare,icon,downloadUrl] as [Any]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivityType.addToReadingList, UIActivityType.print]
        
        activityVC.popoverPresentationController?.sourceView = sender
            present(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func contactMe(_ sender: UIButton) {
        if MFMailComposeViewController.canSendMail(){
            let controller = MFMailComposeViewController()
            controller.mailComposeDelegate = self
            controller.setSubject("#用户交流#--\(k_AppDisplayName)")
            controller.setToRecipients(["develop4ios@163.com"])
            
            controller.setMessageBody("", isHTML: false)
            controller.navigationBar.isTranslucent = false
            controller.navigationBar.tintColor = UIColor(hexString: ThemeManager.shared.themeColorHexString)

            //打开界面
            present(controller, animated: true, completion: nil)
        }else{
            view.makeToast("暂时无法发送邮件！")
        }
    }
    // MARK: - Private Method
    
}


extension AboultViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        
        controller.dismiss(animated: true, completion: nil)
        switch result{
        case .sent:
            view.makeToast("邮件已发送!")
        case .cancelled:
            view.makeToast("邮件已取消!")
        case .saved:
            view.makeToast("邮件已保存!")
        case .failed:
            view.makeToast("邮件发送失败!")
        }
    }
}
