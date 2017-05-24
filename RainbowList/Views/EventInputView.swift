//
//  EventInputView.swift
//  RainbowList
//
//  Created by admin on 2017/3/1.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit
import SnapKit
import Photos


enum EventAdditionalType {
    case alarm
    case remark
    case picture
    case priority
}

protocol EventInputViewDelegate: NSObjectProtocol {
    
    func finishedInput(inputView: EventInputView)
}

private let kTextViewFontSize: CGFloat = 20
private let kTextViewHeight: CGFloat = 150 //文本框高度
private let kToolbarHeight: CGFloat = 40 //工具栏高度
private let kContentViewHeight: CGFloat = kTextViewHeight + kToolbarHeight

class EventInputView: UIView {
    

    let btnWidthNormal = 40
    let btnWidthHighlighted = 50
    
    weak var delegate: EventInputViewDelegate?
    
    var contentViewBottomConstraint: Constraint?
    var shouldChangeContentViewFrameWhenKeyboardHidden: Bool = true
    
    var list: RBList
    var event: RBEvent
    
    //背景
    lazy var backgroundView: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.3)
        view.alpha = 0
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapBackgroundView)))
        return view
    }()
    
    //主视图
    lazy var contentView: UIView = {
        var view = UIView()
        //文本框
        view.addSubview(self.textInputView)
        self.textInputView.snp.makeConstraints { (make) in
            make.left.top.width.equalTo(view)
            make.height.equalTo(kTextViewHeight)
        }
        //toolbar
        view.addSubview(self.toolbar)
        self.toolbar.snp.makeConstraints { (make) in
            make.left.bottom.width.equalTo(view)
            make.height.equalTo(kToolbarHeight)
        }
        //上圆角
        let maskPath = UIBezierPath(roundedRect: CGRect(x:0, y:0, width:self.bounds.size.width, height:kContentViewHeight), byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 8, height: 8 ))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = view.bounds
        maskLayer.path = maskPath.cgPath
        view.layer.mask = maskLayer
        return view
    }()
    
    //文本框 在主视图内
    lazy var textInputView: UITextView = {
        var textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: kTextViewFontSize)
        textView.delegate = self
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 0, right: 8)
        textView.textColor = UIColor.darkGray
        textView.returnKeyType = .done
        textView.enablesReturnKeyAutomatically = true
        //placeholder
        textView.addSubview(self.placeholderLabel)
        return textView
    }()
    lazy var placeholderLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: kTextViewFontSize)
        label.text = "写点什么呢?"
        label.sizeToFit()
        label.frame = CGRect(x: 13, y: 10, width: label.frame.size.width, height: label.frame.size.height)
        label.textColor = UIColor.lightGray
        return label
    }()
    //工具栏，在主内容视图内
    lazy var toolbar: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor(hex: 0xf1f1f1)
//        view.layer.shadowOffset = CGSize(width: 0, height: -0.5)
//        view.layer.shadowOpacity = 0.3
//        view.layer.shadowRadius = 1
        let line = UIView()
        line.backgroundColor = UIColor.lightGray
        view.addSubview(line)
        
        view.addSubview(self.alarmBtn)
        view.addSubview(self.remarkBtn)
        view.addSubview(self.pictureBtn)
        view.addSubview(self.priorityBtn)
        
        line.snp.makeConstraints({ (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(0.5)
        })
        
        self.alarmBtn.snp.makeConstraints({ (make) in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.greaterThanOrEqualTo(40)
        })
        self.remarkBtn.snp.makeConstraints({ (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(self.alarmBtn.snp.right).offset(10)
            make.width.equalTo(self.btnWidthNormal)
        })
        self.pictureBtn.snp.makeConstraints({ (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(self.remarkBtn.snp.right).offset(10)
            make.width.equalTo(self.btnWidthNormal)
        })
        self.priorityBtn.snp.makeConstraints({ (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(self.pictureBtn.snp.right).offset(10)
            make.width.equalTo(self.btnWidthNormal)
        })
        
        return view
    }()
    lazy var alarmBtn: UIButton = {
        var alarmBtn = self.generateToolbarButton(title: "",
                                                  imageNameNormal: "alarm",
                                                  imageNameSelected:"alarm_selected")
        alarmBtn.addTarget(self, action: #selector(alarmBtnClicked(btn:)), for: .touchUpInside)
        alarmBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        return alarmBtn
    }()
    
    lazy var remarkBtn: UIButton = {
        var remarkBtn = self.generateToolbarButton(title: "",
                                                   imageNameNormal: "remark",
                                                   imageNameSelected: "remark_selected")
        remarkBtn.addTarget(self, action: #selector(remarkBtnClicked(btn:)), for: .touchUpInside)
        return remarkBtn
    }()
    lazy var pictureBtn: UIButton = {
        var pictureBtn = self.generateToolbarButton(title: "",
                                                    imageNameNormal: "picture",
                                                    imageNameSelected: "picture_selected")
        pictureBtn.addTarget(self, action: #selector(pictureBtnClicked(btn:)), for: .touchUpInside)
        return pictureBtn
    }()
    lazy var priorityBtn: UIButton = {
        var priorityBtn = self.generateToolbarButton(title: "",
                                                     imageNameNormal: "flag",
                                                     imageNameSelected: "flag_selected")
        priorityBtn.addTarget(self, action: #selector(priorityBtnClicked(btn:)), for: .touchUpInside)
        return priorityBtn
    }()
    //工具栏上可选项触发展示的视图
    //时间选择器
    var datePickerView: RBDatePickerView?
    //图片选择器
    var pictureChooseView: RBPictureChooseView?
    //优先级选择
    var priorityChooseView: RBPriorityChooseView?
    
    //备注输入
    lazy var remarkView: UIView = {
        var view = UIView()
        view.alpha = 0
        view.backgroundColor = UIColor(hex: 0xf1f1f1)
        
        view.addSubview(self.remarkInputView)

        let delBtn = UIButton()
        delBtn.setTitle("移除备注", for: .normal)
        delBtn.setTitleColor(UIColor.gray, for: .normal)
        delBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        delBtn.addTarget(self, action: #selector(deleteRemark), for: .touchUpInside)
        view.addSubview(delBtn)
        view.addSubview(self.addRemarkBtn)

        self.remarkInputView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(delBtn.snp.top).offset(-5)
        }
        delBtn.snp.makeConstraints({ (make) in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.height.equalTo(40)
        })
        self.addRemarkBtn.snp.makeConstraints({ (make) in
            make.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(40)
        })

        //上圆角
        let maskPath = UIBezierPath(roundedRect: CGRect(x:0, y:0, width:self.bounds.size.width, height:kContentViewHeight), byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 8, height: 8 ))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = view.bounds
        maskLayer.path = maskPath.cgPath
        view.layer.mask = maskLayer
        
        return view
    }()
    lazy var remarkInputView: UITextView = {
        var textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: kTextViewFontSize)
        textView.delegate = self
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 0, right: 8)
        textView.textColor = UIColor.darkGray
//        textView.returnKeyType = .done
        //placeholder
        textView.addSubview(self.remarkPlaceholderLabel)
        return textView
    }()
    lazy var remarkPlaceholderLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: kTextViewFontSize)
        label.text = "填写备注!"
        label.sizeToFit()
        label.frame = CGRect(x: 13, y: 10, width: label.frame.size.width, height: label.frame.size.height)
        label.textColor = UIColor.lightGray
        return label
    }()
    lazy var addRemarkBtn: UIButton = {
        var addBtn = UIButton()
        addBtn.setTitle("添加备注", for: .normal)
        addBtn.setTitleColor(UIColor.clear, for: .normal)
        addBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        addBtn.addTarget(self, action: #selector(addRemarkBtnClicked), for: .touchUpInside)
        return addBtn
    }()
    // MARK: - Life Cycle
    init(list: RBList) {
        
        self.list = list
        self.event = RBEvent(list: list)
        
        super.init(frame: UIScreen.main.bounds)
        addSubview(backgroundView)
        addSubview(contentView)
        
        backgroundView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { (make) in
            self.contentViewBottomConstraint = make.bottom.equalTo(self.snp.bottom).constraint
            make.left.right.equalTo(self)
            make.height.equalTo(kContentViewHeight)
        }
        self.layoutIfNeeded()
        
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: nil))
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("-------event input view deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    
    //MARK: - Public Method
    
    //显示自己
    func show(inView view: UIView?) {
        
        //弹出键盘
        textInputView.becomeFirstResponder()
        
        if self.superview == nil {
            if let v = view {
                v.addSubview(self)
            }else {
                let window = UIApplication.shared.keyWindow
                window?.addSubview(self)
            }
            UIView.animate(withDuration: 0.25) {
                self.backgroundView.alpha = 1
            }
        }
        
    }
    
    func dismiss(completed: (() -> Swift.Void)? = nil) {
        if self.superview != nil {
            UIView.animate(withDuration: 0.25, animations: {
                self.backgroundView.alpha = 0
                self.contentViewBottomConstraint?.update(offset: kContentViewHeight)
                self.layoutIfNeeded()
            }, completion: { (_) in
                
                if let block = completed {
                    block()
                }
                self.removeFromSuperview()
            })
        }
    }
    // MARK: - Interaction Event Handler
    func tapBackgroundView() {
        shouldChangeContentViewFrameWhenKeyboardHidden = false
        //收起键盘
        textInputView.resignFirstResponder()
        self.dismiss()
    }
    
    func alarmBtnClicked(btn: UIButton) {
        showDatePickerView()
    }
    func remarkBtnClicked(btn: UIButton) {
        showRemarkInputView()
    }
    func pictureBtnClicked(btn: UIButton) {
        showPictureChooseView()
    }
    func priorityBtnClicked(btn: UIButton) {
        showPriorityChooseView()
    }
    
    func addRemarkBtnClicked() {
        self.addRemark(remark: self.remarkInputView.text)
    }
    // MARK: - Private Method
    func generateToolbarButton(title: String, imageNameNormal: String, imageNameSelected: String) -> UIButton {
        let btn = UIButton()
        let img = UIImage.init(named: imageNameNormal)?.withRenderingMode(.alwaysOriginal)
        let imgSel = UIImage.init(named: imageNameNormal)?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        btn.setImage(img, for: .normal)
        btn.setImage(imgSel, for: .selected)
        btn.tintColor = UIColor(hexString: ThemeManager.shared.themeColorHexString)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont (ofSize: 15)
        btn.setTitleColor(UIColor.lightGray, for: .normal)
        btn.setTitleColor(UIColor(hexString: ThemeManager.shared.themeColorHexString), for: .selected)
        btn.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .horizontal)
        btn.contentHorizontalAlignment = .left
        return btn
    }
    func showDatePickerView() {
        shouldChangeContentViewFrameWhenKeyboardHidden = false
        self.textInputView.resignFirstResponder()
        
        
        let dateView = DateChoosePopView(date: self.event.alarm?.ringTime, repeatType: self.event.alarm?.repeatType)
        dateView.show(inView: UIApplication.shared.keyWindow, chooseCompleted: {
            date, repeatType in
            if date != nil {
                self.addAlarm(date: date!, repeatType: repeatType!)
            }else {
                self.deletaAlarm()
            }
        }) {
            self.textInputView.becomeFirstResponder()
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            self.contentViewBottomConstraint?.update(offset: 0)
            self.layoutIfNeeded()
        }){(_) in
        }
        //添加闹钟时间选择视图
        //        if let date = self.event.alarm?.ringTime, let repeatType = self.event.alarm?.repeatType {
        //            datePickerView = RBDatePickerView(date: date, repeatType: repeatType)
        //        }else{
        //            datePickerView = RBDatePickerView()
        //        }
        //        datePickerView?.delegate = self
        //
        //        if datePickerView?.superview == nil {
        //            self.addSubview(datePickerView!)
        //            datePickerView?.snp.makeConstraints { (make) in
        //                make.top.equalTo(contentView.snp.top)
        ////                make.top.equalTo(contentView.snp.bottom).offset(-EventInputView.kToolbarHeight)
        //                make.left.right.bottom.equalTo(self)
        //            }
        //            self.setNeedsLayout()
        //        }
        //
        //        datePickerView?.alpha = 0
        
    }
    
    func addAlarm(date: Date, repeatType: RBRepeatType) {
        let alarm = RBAlarm(ringTime: date, eventId: self.event.identifier)
        alarm.repeatType = repeatType
        event.alarm = alarm
        alarmBtn.isSelected = true
        let title = "  \(DateUtil.stringInReadableFormat(date: date, repeatType: alarm.repeatType)) "
        alarmBtn.setTitle(title, for: .normal)
    }
    func deletaAlarm() {
        event.alarm = nil
        alarmBtn.isSelected = false
        alarmBtn.setTitle("", for: .normal)
    }
    
    func showRemarkInputView() {
        self.backgroundView.isUserInteractionEnabled = false
        if self.remarkView.superview == nil {
            self.addSubview(self.remarkView)
            self.remarkView.snp.makeConstraints { (make) in
                make.edges.equalTo(self.contentView).inset(UIEdgeInsetsMake(0, 0, 0, 0))
            }
            self.setNeedsLayout()
        }
        
        self.remarkView.alpha = 0
        
        self.remarkPlaceholderLabel.isHidden = !(self.event.remark == nil)
        
        UIView.animate(withDuration: 0.25 ,animations: {
            self.remarkView.alpha = 1
        }) { (_) in
            self.remarkInputView.becomeFirstResponder()
        }
        
    }
    
    func hideRemarkInputView() {
        self.backgroundView.isUserInteractionEnabled = true
        self.textInputView.becomeFirstResponder()

        if self.remarkView.superview != nil {
            
            UIView.animate(withDuration: 0.25, animations: {
                self.remarkView.alpha = 0
                self.setNeedsLayout()
            }) { (_) in
                self.remarkView.removeFromSuperview()
            }
        }
    }

    func addRemark(remark: String) {
        if self.remarkInputView.text == "" {
            return
        }
        
        self.event.remark = remark
        hideRemarkInputView()
        self.remarkBtn.isSelected = true
    }
    func deleteRemark() {
        self.remarkInputView.text = ""
        self.event.remark = nil
        self.remarkBtn.isSelected = false
        hideRemarkInputView()
    }
    
    func showPictureChooseView() {
        self.shouldChangeContentViewFrameWhenKeyboardHidden = false
        self.textInputView.resignFirstResponder()
        self.backgroundView.isUserInteractionEnabled = false
        
        if self.pictureChooseView == nil {
            self.pictureChooseView = RBPictureChooseView(event: self.event)
            self.pictureChooseView!.delegate = self
        }

        if self.pictureChooseView?.superview == nil {
            self.addSubview(pictureChooseView!)
            self.pictureChooseView?.snp.makeConstraints { (make) in
                make.top.equalTo(contentView.snp.top)
//                make.top.equalTo(contentView.snp.bottom).offset(-EventInputView.kToolbarHeight)
                make.left.right.bottom.equalTo(self)
            }
            self.setNeedsLayout()
        }
        
        self.pictureChooseView?.alpha = 0
        UIView.animate(withDuration: 0.25, animations: {
            self.pictureChooseView?.alpha = 1
        }){(_) in
        }
    }
    
    func deleteImages() {
        self.pictureBtn.isSelected = false
        self.pictureBtn.setTitle("", for: .normal)
        self.event.images = nil
        self.pictureBtn.snp.updateConstraints({ (make) in
            make.width.equalTo(btnWidthNormal)
        })
        self.textInputView.becomeFirstResponder()
        self.backgroundView.isUserInteractionEnabled = true
    }
    func addImages(images: [RBImage]) {
        self.pictureBtn.isSelected = true
        self.pictureBtn.setTitle(" \(images.count)", for: .normal)
        self.event.images = images
        
        self.pictureBtn.snp.updateConstraints({ (make) in
            make.width.equalTo(btnWidthHighlighted)
        })
        
        self.textInputView.becomeFirstResponder()
        self.backgroundView.isUserInteractionEnabled = true
        
    }
    
    func showPriorityChooseView() {
        self.shouldChangeContentViewFrameWhenKeyboardHidden = false
        self.textInputView.resignFirstResponder()
        self.backgroundView.isUserInteractionEnabled = false
        
        if self.priorityChooseView == nil {
            self.priorityChooseView = RBPriorityChooseView(priority: self.event.priority)
            self.priorityChooseView!.delegate = self
        }
        
        if self.priorityChooseView?.superview == nil {
            self.addSubview(self.priorityChooseView!)
            self.priorityChooseView?.snp.makeConstraints { (make) in
                make.top.equalTo(contentView.snp.top)
                make.left.right.bottom.equalTo(self)
            }
            self.setNeedsLayout()
        }
        
        self.priorityChooseView?.alpha = 0
        UIView.animate(withDuration: 0.25, animations: {
            self.priorityChooseView?.alpha = 1
        }){(_) in}

    }
    func addPriority(priority: Int) {
        self.event.priority = priority
        self.priorityBtn.isSelected = true
        let arr = Array.init(repeating: "!", count: priority)
        self.priorityBtn.setTitle(" \(arr.joined())", for: .normal)
        self.textInputView.becomeFirstResponder()
        self.backgroundView.isUserInteractionEnabled = true
    }
    func deletePriority() {
        self.event.priority = 0
        self.priorityBtn.isSelected = false
        self.priorityBtn.setTitle("", for: .normal)
        self.textInputView.becomeFirstResponder()
        self.backgroundView.isUserInteractionEnabled = true
    }
    
    func addNewEvent() {
        DBManager.shared.addNewEvent(event: self.event)
        self.dismiss {
            self.delegate?.finishedInput(inputView: self)
        }
    }
    // MARK: Notification Handler
    
    func keyboardWillShow(notification: Notification) {
        
        self.shouldChangeContentViewFrameWhenKeyboardHidden = true
        
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            
            var keyboardHeightConstant:CGFloat = 0
            
            
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                keyboardHeightConstant = 0.0
            } else {
                keyboardHeightConstant = endFrame?.size.height ?? 0.0
            }
            //            print("----------keyboard height: \(keyboardHeightConstant) ")
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: {
                            self.contentViewBottomConstraint?.update(offset: -(keyboardHeightConstant))
//                            self.datePickerView?.alpha = 0
                            self.pictureChooseView?.alpha = 0
                            self.priorityChooseView?.alpha = 0
                            self.layoutIfNeeded()
            },completion:{ _ in
//
//                if self.datePickerView?.superview != nil {
//                    self.datePickerView?.removeFromSuperview()
//                    self.datePickerView = nil
//                }
                
                if self.pictureChooseView?.superview != nil {
                    self.pictureChooseView?.removeFromSuperview()
                    self.pictureChooseView = nil
                }
                if self.priorityChooseView?.superview != nil {
                    self.priorityChooseView?.removeFromSuperview()
                    self.priorityChooseView = nil
                }
            })
        }
    }
    
    func keyboardWillHide(notification: Notification) {
        
        if !self.shouldChangeContentViewFrameWhenKeyboardHidden {
            //视图会销毁,contentview直接移出视图，而不是移到屏幕底部
            return
        }
        
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            
            var keyboardHeightConstant:CGFloat = 0
            
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                keyboardHeightConstant = 0.0
            } else {
                keyboardHeightConstant = endFrame?.size.height ?? 0.0
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: {
                            self.contentViewBottomConstraint?.update(offset: -(keyboardHeightConstant))
                            self.layoutIfNeeded()
            },completion: nil)
        }
        
    }
}


extension EventInputView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView === self.textInputView {
            self.placeholderLabel.isHidden = !textView.text.isEmpty
        } else if textView === self.remarkInputView {
            self.remarkPlaceholderLabel.isHidden = !textView.text.isEmpty
            let titleColor = textView.text.isEmpty ? UIColor.clear : UIColor(hexString: ThemeManager.shared.themeColorHexString)
            self.addRemarkBtn.setTitleColor(titleColor, for: .normal)
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if textView === self.textInputView {
            if text == "\n" {
                self.event.content = textView.text
                addNewEvent()
                return false
            }
        }
        
        return true
    }
    
}

extension EventInputView: RBDatePickerViewDelegate {
    
    func cancelPick(datePickerView: RBDatePickerView) {
        deletaAlarm()
    }
    
    func confirmPick(datePickerView: RBDatePickerView, selectedDate: Date, repeatType: RBRepeatType) {
        addAlarm(date: selectedDate, repeatType: repeatType)
    }
    
    
}

extension EventInputView: RBPictureChooseViewDelegate {
    
    func cancelChoose(pictureView: RBPictureChooseView) {
        deleteImages()
    }

    func confirmChoose(pictureView: RBPictureChooseView, chosenImages: [RBImage]) {
        addImages(images: chosenImages)
    }
}

extension EventInputView: RBPriorityChooseViewDelegate {
    func cancelChoose(priorityView: RBPriorityChooseView) {
        deletePriority()
    }
    func confirmChoose(priorityView: RBPriorityChooseView, priority: Int) {
        addPriority(priority: priority)
    }
}
