//
//  RBDatePickerView.swift
//  RainbowList
//
//  Created by admin on 2017/3/2.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit
import Toast

protocol RBDatePickerViewDelegate: class {
    
    func cancelPick(datePickerView: RBDatePickerView)
    func confirmPick(datePickerView: RBDatePickerView, selectedDate: Date)
    
}

class RBDatePickerView: UIView {

    static let kDatePickerHeight: CGFloat = 216
    static let kDateToolbarHeight: CGFloat = 40
    static let kViewHeight: CGFloat = kDatePickerHeight + kDateToolbarHeight
    
    weak var delegate: RBDatePickerViewDelegate?
    
    var date: Date {
        
        didSet {
            self.datePicker.setDate(self.date, animated: false)
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    lazy var toolbar: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor(hex: 0xf1f1f1)
        
        let upLine = UIView()
        upLine.backgroundColor = UIColor.lightGray
        view.addSubview(upLine)
        
        let deleteBtn = UIButton()
        deleteBtn.setTitle("移除提醒", for: .normal)
        deleteBtn.setTitleColor(UIColor.gray, for: .normal)
        deleteBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        deleteBtn.addTarget(self, action: #selector(deleteBtnClicked), for: .touchUpInside)
        view.addSubview(deleteBtn)
        
        let confirmBtn = UIButton()
        confirmBtn.setTitle("设置提醒", for: .normal)
        let titleColor = UIColor(hexString: ThemeManager.shared.themeColorHexString)
        confirmBtn.setTitleColor(titleColor, for: .normal)
        confirmBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        confirmBtn.addTarget(self, action: #selector(confirmBtnClicked), for: .touchUpInside)
        view.addSubview(confirmBtn)
        
        upLine.snp.makeConstraints({ (make) in
            make.left.right.top.equalTo(view)
            make.height.equalTo(0.5)
        })
        deleteBtn.snp.makeConstraints({ (make) in
            make.left.equalTo(view).offset(10)
            make.top.bottom.equalTo(view)
            make.width.equalTo(80)
        })
        confirmBtn.snp.makeConstraints({ (make) in
            make.right.equalTo(view).offset(-10)
            make.top.bottom.equalTo(view)
            make.width.equalTo(80)
        })
        
        return view
    }()
    
    lazy var datePicker: UIDatePicker = {
        var picker = UIDatePicker()
        picker.date = self.date
        return picker
    }()
    
    
    init(date: Date = DateUtil.getNextNeatDate()) {
        self.date = date
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.white
        
        addSubview(toolbar)
        addSubview(datePicker)
        
        toolbar.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(self)
            make.height.equalTo(RBDatePickerView.kDateToolbarHeight)
        }
        
        datePicker.snp.makeConstraints { (make) in
            make.centerY.equalTo(self).offset(RBDatePickerView.kDateToolbarHeight/2)
            make.centerX.equalTo(self).offset(-10) //iphone6s显示偏右？
            make.height.equalTo(RBDatePickerView.kDatePickerHeight)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func deleteBtnClicked() {
        self.delegate?.cancelPick(datePickerView: self)
        
    }
    func confirmBtnClicked() {
//        print("\(datePicker.date)")
        
        if datePicker.date < Date() {
            UIApplication.shared.keyWindow?.makeToast("时间已过，提醒将不会发生！", duration: 3, position: CSToastPositionCenter)
        }
        
        self.delegate?.confirmPick(datePickerView: self, selectedDate: datePicker.date)
    }

}
