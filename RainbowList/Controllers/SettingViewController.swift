//
//  SettingViewController.swift
//  RainbowList
//
//  Created by admin on 2017/3/27.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit
import MessageUI

class SettingViewController: UITableViewController {

    @IBOutlet weak var sliderView: UISlider!
    @IBOutlet weak var sliderValueLabel: UILabel!
    
    @IBOutlet weak var contentLineNumbersTextField: UITextField!
    @IBOutlet weak var remarkLineNumbersTextField: UITextField!
    
    @IBOutlet weak var contentDecreaseBtn: UIButton!
    @IBOutlet weak var contentIncreaseBtn: UIButton!
    @IBOutlet weak var remarkDecreaseBtn: UIButton!
    @IBOutlet weak var remarkIncreaseBtn: UIButton!
    @IBOutlet weak var shareCell: UITableViewCell!
    
    var leftMenuWidthChanged: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "设置"
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        customView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        if leftMenuWidthChanged {
            UserDefaults.standard.set(sliderView.value * Float(k_SCREEN_WIDTH), forKey: k_Defaultkey_LeftMenuMaxWidth)
            NotificationCenter.default.post(name: Notification.Name(NotificationConstants.refreshLeftMenuMaxWidthNotification), object: nil)
        }
        
        if let value = Int(contentLineNumbersTextField.text ?? "") {
            UserDefaults.standard.set(value, forKey: k_Defaultkey_ContentLineNumbers)
        }
        if let value = Int(remarkLineNumbersTextField.text ?? "") {
            UserDefaults.standard.set(value, forKey: k_Defaultkey_RemarkLineNumbers)
        }
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: Notification.Name(NotificationConstants.refreshEventListShouldNotRequeryNotification), object: nil)
    }
    
    // MARK: Inherit Method
    
    // MARK: Setup Method
    func customView() {
        tableView.backgroundColor = UIColor(hex: 0xF0EFF5)
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .singleLine
        tableView.allowsSelectionDuringEditing = true
        tableView.tableFooterView = UIView()
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 80, 0)
        
        let oldValue = UserDefaults.standard.float(forKey:k_Defaultkey_LeftMenuMaxWidth) / Float(k_SCREEN_WIDTH)
        sliderView.value = oldValue
        sliderValueLabel.text = "侧滑菜单比例:\(Int(oldValue * 100))%"
        sliderView.tintColor = UIColor(hexString: ThemeManager.shared.themeColorHexString)
        let img = UIImage(named:"ver_line")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        sliderView.setThumbImage(img, for: .normal)
        
        let titleLineNumbers = UserDefaults.standard.integer(forKey: k_Defaultkey_ContentLineNumbers)
        contentLineNumbersTextField.text = "\(titleLineNumbers)"
        contentLineNumbersTextField.isEnabled = false
        let remarkLineNumbers = UserDefaults.standard.integer(forKey: k_Defaultkey_RemarkLineNumbers)
        remarkLineNumbersTextField.text = "\(remarkLineNumbers)"
        remarkLineNumbersTextField.isEnabled = false
        
        let minusImage = UIImage(named: "minus_sign")?.withRenderingMode(.alwaysTemplate)
        let plusImage = UIImage(named: "plus_sign")?.withRenderingMode(.alwaysTemplate)
        contentDecreaseBtn.tintColor = UIColor(hexString: ThemeManager.shared.themeColorHexString)
        contentDecreaseBtn.setImage(minusImage, for: .normal)
        contentIncreaseBtn.tintColor = UIColor(hexString: ThemeManager.shared.themeColorHexString)
        contentIncreaseBtn.setImage(plusImage, for: .normal)
        remarkDecreaseBtn.tintColor = UIColor(hexString: ThemeManager.shared.themeColorHexString)
        remarkDecreaseBtn.setImage(minusImage, for: .normal)
        remarkIncreaseBtn.tintColor = UIColor(hexString: ThemeManager.shared.themeColorHexString)
        remarkIncreaseBtn.setImage(plusImage, for: .normal)
    }

    // MARK: - Public Method
    
    // MARK: - Interaction Event Handler
    
    
    // MARK: - Private Method
    
   
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        sliderValueLabel.text = "侧滑菜单比例:\(Int(sender.value * 100))%"
        leftMenuWidthChanged = true
    }
    @IBAction func increaseTitleLineNumbers(_ sender: Any) {
        if var value = Int(contentLineNumbersTextField.text ?? "") {
            value += 1
            contentLineNumbersTextField.text = "\(value)"
        }
    }
    @IBAction func decreaseTitleLineNumbers(_ sender: Any) {
        if var value = Int(contentLineNumbersTextField.text ?? "") {
            value -= 1
            value = max(0, value)
            contentLineNumbersTextField.text = "\(value)"
        }
    }
    @IBAction func increaseRemarkLineNumbers(_ sender: Any) {
        if var value = Int(remarkLineNumbersTextField.text ?? "") {
            value += 1
            remarkLineNumbersTextField.text = "\(value)"
        }
    }
    @IBAction func decreaseRemarkLineNumbers(_ sender: Any) {
        if var value = Int(remarkLineNumbersTextField.text ?? "") {
            value -= 1
            value = max(0, value)
            remarkLineNumbersTextField.text = "\(value)"
        }
    }
    
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail(){
            let controller = MFMailComposeViewController()
            controller.mailComposeDelegate = self
            controller.setSubject("#意见反馈#--彩虹清单")
            controller.setToRecipients(["develop4ios@163.com"])
            
            var content = "\n\n\n\n\n\n\n\n\n\n\n"
            content += "设备:\(UIDevice.current.model)\n"
            content += "系统:\(UIDevice.current.systemVersion)\n"
            content += "App版本:\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "")"
            controller.setMessageBody(content, isHTML: false)
            
            //打开界面
            present(controller, animated: true, completion: nil)
        }else{
            view.makeToast("暂时无法发送邮件！")
        }
    }
    
    func shareApp() {
        
        let textToShare = "彩虹清单-让生活变得简单!"
        let icon = UIImage(named:"picture")!
        let downloadUrl = NSURL(string: "https://itunes.apple.com/us/app/id970057582")!
        let objectsToShare = [textToShare,icon,downloadUrl] as [Any]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivityType.addToReadingList, UIActivityType.print]
        
        activityVC.popoverPresentationController?.sourceView = shareCell
        present(activityVC, animated: true, completion: nil)
        
    }
    // MARK: Notification Handler
    
}

extension SettingViewController {

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "视图设置"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            
            if indexPath.row == 0 {//分享应用
                shareApp()
            }else if indexPath.row == 1 {//反馈
                sendEmail()
            }
        }
    }
}
extension SettingViewController: MFMailComposeViewControllerDelegate {
    
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
