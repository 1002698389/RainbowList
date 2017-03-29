//
//  DateChoosePopView.swift
//  RainbowList
//
//  Created by admin on 2017/3/20.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit
import SnapKit


typealias DateChooseCompletedBlock = (Date?) -> Void


class DateChoosePopView: UIView {

    static let kCellIdentifierForContent = "kCellIdentifierForContent"
    static let kContentViewMaxHeight = k_SCREEN_HEIGHT / 2
    static let kCellRowHeight: CGFloat = 50
    
    var contentViewBottomConstraint: Constraint?
    
    var dateChooseCompletedBlock: DateChooseCompletedBlock?
    
    var initDate: Date
    
    lazy var contentHeight: CGFloat = {
        return  DateChoosePopView.kContentViewMaxHeight
    }()
    
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
        
        view.addSubview(self.pickerView)
        
        self.pickerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        return view
    }()
    
    lazy var pickerView: RBDatePickerView = {
        var pickerView = RBDatePickerView(date: self.initDate)
        pickerView.delegate = self
        pickerView.backgroundColor = UIColor.white
        return pickerView
    }()
    // MARK: - Life Cycle
    init(date: Date?) {
        if date != nil {
            self.initDate = date!
        }else {
            self.initDate = DateUtil.getNextNeatDate()
        }
        super.init(frame: UIScreen.main.bounds)
        addSubview(backgroundView)
        addSubview(contentView)
        
        backgroundView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(contentHeight)
            self.contentViewBottomConstraint = make.bottom.equalTo(self.snp.bottom).offset(self.contentHeight).constraint
        }
        self.layoutIfNeeded()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("-------DateChoose Pop view deinit")
    }
    
    //MARK: - Public Method
    
    //显示自己
    func show(inView view: UIView?, chooseCompleted: @escaping DateChooseCompletedBlock) {
        
        self.dateChooseCompletedBlock = chooseCompleted
        
        if self.superview == nil {
            if let v = view {
                v.addSubview(self)
            }else {
                let window = UIApplication.shared.keyWindow
                window?.addSubview(self)
            }
            UIView.animate(withDuration: 0.25) {
                self.backgroundView.alpha = 1
                self.contentViewBottomConstraint?.update(offset: 0)
                self.layoutIfNeeded()
            }
        }
    }
    
    func dismiss(completed: (() -> Void)? = nil) {
        if self.superview != nil {
            
            UIView.animate(withDuration: 0.25, animations: {
                self.backgroundView.alpha = 0
                self.contentViewBottomConstraint?.update(offset: self.contentHeight)
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
        self.dismiss()
    }
}


extension DateChoosePopView: RBDatePickerViewDelegate {
    
    func cancelPick(datePickerView: RBDatePickerView) {
        self.dismiss(){
            if let block = self.dateChooseCompletedBlock {
                block(nil)
            }
            self.dateChooseCompletedBlock = nil
        }
    }
    func confirmPick(datePickerView: RBDatePickerView, selectedDate: Date) {
        self.dismiss(){
            if let block = self.dateChooseCompletedBlock {
                block(selectedDate)
            }
            self.dateChooseCompletedBlock = nil
        }
    }
}
