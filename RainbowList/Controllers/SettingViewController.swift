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
            MobClick.event(UMEvent_ChangeSlideWidth)
            ConfigManager.shared.leftMenuWidth = CGFloat(sliderView.value) * k_SCREEN_WIDTH
        }
        
        if let value = Int(contentLineNumbersTextField.text ?? "") {
            ConfigManager.shared.maxLineNumbersForEventCellContent = value
        }
        
        if let value = Int(remarkLineNumbersTextField.text ?? "") {
            ConfigManager.shared.maxLineNumbersForEventCellRemark = value
        }
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
        
        let oldValue = ConfigManager.shared.leftMenuWidth / k_SCREEN_WIDTH
        sliderView.value = Float(oldValue)
        sliderValueLabel.text = "侧滑菜单比例:\(Int(oldValue * 100))%"
        sliderView.tintColor = UIColor(hexString: ThemeManager.shared.themeColorHexString)
        let img = UIImage(named:"ver_line")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        sliderView.setThumbImage(img, for: .normal)
        
        let contentLineNumbers = ConfigManager.shared.maxLineNumbersForEventCellContent
        contentLineNumbersTextField.text = "\(contentLineNumbers)"
        contentLineNumbersTextField.isEnabled = false
        let remarkLineNumbers = ConfigManager.shared.maxLineNumbersForEventCellRemark
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
        
        //太小了设置按钮都露不出来了
        if sender.value < 0.2 {
            sender.value = 0.2
        }
        
        sliderValueLabel.text = "侧滑菜单比例:\(Int(sender.value * 100))%"
        leftMenuWidthChanged = true
    }
    @IBAction func increaseTitleLineNumbers(_ sender: UIButton) {
        showClickAnimate(forButton: sender)
        
        if var value = Int(contentLineNumbersTextField.text ?? "") {
            value += 1
            contentLineNumbersTextField.text = "\(value)"
        }
    }
    @IBAction func decreaseTitleLineNumbers(_ sender: UIButton) {
        showClickAnimate(forButton: sender)
        if var value = Int(contentLineNumbersTextField.text ?? "") {
            value -= 1
            value = max(0, value)
            contentLineNumbersTextField.text = "\(value)"
        }
    }
    @IBAction func increaseRemarkLineNumbers(_ sender: UIButton) {
        showClickAnimate(forButton: sender)
        if var value = Int(remarkLineNumbersTextField.text ?? "") {
            value += 1
            remarkLineNumbersTextField.text = "\(value)"
        }
    }
    @IBAction func decreaseRemarkLineNumbers(_ sender: UIButton) {
        showClickAnimate(forButton: sender)
        if var value = Int(remarkLineNumbersTextField.text ?? "") {
            value -= 1
            value = max(0, value)
            remarkLineNumbersTextField.text = "\(value)"
        }
    }
    
    func showClickAnimate(forButton btn: UIButton) {
        
        MobClick.event(UMEvent_ChangeContentLineNumber)
        
        UIView.animate(withDuration: 0.1, animations: {
            btn.transform = btn.transform.scaledBy(x: 1.2, y: 1.2)
        }) { (completed) in
            btn.transform = CGAffineTransform.identity
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
            controller.navigationBar.isTranslucent = false
            controller.navigationBar.tintColor = UIColor(hexString: ThemeManager.shared.themeColorHexString)

            //打开界面
            present(controller, animated: true, completion: nil)
        }else{
            view.makeToast("暂时无法发送邮件！")
        }
    }
    
    
    
    func appReview() {
        let urlString = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=\(k_appid)"
        if let url = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(url){
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
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
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            if indexPath.row == 0 {//反馈
                sendEmail()
            }else if indexPath.row == 1 {//评价
                MobClick.event(UMEvent_ClickReviewCell)
                appReview()
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
