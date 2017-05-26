//
//  FeedbackViewController.swift
//  TxtPainting
//
//  Created by admin on 2017/5/20.
//  Copyright © 2017年 LiberalMan. All rights reserved.
//

import UIKit
import LeanCloud
import Toast_Swift

private let kTextViewFont = UIFont.systemFont(ofSize: 15)

class FeedbackViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    
    lazy var placeholderLabel: UILabel = {
        var label = UILabel()
        label.font = kTextViewFont
        label.text = "这里填写意见或者建议！"
        label.sizeToFit()
        label.frame = CGRect(x: 8, y: 10, width: label.frame.size.width, height: label.frame.size.height)
        label.textColor = UIColor.lightGray
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = .init(rawValue: 0)
        navigationItem.title = "意见反馈"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"send"), style: .plain, target: self, action: #selector(sendBtnClicked(sender:)))
        
        textView.layer.cornerRadius = 5
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 3, bottom: 0, right: 8)
        textView.font = kTextViewFont
        textView.delegate = self
        textView.addSubview(self.placeholderLabel)
        
        textField.delegate = self
        
        if k_SCREEN_HEIGHT <= 480 {
            textViewHeightConstraint.constant = 150
        }
    }
    
    func sendBtnClicked(sender: UIBarButtonItem) {
        
        MobClick.event(UMEvent_Feedback)
        
        if textView.text == "" {
            view.makeToast("反馈内容不能为空", duration: k_ToastShortDuration, position: .center)
            return
        }
        if textField.text == "" {
            view.makeToast("联系方式不能为空", duration: k_ToastShortDuration, position: .center)
            return
        }
        
        view.endEditing(true)
        sender.isEnabled = false
        
        activityView.startAnimating()
        
        LeanCloud.initialize(applicationID: "UV4w7w3mB0bhlULK4A2iW5VV-gzGzoHsz", applicationKey: "OghBLxiyiBq2ELs0qQjxtzmF")
        
        let feedback = LCObject(className: "AppFeedback")
        
        feedback.set("appName", value: k_AppDisplayName)
        feedback.set("appVersion", value: k_AppVersion)
        feedback.set("appBundleId", value: k_AppBundleId)
        feedback.set("deviceModel", value: UIDevice.current.model)
        feedback.set("deviceModelName", value: UIDevice.current.modelName)
        feedback.set("systemVersion", value: UIDevice.current.systemVersion)
        feedback.set("systemName", value: UIDevice.current.systemName)
        feedback.set("content", value: textView.text)
        feedback.set("contactInfo", value: textField.text)
        
        feedback.save { result in
            self.activityView.stopAnimating()
            switch result {
            case .success:
                self.view.makeToast("感谢您的反馈！", duration: k_ToastLongDuration, position: .center)
                self.textView.text = ""
                self.textField.text = ""
                self.placeholderLabel.isHidden = false
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+k_ToastLongDuration, execute: {
                    self.navigationController?.popViewController(animated: true)
                })
                
            case .failure(let error):
                self.view.makeToast("发送失败！请稍后再试！", duration: k_ToastLongDuration, position: .center)
                print(error)
            }
            sender.isEnabled = true
        }
    }

}
extension FeedbackViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView === self.textView {
            self.placeholderLabel.isHidden = !textView.text.isEmpty
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if textView === self.textView {
            if text == "\n" {
                textField.becomeFirstResponder()
                return false
            }
        }
        return true
    }
}

extension FeedbackViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
