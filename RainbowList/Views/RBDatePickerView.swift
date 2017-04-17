//
//  RBDatePickerView.swift
//  RainbowList
//
//  Created by admin on 2017/3/2.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit
import Toast_Swift

protocol RBDatePickerViewDelegate: NSObjectProtocol {
    
    func cancelPick(datePickerView: RBDatePickerView)
    func confirmPick(datePickerView: RBDatePickerView, selectedDate: Date, repeatType: RBRepeatType)
    
}

class RBDatePickerView: UIView {

    static let kDateToolbarHeight: CGFloat = 40
    static let kRepeatChooseViewHeight: CGFloat = 35
    
    weak var delegate: RBDatePickerViewDelegate?
    
    var date: Date {
        
        didSet {
            self.datePicker.setDate(self.date, animated: false)
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    var repeatType: RBRepeatType
    
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
        })
        confirmBtn.snp.makeConstraints({ (make) in
            make.right.equalTo(view).offset(-10)
            make.top.bottom.equalTo(view)
        })
        
        return view
    }()
    
    lazy var segmentView: UISegmentedControl = {
        var segment = UISegmentedControl(items: ["提醒一次","每日重复","每周重复","每月重复"])
        segment.addTarget(self, action: #selector(segmentValueChanged(sender:)), for: .valueChanged)
        segment.tintColor = UIColor(hexString: ThemeManager.shared.themeColorHexString)
        segment.selectedSegmentIndex = 0
        return segment
    }()
    
    lazy var datePicker: UIDatePicker = {
        var picker = UIDatePicker()
        picker.date = self.date
        return picker
    }()
    
    
    init(date: Date = DateUtil.getNextNeatDate(), repeatType: RBRepeatType = RBRepeatType.none) {
        self.date = date
        self.repeatType = repeatType
        
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.white
        
        addSubview(toolbar)
        addSubview(segmentView)
        addSubview(datePicker)
        
        self.segmentView.selectedSegmentIndex = repeatType.rawValue
        
        toolbar.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(self)
            make.height.equalTo(RBDatePickerView.kDateToolbarHeight)
        }
        
        segmentView.snp.makeConstraints { (make) in
            make.top.equalTo(toolbar.snp.bottom).offset(30)
            make.height.equalTo(RBDatePickerView.kRepeatChooseViewHeight)
            make.centerX.equalToSuperview()
        }
        datePicker.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-40)
            make.centerX.equalToSuperview().offset(-10) //iphone6s显示偏右？
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
        
        if datePicker.date < Date() && self.repeatType == RBRepeatType.none{
            UIApplication.shared.keyWindow?.makeToast("时间已过，提醒将不会发生！", duration: 3, position:.center)
        }
        
        self.delegate?.confirmPick(datePickerView: self, selectedDate: datePicker.date, repeatType: repeatType)
    }

    func segmentValueChanged(sender: UISegmentedControl) {
        print("======\(sender.selectedSegmentIndex)")
        self.repeatType = RBRepeatType(rawValue: sender.selectedSegmentIndex)!
    }
}
