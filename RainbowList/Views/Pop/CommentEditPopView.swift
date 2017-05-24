//
//  CommentEditPopView.swift
//  RainbowList
//
//  Created by admin on 2017/3/20.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit
import SnapKit

typealias InputCompletedBlock = (String) -> Void

private let kTextViewFontSize: CGFloat = 17
private let kTextViewHeight: CGFloat = 150 //文本框高度
private let kContentViewHeight: CGFloat = kTextViewHeight

class CommentEditPopView: UIView {

    
    let btnWidthNormal = 40
    let btnWidthHighlighted = 50
    
    var inputCompletedBlock: InputCompletedBlock?
    
    var contentViewBottomConstraint: Constraint?
    var shouldChangeContentViewFrameWhenKeyboardHidden: Bool = true
    
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
    // MARK: - Life Cycle
    init(){
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
        NotificationCenter.default.removeObserver(self)
    }
    
    
    //MARK: - Public Method
    
    //显示自己
    func show(inView view: UIView?, inputCompleted: @escaping InputCompletedBlock) {
        
        self.inputCompletedBlock = inputCompleted
        
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
    
    
    // MARK: - Private Method

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
                            self.layoutIfNeeded()
            },completion:{ _ in
                
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
extension CommentEditPopView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView === self.textInputView {
            self.placeholderLabel.isHidden = !textView.text.isEmpty
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if textView === self.textInputView {
            if text == "\n" {
                
                self.dismiss(){
                    if let block = self.inputCompletedBlock {
                        block(self.textInputView.text)
                    }
                    self.inputCompletedBlock = nil
                }

                return false
            }
        }
        return true
    }
    
}
